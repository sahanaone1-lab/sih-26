const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctor.controller');

/**
 * @route   POST /api/doctor/auth/register
 * @desc    Register a new doctor
 * @access  Public
 */
router.post('/auth/register', doctorController.register);

/**
 * @route   POST /api/doctor/auth/login
 * @desc    Authenticate a doctor
 * @access  Public
 */
router.post('/auth/login', doctorController.login);

const upload = require('../middleware/upload.middleware');
const auditLog = require('../middleware/audit.middleware');

/**
 * @route   POST /api/doctor/consultations
 * @desc    Upload consultation documents (requires active session token)
 * @access  Public (protected logically by token)
 */
router.post(
  '/consultations',
  upload.single('document'),
  auditLog('DOCTOR_UPLOAD_CONSULTATION'),
  doctorController.uploadConsultation
);

module.exports = router;
