-- Create a database (optional, if not already created)
CREATE DATABASE IF NOT EXISTS sample_db;

-- Use the database
USE sample_db;

-- Create a table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some data
INSERT INTO users (username, email) VALUES 
('gayatri', 'gayatri@example.com'),
('nareshit', 'nareshit@example.com'),
('devops', 'devops@example.com');

-- Query the table
SELECT * FROM users;