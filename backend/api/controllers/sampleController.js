const store = require('../../database/mockStore');
const Sample = require('../models/Sample');

class SampleController {
  /**
   * GET /api/samples
   * Query params: ?status=... &category=... &search=...
   */
  async getSamples(req, res, next) {
    try {
      const { status, category, search } = req.query;
      const samples = await store.getAllSamples({ status, category, search });
      return res.status(200).json(samples);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/samples/:id
   */
  async getSampleById(req, res, next) {
    try {
      const { id } = req.params;
      const sample = await store.getSampleById(id);
      if (!sample) {
        return res.status(404).json({
          success: false,
          message: `Sample with ID ${id} not found.`,
        });
      }
      return res.status(200).json(sample);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/samples
   */
  async createSample(req, res, next) {
    try {
      const validation = Sample.validate(req.body);
      if (!validation.isValid) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: validation.errors,
        });
      }

      const created = await store.createSample(req.body);
      return res.status(201).json(created);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/samples/:id/status
   */
  async updateSampleStatus(req, res, next) {
    try {
      const { id } = req.params;
      const validation = Sample.validate(req.body, true);
      if (!validation.isValid) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: validation.errors,
        });
      }

      const updated = await store.updateSampleStatus(id, req.body);
      if (!updated) {
        return res.status(404).json({
          success: false,
          message: `Sample with ID ${id} not found.`,
        });
      }

      return res.status(200).json(updated);
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/samples/:id
   */
  async deleteSample(req, res, next) {
    try {
      const { id } = req.params;
      const deleted = await store.deleteSample(id);
      if (!deleted) {
        return res.status(404).json({
          success: false,
          message: `Sample with ID ${id} not found.`,
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Sample deleted successfully.',
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new SampleController();
