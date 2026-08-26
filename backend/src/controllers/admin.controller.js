const adminService = require('../services/admin.service');
const { VerificationStatus } = require('../utils/verificationStatus');

/**
 * Controller for Admin Hospital Verification operations
 */

const getHospitals = async (req, res, next) => {
  try {
    const result = await adminService.listHospitals(req.query);
    res.status(200).json({
      success: true,
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
};

const getPendingHospitals = async (req, res, next) => {
  try {
    const result = await adminService.getPendingHospitals(req.query);
    res.status(200).json({
      success: true,
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
};

const getHospitalById = async (req, res, next) => {
  try {
    const hospital = await adminService.getHospitalDetails(req.params.hospitalId);
    res.status(200).json({
      success: true,
      data: hospital,
    });
  } catch (error) {
    next(error);
  }
};

const markUnderReview = async (req, res, next) => {
  try {
    const result = await adminService.updateHospitalStatus(
      req.params.hospitalId,
      VerificationStatus.UNDER_REVIEW,
      { adminId: req.admin?.id }
    );

    res.status(200).json({
      success: true,
      message: 'Hospital moved to under review',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const approveHospital = async (req, res, next) => {
  try {
    const result = await adminService.updateHospitalStatus(
      req.params.hospitalId,
      VerificationStatus.VERIFIED,
      {
        adminId: req.admin?.id,
        notes: req.body?.notes,
      }
    );

    res.status(200).json({
      success: true,
      message: 'Hospital approved successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const rejectHospital = async (req, res, next) => {
  try {
    const result = await adminService.updateHospitalStatus(
      req.params.hospitalId,
      VerificationStatus.REJECTED,
      {
        reason: req.body.reason,
        notes: req.body?.notes,
        adminId: req.admin?.id,
      }
    );

    res.status(200).json({
      success: true,
      message: 'Hospital registration rejected',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getHospitals,
  getPendingHospitals,
  getHospitalById,
  markUnderReview,
  approveHospital,
  rejectHospital,
};
