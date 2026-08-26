const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const requireAdmin = require('../middleware/adminAuth.middleware');
const validate = require('../middleware/validation.middleware');
const { validateRejection } = require('../validators/admin.validator');

// All admin routes use the development admin authentication middleware
router.use(requireAdmin);

/**
 * @route   GET /api/admin/hospitals/pending
 * @desc    List pending hospital applications
 */
router.get('/hospitals/pending', adminController.getPendingHospitals);

/**
 * @route   GET /api/admin/hospitals
 * @desc    List all hospitals with status filter, search, and pagination
 */
router.get('/hospitals', adminController.getHospitals);

/**
 * @route   GET /api/admin/hospitals/:hospitalId
 * @desc    Get complete hospital profile, officials, documents, and verification history
 */
router.get('/hospitals/:hospitalId', adminController.getHospitalById);

/**
 * @route   PATCH /api/admin/hospitals/:hospitalId/under-review
 * @desc    Move hospital verification status from 'pending' to 'under_review'
 */
router.patch('/hospitals/:hospitalId/under-review', adminController.markUnderReview);

/**
 * @route   PATCH /api/admin/hospitals/:hospitalId/approve
 * @desc    Approve hospital registration (status becomes 'verified')
 */
router.patch('/hospitals/:hospitalId/approve', adminController.approveHospital);

/**
 * @route   PATCH /api/admin/hospitals/:hospitalId/reject
 * @desc    Reject hospital registration with required reason
 */
router.patch('/hospitals/:hospitalId/reject', validate(validateRejection), adminController.rejectHospital);

module.exports = router;
