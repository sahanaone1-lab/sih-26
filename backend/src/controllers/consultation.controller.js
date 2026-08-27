const consultationService = require('../services/consultation.service');

const startSession = async (req, res, next) => {
  try {
    const { hospitalId, doctorId } = req.body;
    
    // Require admin or kiosk authorization for this in real app, skipping strict auth for MVP demo
    const result = await consultationService.startSession(hospitalId, doctorId);

    res.status(201).json({
      success: true,
      message: 'Consultation session started',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const validateToken = async (req, res, next) => {
  try {
    const { token } = req.query;
    if (!token) {
      return res.status(400).json({ success: false, message: 'Token is required' });
    }

    const result = await consultationService.validateSessionToken(token);

    res.status(200).json({
      success: true,
      message: 'Token is valid',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const validateFallback = async (req, res, next) => {
  try {
    const { code } = req.query;
    if (!code) {
      return res.status(400).json({ success: false, message: 'Fallback code is required' });
    }

    const result = await consultationService.validateFallbackCode(code.toUpperCase());

    res.status(200).json({
      success: true,
      message: 'Fallback code is valid',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const uploadDocument = async (req, res, next) => {
  try {
    const { token } = req.body;
    const file = req.file;

    if (!token) return res.status(400).json({ success: false, message: 'Token is required' });
    if (!file) return res.status(400).json({ success: false, message: 'Document file is required' });

    // Validate size manually if multer didn't catch it
    if (file.size > 10 * 1024 * 1024) {
      return res.status(400).json({ success: false, message: 'File too large. Max 10MB.' });
    }

    const result = await consultationService.uploadDocument(token, file);

    // Emit Socket.IO event to the doctor's room
    const io = req.app.get('io');
    if (io) {
      io.to(`session_${result.session_id}`).emit('document_uploaded', {
        document: result.document
      });
    }

    res.status(201).json({
      success: true,
      message: 'Document uploaded securely',
      data: result.document,
    });
  } catch (error) {
    next(error);
  }
};

const getDocument = async (req, res, next) => {
  try {
    const { documentId } = req.params;
    const { doctorId } = req.query; // Should come from JWT auth middleware ideally

    if (!doctorId) {
      return res.status(401).json({ success: false, message: 'Doctor ID is required for access' });
    }

    const result = await consultationService.getDocumentUrl(documentId, doctorId);

    res.status(200).json({
      success: true,
      message: 'Pre-signed URL generated',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const endSession = async (req, res, next) => {
  try {
    const { sessionId, doctorId } = req.body;
    
    if (!sessionId || !doctorId) {
      return res.status(400).json({ success: false, message: 'Session ID and Doctor ID required' });
    }

    const result = await consultationService.endSession(sessionId, doctorId);

    // Notify room
    const io = req.app.get('io');
    if (io) {
      io.to(`session_${sessionId}`).emit('consultation_ended', { sessionId });
    }

    res.status(200).json({
      success: true,
      message: 'Session ended and files cleaned up',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  startSession,
  validateToken,
  validateFallback,
  uploadDocument,
  getDocument,
  endSession,
};
