/**
 * Validator for Admin operations
 */

const validateRejection = (data) => {
  const errors = [];

  if (!data.reason || typeof data.reason !== 'string' || data.reason.trim().length < 5) {
    errors.push('Rejection reason is required and must be at least 5 characters long.');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

module.exports = {
  validateRejection,
};
