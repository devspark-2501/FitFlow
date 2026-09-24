const express = require('express');
const router = express.Router();
const FoodLog = require('../models/FoodLog');

// POST: Save Food Log for Specific User
router.post('/food-logs', async (req, res) => {
  try {
    const { userId, foodName, calories, protein, fat, carbs, date } = req.body;

    if (!userId || !foodName) {
      return res.status(400).json({ error: 'User ID and food name are required' });
    }

    const newLog = new FoodLog({
      userId,
      foodName,
      calories,
      protein,
      fat,
      carbs,
      date: date || new Date().toISOString().split('T')[0]
    });

    await newLog.save();
    return res.status(201).json({ message: 'Food log saved successfully', log: newLog });
  } catch (error) {
    return res.status(500).json({ error: 'Server error saving food log' });
  }
});

// GET: Fetch Food Logs for Specific User
router.get('/food-logs', async (req, res) => {
  try {
    const { userId, date } = req.query;

    if (!userId) {
      return res.status(400).json({ error: 'User ID query parameter is required' });
    }

    const query = { userId };
    if (date) query.date = date;

    const logs = await FoodLog.find(query).sort({ createdAt: -1 });
    return res.status(200).json(logs);
  } catch (error) {
    return res.status(500).json({ error: 'Server error fetching food logs' });
  }
});

module.exports = router;