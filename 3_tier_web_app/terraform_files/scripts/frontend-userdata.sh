#!/bin/bash
# Install dependencies FIRST
sudo apt-get update
sudo apt-get install -y git nodejs npm nginx

# Clone frontend code - ADD YOUR ACTUAL GIT URL
git clone https://github.com/M-Yassir/todo-app.git
cd /todo-app/frontend

# Install and build React app
npm install
npm run build

# Copy built files to NGINX directory (FIXED THIS LINE)
sudo cp -r build/* /var/www/html/

sudo chown -R www-data:www-data /var/www/html/

# Configure NGINX with ALB DNS (FIXED root path)
sudo bash -c 'cat > /etc/nginx/sites-available/default << "EOF"
server {
    listen 80;
    root /var/www/html;
    index index.html;

    # Health check endpoint
    location /health {
        access_log off;
        add_header Content-Type text/plain;
        return 200 "Frontend Healthy\n";
    }

    # Serve React app - FIXED THIS PART
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests (leave empty for now)
    location /api/ {
        proxy_pass http://'"${backend_alb_dns}"';
        proxy_set_header Host $host;    
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF'

# Start NGINX
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Frontend is ready! NGINX configured to proxy to: ${backend_alb_dns}"