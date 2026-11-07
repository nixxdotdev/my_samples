const store = require('../../database/mockStore');

class AnalyticsController {
  /**
   * GET /api/analytics/summary
   */
  async getSummary(req, res, next) {
    try {
      const summary = await store.getAnalyticsSummary();
      return res.status(200).json(summary);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AnalyticsController();
