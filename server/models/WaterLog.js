const mongoose = require('mongoose');

const waterLogSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  amount: {
    type: Number,
    required: true
  },
  date: {
    type: String, // Format: YYYY-MM-DD
    required: true,
    index: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('WaterLog', waterLogSchema);