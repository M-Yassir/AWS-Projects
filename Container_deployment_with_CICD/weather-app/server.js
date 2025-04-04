const express = require('express');
const axios = require('axios');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// API Key from environment variables
const API_KEY = process.env.OPENWEATHER_API_KEY;

// Weather API endpoints
app.get('/api/weather/:city', async (req, res) => {
    try {
        const city = req.params.city;
        
        // Get current weather only
        const weatherResponse = await axios.get(
            `https://api.openweathermap.org/data/2.5/weather?q=${city}&units=metric&appid=${API_KEY}`
        );
        
        // Send only the current weather data
        res.json({
            current: weatherResponse.data
        });
    } catch (error) {
        console.error('Error fetching weather data:', error.message);
        
        // Send appropriate error response
        if (error.response && error.response.status === 404) {
            return res.status(404).json({ message: 'City not found' });
        }
        
        res.status(500).json({ message: 'Error fetching weather data' });
    }
});

// Serve the main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});