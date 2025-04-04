// DOM Elements
const weatherForm = document.getElementById('weatherForm');
const cityInput = document.getElementById('cityInput');
const weatherInfo = document.getElementById('weatherInfo');
const loadingIndicator = document.getElementById('loadingIndicator');
const errorMessage = document.getElementById('errorMessage');

// Weather Info Elements
const cityName = document.getElementById('cityName');
const countryName = document.getElementById('countryName');
const temperature = document.getElementById('temperature');
const weatherDesc = document.getElementById('weatherDesc');
const feelsLike = document.getElementById('feelsLike');
const weatherIcon = document.getElementById('weatherIcon');
const windSpeed = document.getElementById('windSpeed');
const humidity = document.getElementById('humidity');
const pressure = document.getElementById('pressure');
const visibility = document.getElementById('visibility');

// Date and Time Elements
const currentDateElement = document.getElementById('currentDate');
const currentTimeElement = document.getElementById('currentTime');

// Update date and time
function updateDateTime() {
    const now = new Date();
    
    // Format date: Monday, March 9, 2025
    const dateOptions = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    currentDateElement.textContent = now.toLocaleDateString('en-US', dateOptions);
    
    // Format time: 10:30 AM
    const timeOptions = { hour: 'numeric', minute: 'numeric', hour12: true };
    currentTimeElement.textContent = now.toLocaleTimeString('en-US', timeOptions);
}

// Update date and time every second
setInterval(updateDateTime, 1000);
updateDateTime(); // Initial update

// Get weather data from our API endpoint
async function getWeatherData(city) {
    try {
        showLoading();
        
        // Fetch data from our server endpoint
        const response = await fetch(`/api/weather/${encodeURIComponent(city)}`);
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.message || 'Failed to fetch weather data');
        }
        
        const data = await response.json();
        
        // Display only the current weather data
        displayWeatherData(data.current);
        
        hideLoading();
        showWeatherInfo();
    } catch (error) {
        hideLoading();
        showError(error.message);
    }
}

// Display current weather data
function displayWeatherData(data) {
    // Set city and country
    cityName.textContent = data.name;
    countryName.textContent = data.sys.country;
    
    // Set temperature and feels like
    temperature.textContent = Math.round(data.main.temp);
    feelsLike.textContent = `Feels like: ${Math.round(data.main.feels_like)}°C`;
    
    // Set weather description
    weatherDesc.textContent = data.weather[0].description.charAt(0).toUpperCase() + 
                              data.weather[0].description.slice(1);
    
    // Set weather icon
    setWeatherIcon(weatherIcon, data.weather[0].id);
    
    // Set weather details
    windSpeed.textContent = `${data.wind.speed} m/s`;
    humidity.textContent = `${data.main.humidity}%`;
    pressure.textContent = `${data.main.pressure} hPa`;
    visibility.textContent = `${(data.visibility / 1000).toFixed(1)} km`;
}

// Set appropriate weather icon based on weather id
function setWeatherIcon(iconElement, weatherId) {
    iconElement.className = getWeatherIconClass(weatherId);
}

// Get Font Awesome icon class based on weather id
function getWeatherIconClass(weatherId) {
    // Weather codes: https://openweathermap.org/weather-conditions
    if (weatherId >= 200 && weatherId < 300) {
        return 'fas fa-bolt'; // Thunderstorm
    } else if (weatherId >= 300 && weatherId < 400) {
        return 'fas fa-cloud-rain'; // Drizzle
    } else if (weatherId >= 500 && weatherId < 600) {
        return 'fas fa-cloud-showers-heavy'; // Rain
    } else if (weatherId >= 600 && weatherId < 700) {
        return 'fas fa-snowflake'; // Snow
    } else if (weatherId >= 700 && weatherId < 800) {
        return 'fas fa-smog'; // Atmosphere (fog, mist, etc.)
    } else if (weatherId === 800) {
        return 'fas fa-sun'; // Clear sky
    } else if (weatherId >= 801 && weatherId < 804) {
        return 'fas fa-cloud-sun'; // Few/scattered clouds
    } else {
        return 'fas fa-cloud'; // Broken/overcast clouds
    }
}

// UI state functions
function showLoading() {
    loadingIndicator.classList.remove('hidden');
    weatherInfo.classList.add('hidden');
    errorMessage.classList.add('hidden');
}

function hideLoading() {
    loadingIndicator.classList.add('hidden');
}

function showWeatherInfo() {
    weatherInfo.classList.remove('hidden');
}

function showError(message) {
    errorMessage.querySelector('p').textContent = message || 'Unable to fetch weather data. Please check the city name and try again.';
    errorMessage.classList.remove('hidden');
}

// Event listener for form submission
weatherForm.addEventListener('submit', function(e) {
    e.preventDefault();
    const city = cityInput.value.trim();
    
    if (city) {
        getWeatherData(city);
    }
});

// Initialize the app - can set default city or leave blank
function initApp() {
    // Optional: Set a default city when the app loads
    // getWeatherData('London');
}

// Start the app
initApp();