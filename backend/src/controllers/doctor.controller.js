const doctorService = require('../services/doctor.service');

const register = async (req, res, next) => {
  try {
    const result = await doctorService.registerDoctor(req.body);

    res.status(201).json({
      success: true,
      message: 'Doctor registered successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await doctorService.loginDoctor(email, password);

    res.status(200).json({
      success: true,
      message: 'Doctor authenticated successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const getDoctorsByHospital = async (req, res, next) => {
  try {
    const { hospitalId } = req.params;
    const result = await doctorService.getDoctorsByHospital(hospitalId);

    res.status(200).json({
      success: true,
      message: 'Doctors retrieved successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const uploadConsultation = async (req, res, next) => {
  try {
    const { doctorId, rawToken, patientId, title, notes } = req.body;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ success: false, message: 'Document file is required' });
    }

    const result = await doctorService.uploadConsultation(doctorId, rawToken, patientId, file, title, notes);

    res.status(201).json({
      success: true,
      message: 'Consultation document uploaded securely',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  getDoctorsByHospital,
  uploadConsultation,
};
