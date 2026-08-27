const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patient.controller');

/**
 * @route   POST /api/patient/auth/register
 * @desc    Register a new patient
 * @access  Public
 */
router.post('/auth/register', patientController.register);

/**
 * @route   POST /api/patient/auth/login
 * @desc    Authenticate a patient
 * @access  Public
 */
router.post('/auth/login', patientController.login);

const upload = require('../middleware/upload.middleware');
const auditLog = require('../middleware/audit.middleware');

/**
 * @route   POST /api/patient/records
 * @desc    Upload a medical record
 * @access  Public (should be protected in prod)
 */
router.post(
  '/records',
  upload.single('document'),
  auditLog('PATIENT_UPLOAD_RECORD'),
  patientController.uploadRecord
);

module.exports = router;
