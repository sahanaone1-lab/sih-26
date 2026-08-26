/**
 * Verification Status Constants & Transition Matrix
 */

const VerificationStatus = {
  PENDING: 'pending',
  UNDER_REVIEW: 'under_review',
  VERIFIED: 'verified',
  REJECTED: 'rejected',
};

/**
 * Permitted status transitions map:
 * pending -> under_review, rejected
 * under_review -> verified, rejected
 * verified -> terminal (no transitions)
 * rejected -> terminal (no transitions unless formal re-apply is initiated)
 */
const ALLOWED_TRANSITIONS = {
  [VerificationStatus.PENDING]: [VerificationStatus.UNDER_REVIEW, VerificationStatus.REJECTED],
  [VerificationStatus.UNDER_REVIEW]: [VerificationStatus.VERIFIED, VerificationStatus.REJECTED],
  [VerificationStatus.VERIFIED]: [],
  [VerificationStatus.REJECTED]: [],
};

const isValidTransition = (currentStatus, targetStatus) => {
  if (!currentStatus || !targetStatus) return false;
  const allowedNextStatuses = ALLOWED_TRANSITIONS[currentStatus] || [];
  return allowedNextStatuses.includes(targetStatus);
};

module.exports = {
  VerificationStatus,
  ALLOWED_TRANSITIONS,
  isValidTransition,
};
