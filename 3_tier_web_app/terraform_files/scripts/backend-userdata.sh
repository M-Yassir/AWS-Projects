#!/bin/bash
# Update system and install dependencies FIRST
sudo apt-get update
apt-get install -y curl
sudo apt install -y netcat
apt-get remove nodejs npm -y --purge
sudo apt-get install -y git

# Install Node.js 18.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Clone the backend code
git clone https://github.com/M-Yassir/todo-app.git
cd /todo-app/backend

# Change ownership to ubuntu user
sudo chown -R ubuntu:ubuntu /todo-app/backend

# Install Node.js dependencies
sudo npm install

# Create environment file (but don't start yet)
cat > .env << EOF
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
PORT=3001
JWT_SECRET=your-super-secret-key
EOF

echo "Database connected! Initializing database schema..."

# Initialize database tables
sudo apt install mysql-client-core-8.0

mysql -h ${db_host} -u ${db_username} -p${db_password} << EOF
CREATE DATABASE IF NOT EXISTS ${db_name};
USE ${db_name};

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    text VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
EOF

echo "Database schema initialized! Starting backend service..."

# Create and enable systemd service
sudo bash -c 'cat > /etc/systemd/system/nodejs-backend.service << EOF
[Unit]
Description=Node.js Backend Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/todo-app/backend
Environment=NODE_ENV=production
Environment=PORT=3001
ExecStart=sudo /usr/bin/npm start
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable nodejs-backend.service
sudo systemctl start nodejs-backend.service

echo "Node.js backend service started and enabled!"
