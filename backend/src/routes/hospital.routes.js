const express = require('express');
const router = express.Router();
const hospitalController = require('../controllers/hospital.controller');
const validate = require('../middleware/validation.middleware');
const { validateHospitalRegistration } = require('../validators/hospital.validator');

/**
 * @route   POST /api/hospitals/register
 * @desc    Submit a new AYUSH hospital registration for verification
 * @access  Public
 */
router.post('/register', validate(validateHospitalRegistration), hospitalController.register);

/**
 * @route   POST /api/hospitals/login
 * @desc    Authenticate an AYUSH hospital
 * @access  Public
 */
router.post('/login', hospitalController.login);

/**
 * @route   GET /api/hospitals/status/:applicationId
 * @desc    Check verification status of an AYUSH hospital
 * @access  Public
 */
router.get('/status/:applicationId', hospitalController.checkStatus);

module.exports = router;
