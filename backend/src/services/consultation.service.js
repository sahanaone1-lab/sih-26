const { getSupabase } = require('../config/supabase');
const crypto = require('crypto');
const s3Service = require('./s3.service');
const { v4: uuidv4 } = require('uuid');

const startSession = async (hospitalId, doctorId) => {
  const supabase = getSupabase();
  const token = crypto.randomBytes(32).toString('hex');
  const fallbackCode = crypto.randomBytes(3).toString('hex').toUpperCase();

  const expiresAt = new Date(Date.now() + 90 * 60 * 1000).toISOString(); // 90 min

  const { data: session, error } = await supabase
    .from('consultation_sessions')
    .insert({
      hospital_id: hospitalId,
      doctor_id: doctorId,
      qr_token: token,
      fallback_code: fallbackCode,
      status: 'ACTIVE',
      expires_at: expiresAt,
    })
    .select('*')
    .single();

  if (error) throw error;
  return session;
};

const validateSessionToken = async (token) => {
  const supabase = getSupabase();
  
  const { data: session, error } = await supabase
    .from('consultation_sessions')
    .select('*')
    .eq('qr_token', token)
    .single();

  if (error || !session) {
    const err = new Error('Invalid or expired QR token');
    err.statusCode = 404;
    throw err;
  }

  if (session.status !== 'ACTIVE' || new Date(session.expires_at) < new Date()) {
    const err = new Error('This consultation session has ended or expired');
    err.statusCode = 400;
    throw err;
  }

  // Fetch doctor and hospital separately
  const { data: doctor } = await supabase
    .from('doctors')
    .select('id, first_name, last_name, specialization')
    .eq('id', session.doctor_id)
    .single();

  const { data: hospital } = await supabase
    .from('hospitals')
    .select('id, name')
    .eq('id', session.hospital_id)
    .single();

  return {
    ...session,
    doctors: doctor || { first_name: 'Unknown', last_name: '', specialization: '' },
    hospitals: hospital || { name: 'Unknown Hospital' },
  };
};

const validateFallbackCode = async (code) => {
  const supabase = getSupabase();
  
  // Step 1: Find the session by fallback code
  const { data: session, error } = await supabase
    .from('consultation_sessions')
    .select('*')
    .eq('fallback_code', code)
    .eq('status', 'ACTIVE')
    .single();

  if (error || !session) {
    const err = new Error('Invalid or expired fallback code');
    err.statusCode = 404;
    throw err;
  }

  if (new Date(session.expires_at) < new Date()) {
    const err = new Error('This consultation session has expired');
    err.statusCode = 400;
    throw err;
  }

  // Step 2: Fetch doctor details separately
  const { data: doctor } = await supabase
    .from('doctors')
    .select('id, first_name, last_name, specialization')
    .eq('id', session.doctor_id)
    .single();

  // Step 3: Fetch hospital details separately
  const { data: hospital } = await supabase
    .from('hospitals')
    .select('id, name')
    .eq('id', session.hospital_id)
    .single();

  return {
    ...session,
    doctors: doctor || { first_name: 'Unknown', last_name: '', specialization: '' },
    hospitals: hospital || { name: 'Unknown Hospital' },
  };
};

const uploadDocument = async (token, file) => {
  const session = await validateSessionToken(token);
  
  const supabase = getSupabase();
  const fileExt = file.originalname.split('.').pop();
  const secureFileName = `${uuidv4()}.${fileExt}`;

  // Upload to S3
  const storageKey = await s3Service.uploadBuffer(session.id, file.buffer, secureFileName, file.mimetype);

  // Save metadata to DB
  const { data: doc, error } = await supabase
    .from('temporary_documents')
    .insert({
      session_id: session.id,
      original_filename: file.originalname,
      storage_key: storageKey,
      mime_type: file.mimetype,
      file_size: file.size,
    })
    .select('*')
    .single();

  if (error) {
    // If DB fails, we should ideally rollback S3 but for this MVP we log it
    console.error('Failed to save temp doc metadata:', error);
    throw error;
  }

  return { document: doc, session_id: session.id };
};

const getDocumentUrl = async (documentId, doctorId) => {
  const supabase = getSupabase();

  // Validate that document exists and belongs to this doctor's session
  const { data: doc, error } = await supabase
    .from('temporary_documents')
    .select(`
      *,
      consultation_sessions!inner ( doctor_id, status )
    `)
    .eq('id', documentId)
    .single();

  if (error || !doc) {
    const err = new Error('Document not found');
    err.statusCode = 404;
    throw err;
  }

  // Check Authorization
  if (doc.consultation_sessions.doctor_id !== doctorId) {
    const err = new Error('Unauthorized to view this document');
    err.statusCode = 403;
    throw err;
  }

  // Even if completed, maybe the doctor needs 5 extra mins? For now, allow viewing if uploaded.
  
  // Generate presigned URL
  const url = await s3Service.generatePresignedUrl(doc.storage_key);
  return { url, document: doc };
};

const endSession = async (sessionId, doctorId) => {
  const supabase = getSupabase();

  // Validate ownership
  const { data: session, error: checkErr } = await supabase
    .from('consultation_sessions')
    .select('id, doctor_id, status')
    .eq('id', sessionId)
    .single();

  if (checkErr || !session || session.doctor_id !== doctorId) {
    const err = new Error('Session not found or unauthorized');
    err.statusCode = 403;
    throw err;
  }

  // Update status
  const { error: updateErr } = await supabase
    .from('consultation_sessions')
    .update({ status: 'COMPLETED' })
    .eq('id', sessionId);
    
  if (updateErr) throw updateErr;

  // Cleanup S3 files
  try {
    await s3Service.deleteSessionFolder(sessionId);
    
    // Mark DB docs as deleted
    await supabase
      .from('temporary_documents')
      .update({ status: 'DELETED' })
      .eq('session_id', sessionId);
  } catch (s3Err) {
    console.error('S3 Cleanup failed for session:', sessionId, s3Err);
    // Don't throw, session is already marked completed
  }

  return { success: true };
};

module.exports = {
  startSession,
  validateSessionToken,
  validateFallbackCode,
  uploadDocument,
  getDocumentUrl,
  endSession,
};
