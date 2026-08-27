const patientService = require('../services/patient.service');

const register = async (req, res, next) => {
  try {
    const result = await patientService.registerPatient(req.body);

    res.status(201).json({
      success: true,
      message: 'Patient registered successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await patientService.loginPatient(email, password);

    res.status(200).json({
      success: true,
      message: 'Patient authenticated successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

const uploadRecord = async (req, res, next) => {
  try {
    const { patientId, documentType, title, medicalDate } = req.body;
    const file = req.file;

    const result = await patientService.uploadMedicalDocument(patientId, file, documentType, title, medicalDate);

    res.status(201).json({
      success: true,
      message: 'Document uploaded successfully',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  uploadRecord,
};
