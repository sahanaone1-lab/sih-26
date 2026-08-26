const express = require('express');
const router = express.Router();
const { isSupabaseConfigured, getSupabase } = require('../config/supabase');

/**
 * @route   GET /health
 * @desc    Main health check reporting Express status and Supabase configuration state
 * @access  Public
 */
router.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'MediKiosk backend is running',
    services: {
      backend: 'ok',
      supabase: isSupabaseConfigured ? 'configured' : 'not_configured',
    },
    timestamp: new Date().toISOString(),
  });
});

/**
 * @route   GET /health/supabase-test
 * @desc    Temporary verification endpoint to test live connection to Supabase instance
 * @access  Public
 */
router.get('/supabase-test', async (req, res, next) => {
  try {
    if (!isSupabaseConfigured) {
      return res.status(503).json({
        success: false,
        message: 'Supabase credentials are not configured. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env',
        services: {
          backend: 'ok',
          supabase: 'not_configured',
        },
      });
    }

    const supabase = getSupabase();

    // Perform a lightweight admin verification call against Supabase Auth service
    const { data, error } = await supabase.auth.admin.listUsers({ page: 1, perPage: 1 });

    if (error) {
      return res.status(502).json({
        success: false,
        message: 'Failed to connect to Supabase instance',
        error: error.message,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Supabase connection verified successfully',
      services: {
        backend: 'ok',
        supabase: 'connected',
      },
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
