const hospitalService = require('../services/hospital.service');

/**
 * Controller to handle Hospital Registration POST requests
 */
const register = async (req, res, next) => {
  try {
    const result = await hospitalService.registerHospital(req.body);

    res.status(201).json({
      success: true,
      message: 'Hospital registration submitted successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Controller to handle Hospital Login POST requests
 */
const login = async (req, res, next) => {
  try {
    const { identifier, password } = req.body;
    const result = await hospitalService.loginHospital(identifier, password);

    res.status(200).json({
      success: true,
      message: 'Hospital authenticated successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Controller to handle check status GET requests
 */
const checkStatus = async (req, res, next) => {
  try {
    const result = await hospitalService.checkHospitalStatus(req.params.applicationId);

    res.status(200).json({
      success: true,
      message: 'Status fetched successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  checkStatus,
};
