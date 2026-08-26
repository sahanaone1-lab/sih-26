const env = require('../config/env');

/**
 * Temporary Development Admin Authentication Middleware
 * Injects admin context for development/testing prior to full Supabase RBAC integration.
 * NOTE: Strictly isolated for development mode.
 */
const requireAdmin = (req, res, next) => {
  // In development mode, provide a mock admin identity context
  if (env.nodeEnv === 'development' || !env.isProduction) {
    req.admin = {
      id: req.headers['x-admin-id'] || null,
      role: 'system_admin',
      name: 'National AYUSH Verification Officer',
    };
    return next();
  }

  // In production, real Supabase JWT token verification will be required
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized: Admin authentication token required',
    });
  }

  next();
};

module.exports = requireAdmin;
