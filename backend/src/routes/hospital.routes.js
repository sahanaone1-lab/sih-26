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

module.exports = router;
