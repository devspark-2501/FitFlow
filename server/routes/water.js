const express = require('express');
const router = express.Router();
const WaterLog = require('../models/WaterLog');

// @route   POST /api/water/add
// @desc    Add a new water intake log
router.post('/add', async (req, res) => {
  try {
    const { userId, amount, date } = req.body;

    if (!userId || !amount) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const todayDateStr = date || new Date().toISOString().split('T')[0];

    const newLog = new WaterLog({
      userId,
      amount,
      date: todayDateStr,
      timestamp: new Date()
    });

    await newLog.save();

    res.status(201).json({
      success: true,
      message: 'Water log saved successfully',
      log: newLog
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// @route   GET /api/water/:userId/:date
// @desc    Get total intake and logs for today
router.get('/:userId/:date', async (req, res) => {
  try {
    const { userId, date } = req.params;

    const logs = await WaterLog.find({ userId, date }).sort({ timestamp: 1 });

    const totalIntake = logs.reduce((acc, log) => acc + log.amount, 0);

    res.status(200).json({
      success: true,
      totalIntake,
      logs
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

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

    // Generate date keys for past N days
    for (let i = 0; i < days; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      historyMap[dateStr] = 0;
    }

    // Aggregate totals
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