const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const foodRoutes = require('./routes/food');

const app = express();
app.use(express.json());
app.use(cors());

// Mount the route
app.use('/api', foodRoutes);

// Connect to Database & Start Server
mongoose.connect('mongodb://127.0.0.1:27017/fitflow_db')
  .then(() => {
    app.listen(5000, () => console.log('Backend server running on port 5000'));
  })
  .catch(err => console.error('DB Connection Error:', err));