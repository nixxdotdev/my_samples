const store = require('../../database/mockStore');

class NotificationController {
  /**
   * GET /api/notifications
   */
  async getNotifications(req, res, next) {
    try {
      const notifications = await store.getAllNotifications();
      return res.status(200).json(notifications);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/notifications/:id/read
   */
  async markAsRead(req, res, next) {
    try {
      const { id } = req.params;
      const updated = await store.markNotificationRead(id);
      if (!updated) {
        return res.status(404).json({
          success: false,
          message: `Notification with ID ${id} not found.`,
        });
      }
      return res.status(200).json(updated);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/notifications/read-all
   */
  async markAllAsRead(req, res, next) {
    try {
      await store.markAllNotificationsRead();
      return res.status(200).json({
        success: true,
        message: 'All notifications marked as read.',
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new NotificationController();
