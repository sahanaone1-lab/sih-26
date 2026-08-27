const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/session.controller');

/**
 * @route   POST /api/sessions/request
 * @desc    Request doctor access (generates QR token)
 * @access  Public
 */
router.post('/request', sessionController.requestAccess);

/**
 * @route   POST /api/sessions/approve
 * @desc    Patient approves doctor access (starts 90 min timer)
 * @access  Public
 */
router.post('/approve', sessionController.approveAccess);

/**
 * @route   POST /api/sessions/verify
 * @desc    Doctor verifies access token
 * @access  Public
 */
router.post('/verify', sessionController.verifyAccess);

module.exports = router;
