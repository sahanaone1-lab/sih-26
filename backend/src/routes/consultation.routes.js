const express = require('express');
const router = express.Router();
const multer = require('multer');
const consultationController = require('../controllers/consultation.controller');

// Multer in-memory storage configuration
const storage = multer.memoryStorage();
const upload = multer({ 
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    // Allow PDFs and Images
    if (file.mimetype === 'application/pdf' || file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only PDF and Image files are allowed'));
    }
  }
});

/**
 * @route   POST /api/consultations/start
 * @desc    Start a temporary consultation session (generates QR token)
 * @access  Public (for Kiosk)
 */
router.post('/start', consultationController.startSession);

/**
 * @route   GET /api/consultations/validate
 * @desc    Validate a QR token
 * @access  Public (for Patient Upload Portal)
 */
router.get('/validate', consultationController.validateToken);

/**
 * @route   GET /api/consultations/validate-fallback
 * @desc    Validate a fallback code and return the session info
 * @access  Public (for Patient App or Web)
 */
router.get('/validate-fallback', consultationController.validateFallback);

/**
 * @route   POST /api/consultations/upload
 * @desc    Upload document to temporary S3 session storage
 * @access  Public (for Patient Upload Portal)
 */
router.post('/upload', upload.single('document'), consultationController.uploadDocument);

/**
 * @route   GET /api/consultations/documents/:documentId
 * @desc    Get pre-signed URL for a document
 * @access  Public (Doctor Dashboard - needs doctorId query param)
 */
router.get('/documents/:documentId', consultationController.getDocument);

/**
 * @route   POST /api/consultations/end
 * @desc    End session and delete temporary documents from S3
 * @access  Public (Doctor Dashboard)
 */
router.post('/end', consultationController.endSession);

module.exports = router;
