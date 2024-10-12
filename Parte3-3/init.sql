CREATE TABLE weather_data (
    id SERIAL PRIMARY KEY,
    city VARCHAR(50),
    description VARCHAR(100),
    temperature DECIMAL(5, 2),
    humidity INT,
    wind_speed DECIMAL(5, 2),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
