const { getSupabase } = require('../config/supabase');
const { VerificationStatus, isValidTransition } = require('../utils/verificationStatus');

/**
 * Lists hospitals with filtering, multi-field search, and pagination
 */
const listHospitals = async ({ status, search, page = 1, limit = 20 }) => {
  const supabase = getSupabase();
  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));
  const from = (pageNum - 1) * limitNum;
  const to = from + limitNum - 1;

  let query = supabase
    .from('hospitals')
    .select('*, hospital_officials(full_name, designation, official_email, official_phone, is_primary)', {
      count: 'exact',
    });

  // Filter by status if provided
  if (status && Object.values(VerificationStatus).includes(status.toLowerCase())) {
    query = query.eq('verification_status', status.toLowerCase());
  }

  // Search by name, application ID, registration number, or HFR ID
  if (search && typeof search === 'string' && search.trim().length > 0) {
    const s = search.trim();
    query = query.or(
      `facility_name.ilike.%${s}%,application_id.ilike.%${s}%,registration_number.ilike.%${s}%,hfr_id.ilike.%${s}%,state.ilike.%${s}%,district.ilike.%${s}%`
    );
  }

  query = query.order('created_at', { ascending: false }).range(from, to);

  const { data, count, error } = await query;

  if (error) {
    throw error;
  }

  const total = count || 0;
  const totalPages = Math.ceil(total / limitNum);

  return {
    data: data || [],
    pagination: {
      page: pageNum,
      limit: limitNum,
      total,
      total_pages: totalPages,
    },
  };
};

/**
 * Returns pending hospitals awaiting verification
 */
const getPendingHospitals = async ({ page = 1, limit = 20 }) => {
  return listHospitals({ status: VerificationStatus.PENDING, page, limit });
};

/**
 * Returns complete details of a single hospital including officials, documents, and audit history
 */
const getHospitalDetails = async (hospitalId) => {
  const supabase = getSupabase();

  // Find by UUID or by application_id
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(hospitalId);

  let hospitalQuery = supabase.from('hospitals').select('*');
  if (isUuid) {
    hospitalQuery = hospitalQuery.eq('id', hospitalId);
  } else {
    hospitalQuery = hospitalQuery.eq('application_id', hospitalId.trim().toUpperCase());
  }

  const { data: hospital, error: hospitalError } = await hospitalQuery.maybeSingle();

  if (hospitalError) {
    throw hospitalError;
  }

  if (!hospital) {
    const notFoundError = new Error('Hospital not found');
    notFoundError.statusCode = 404;
    throw notFoundError;
  }

  // Fetch related officials
  const { data: officials, error: officialsError } = await supabase
    .from('hospital_officials')
    .select('*')
    .eq('hospital_id', hospital.id)
    .order('is_primary', { ascending: false });

  if (officialsError) {
    throw officialsError;
  }

  // Fetch related documents metadata
  const { data: documents, error: documentsError } = await supabase
    .from('hospital_documents')
    .select('*')
    .eq('hospital_id', hospital.id)
    .order('uploaded_at', { ascending: false });

  if (documentsError) {
    throw documentsError;
  }

  // Fetch complete verification history audit trail
  const { data: history, error: historyError } = await supabase
    .from('hospital_verification_history')
    .select('*')
    .eq('hospital_id', hospital.id)
    .order('created_at', { ascending: true });

  if (historyError) {
    throw historyError;
  }

  return {
    ...hospital,
    authorized_officials: officials || [],
    documents: documents || [],
    verification_history: history || [],
  };
};

/**
 * Performs a validated status transition and creates an immutable audit history log
 */
const updateHospitalStatus = async (hospitalId, targetStatus, { reason, notes, adminId } = {}) => {
  const supabase = getSupabase();

  // 1. Fetch current hospital status
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(hospitalId);
  let hospitalQuery = supabase.from('hospitals').select('id, application_id, facility_name, verification_status');

  if (isUuid) {
    hospitalQuery = hospitalQuery.eq('id', hospitalId);
  } else {
    hospitalQuery = hospitalQuery.eq('application_id', hospitalId.trim().toUpperCase());
  }

  const { data: hospital, error: fetchError } = await hospitalQuery.maybeSingle();

  if (fetchError) {
    throw fetchError;
  }

  if (!hospital) {
    const error = new Error('Hospital not found');
    error.statusCode = 404;
    throw error;
  }

  // 2. Validate status transition against rules
  const currentStatus = hospital.verification_status;
  if (!isValidTransition(currentStatus, targetStatus)) {
    const error = new Error(`Invalid verification status transition from '${currentStatus}' to '${targetStatus}'`);
    error.statusCode = 409;
    throw error;
  }

  // 3. Prepare update payload
  const updatePayload = {
    verification_status: targetStatus,
  };

  if (targetStatus === VerificationStatus.VERIFIED) {
    updatePayload.rejection_reason = null;
    updatePayload.verified_at = new Date().toISOString();
  } else if (targetStatus === VerificationStatus.REJECTED) {
    if (!reason || typeof reason !== 'string' || reason.trim().length === 0) {
      const error = new Error('Rejection reason is required');
      error.statusCode = 400;
      throw error;
    }
    updatePayload.rejection_reason = reason.trim();
  }

  // 4. Update hospital status
  const { data: updatedHospital, error: updateError } = await supabase
    .from('hospitals')
    .update(updatePayload)
    .eq('id', hospital.id)
    .select('id, application_id, facility_name, verification_status, rejection_reason, verified_at')
    .single();

  if (updateError) {
    throw updateError;
  }

  // 5. Determine action name
  let actionName = 'status_updated';
  if (targetStatus === VerificationStatus.UNDER_REVIEW) {
    actionName = 'moved_to_under_review';
  } else if (targetStatus === VerificationStatus.VERIFIED) {
    actionName = 'hospital_approved';
  } else if (targetStatus === VerificationStatus.REJECTED) {
    actionName = 'hospital_rejected';
  }

  // 6. Record immutable verification audit history
  const { error: historyError } = await supabase
    .from('hospital_verification_history')
    .insert({
      hospital_id: hospital.id,
      previous_status: currentStatus,
      new_status: targetStatus,
      action: actionName,
      rejection_reason: targetStatus === VerificationStatus.REJECTED ? reason.trim() : null,
      notes: notes || (targetStatus === VerificationStatus.VERIFIED ? 'Hospital verified by administrator' : null),
      admin_auth_user_id: adminId || null,
    });

  if (historyError) {
    console.error('Warning: Failed to insert verification history log:', historyError.message);
  }

  return {
    hospital_id: updatedHospital.id,
    application_id: updatedHospital.application_id,
    facility_name: updatedHospital.facility_name,
    verification_status: updatedHospital.verification_status,
    rejection_reason: updatedHospital.rejection_reason,
    verified_at: updatedHospital.verified_at,
  };
};

module.exports = {
  listHospitals,
  getPendingHospitals,
  getHospitalDetails,
  updateHospitalStatus,
};
