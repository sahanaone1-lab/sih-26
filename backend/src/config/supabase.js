const { createClient } = require('@supabase/supabase-js');
const env = require('./env');

const isConfigured = Boolean(
  env.supabaseUrl &&
  env.supabaseServiceRoleKey &&
  env.supabaseUrl.startsWith('http')
);

let supabase = null;

if (isConfigured) {
  supabase = createClient(env.supabaseUrl, env.supabaseServiceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Returns the initialized Supabase client or throws a descriptive error
 */
const getSupabase = () => {
  if (!supabase) {
    throw new Error(
      'Supabase client is not initialized. Please provide valid SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env'
    );
  }
  return supabase;
};

module.exports = {
  supabase,
  getSupabase,
  isSupabaseConfigured: isConfigured,
};
