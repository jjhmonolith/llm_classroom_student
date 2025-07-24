#!/bin/bash

echo "🔧 Fixing dev.llmclass.org redirect issue..."

# Check current site configurations
echo "📋 Current enabled sites:"
ls -la /etc/nginx/sites-enabled/

# Remove conflicting configurations that might cause redirects
echo "🗑️ Removing potential conflicting configurations..."
sudo rm -f /etc/nginx/sites-enabled/llm-classroom-student
sudo rm -f /etc/nginx/sites-enabled/strategic-llmclass
sudo rm -f /etc/nginx/sites-enabled/rtcf-llmclass

# Create clean Student Hub configuration with highest priority
echo "📝 Creating Student Hub configuration..."
sudo tee /etc/nginx/sites-available/00-student-hub > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name dev.llmclass.org;

    root /var/www/llm-classroom-student;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
        
        add_header Cache-Control "public, max-age=3600";
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header 'Access-Control-Allow-Origin' '*' always;
    }

    access_log /var/log/nginx/student-hub.access.log;
    error_log /var/log/nginx/student-hub.error.log;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
}
EOF

# Enable the Student Hub configuration
sudo ln -sf /etc/nginx/sites-available/00-student-hub /etc/nginx/sites-enabled/00-student-hub

# Re-enable subdomain configurations
sudo ln -sf /etc/nginx/sites-available/strategic-llmclass /etc/nginx/sites-enabled/strategic-llmclass
sudo ln -sf /etc/nginx/sites-available/rtcf-llmclass /etc/nginx/sites-enabled/rtcf-llmclass

echo "📋 Final enabled sites:"
ls -la /etc/nginx/sites-enabled/

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Configuration test passed!"
    
    # Restart Nginx
    echo "🔄 Restarting Nginx..."
    sudo systemctl restart nginx
    
    # Test the fix
    echo "🌐 Testing dev.llmclass.org..."
    curl -I http://dev.llmclass.org/
    
    echo ""
    echo "✅ Fix completed!"
    echo "🌐 Please test: https://dev.llmclass.org"
else
    echo "❌ Nginx configuration test failed!"
fi