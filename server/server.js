const express = require('express');
const cors = require('cors');
require('dotenv').config();
const connectDB = require('./config/db');

// Initialize App & DB
const app = express();
connectDB();

// Middleware
app.use(cors());
app.use(express.json());

// Base Route Test
app.get('/', (req, res) => {
  res.send('FitFlow API is running...');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));