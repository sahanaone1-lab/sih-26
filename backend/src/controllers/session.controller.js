const sessionService = require('../services/session.service');

const requestAccess = async (req, res, next) => {
  try {
    const { patientId, doctorId } = req.body;
    const result = await sessionService.requestDoctorAccess(patientId, doctorId);

    res.status(201).json({
      success: true,
      message: 'Access request created',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const approveAccess = async (req, res, next) => {
  try {
    const { sessionId, patientId } = req.body;
    const result = await sessionService.approveDoctorAccess(sessionId, patientId);

    res.status(200).json({
      success: true,
      message: 'Access approved for 90 minutes',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const verifyAccess = async (req, res, next) => {
  try {
    const { doctorId, rawToken } = req.body;
    const result = await sessionService.verifyDoctorAccess(doctorId, rawToken);

    res.status(200).json({
      success: true,
      message: 'Access verified',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  requestAccess,
  approveAccess,
  verifyAccess,
};
