/**
 * Domain model representing a creator sample request.
 */
class Sample {
  static VALID_STATUSES = ['pendingApproval', 'approved', 'pendingCriteria'];

  static VALID_CATEGORIES = [
    'Electronics & Audio',
    'Beauty & Skincare',
    'Apparel & Fashion',
    'Home & Kitchen',
    'Gadgets & Fitness',
    'Computer & Office',
    'Creator Studio Gear',
    'Accessories & Travel',
    'Mobile & Tech',
    'Personal Care',
  ];

  static validate(payload, isUpdate = false) {
    const errors = [];

    if (!isUpdate || payload.title !== undefined) {
      if (!payload.title || typeof payload.title !== 'string' || payload.title.trim().length === 0) {
        errors.push('Title is required and must be a non-empty string.');
      }
    }

    if (payload.status !== undefined) {
      if (!this.VALID_STATUSES.includes(payload.status)) {
        errors.push(`Status must be one of: ${this.VALID_STATUSES.join(', ')}.`);
      }
    }

    if (payload.remainingDays !== undefined) {
      const days = Number(payload.remainingDays);
      if (isNaN(days) || days < 0) {
        errors.push('remainingDays must be a non-negative number.');
      }
    }

    if (payload.totalDays !== undefined) {
      const days = Number(payload.totalDays);
      if (isNaN(days) || days < 0) {
        errors.push('totalDays must be a non-negative number.');
      }
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }
}

module.exports = Sample;
