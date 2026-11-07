/**
 * Domain model representing a notification item.
 */
class Notification {
  static VALID_TYPES = ['urgent', 'approved', 'shipping', 'guidelines', 'offer', 'info'];

  static validate(payload) {
    const errors = [];

    if (!payload.title || typeof payload.title !== 'string' || payload.title.trim().length === 0) {
      errors.push('Title is required.');
    }

    if (!payload.description || typeof payload.description !== 'string') {
      errors.push('Description is required.');
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }
}

module.exports = Notification;
