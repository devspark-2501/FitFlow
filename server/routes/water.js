const express = require('express');
const router = express.Router();
const WaterLog = require('../models/WaterLog');

// @route   GET /api/water/history/:userId
// @desc    Get aggregated water intake totals for the past N days
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const days = parseInt(req.query.days) || 7;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - (days - 1));

    const logs = await WaterLog.find({
      userId,
      timestamp: { $gte: startDate }
    }).sort({ timestamp: 1 });

    const historyMap = {};

    // Generate date map keys
    for (let i = 0; i < days; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      historyMap[dateStr] = 0;
    }

    // Populate actual totals
    logs.forEach(log => {
      if (historyMap[log.date] !== undefined) {
        historyMap[log.date] += log.amount;
      }
    });

    res.status(200).json({
      success: true,
      data: historyMap
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;