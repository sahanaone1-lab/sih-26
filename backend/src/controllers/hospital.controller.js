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

module.exports = {
  register,
};
