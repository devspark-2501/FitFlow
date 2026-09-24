const mongoose = require('mongoose');

const foodLogSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  foodName: { type: String, required: true },
  calories: { type: Number, required: true },
  protein: { type: Number, required: true },
  fat: { type: Number, required: true },
  carbs: { type: Number, required: true },
  date: { type: String, required: true } // YYYY-MM-DD
}, { timestamps: true });

module.exports = mongoose.model('FoodLog', foodLogSchema);