const { getSupabase } = require('../config/supabase');

const auditLog = (action) => {
  return async (req, res, next) => {
    // Capture the original send to intercept the response status code
    const originalSend = res.send;

    res.send = function (body) {
      res.send = originalSend;

      // Extract details
      const patientId = req.body.patientId || req.user?.id || null;
      const doctorId = req.body.doctorId || req.doctor?.id || null;
      const statusCode = res.statusCode;
      const ipAddress = req.ip || req.connection.remoteAddress;
      
      const supabase = getSupabase();

      // Fire and forget logging
      supabase.from('audit_logs').insert({
        action: action,
        patient_id: patientId,
        doctor_id: doctorId,
        resource_accessed: req.originalUrl,
        ip_address: ipAddress,
        status: statusCode >= 200 && statusCode < 300 ? 'SUCCESS' : 'FAILURE',
        details: body,
      }).then(({ error }) => {
        if (error) {
          console.error('Failed to write audit log:', error);
        }
      });

      return res.send(body);
    };

    next();
  };
};

module.exports = auditLog;
