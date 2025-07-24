#!/bin/bash

echo "🔧 도메인 접속 문제 수정 중..."
echo "IP로는 접속되지만 dev.llmclass.org로는 안 되는 문제 해결"

# 현재 Nginx 설정 확인
echo "📋 현재 활성화된 사이트:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "📋 현재 Nginx 설정 파일들:"
ls -la /etc/nginx/sites-available/

# Student Hub 설정을 IP와 도메인 모두에서 작동하도록 수정
echo ""
echo "📝 Student Hub 설정 수정 중..."
sudo tee /etc/nginx/sites-available/00-student-hub > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    # IP와 도메인 모두 허용
    server_name dev.llmclass.org 3.107.236.141 _;

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

# 기존 설정들 정리
echo "🗑️ 기존 설정 정리..."
sudo rm -f /etc/nginx/sites-enabled/llm-classroom-student
sudo rm -f /etc/nginx/sites-enabled/default

# Student Hub 설정 활성화
echo "✅ Student Hub 설정 활성화..."
sudo ln -sf /etc/nginx/sites-available/00-student-hub /etc/nginx/sites-enabled/00-student-hub

# 서브도메인 설정들도 다시 활성화
echo "🔗 서브도메인 설정 활성화..."

# Strategic 서브도메인 설정 확인 및 수정
if [ -f /etc/nginx/sites-available/strategic-llmclass ]; then
    sudo ln -sf /etc/nginx/sites-available/strategic-llmclass /etc/nginx/sites-enabled/strategic-llmclass
    echo "✅ Strategic 서브도메인 활성화됨"
else
    echo "⚠️ Strategic 서브도메인 설정이 없습니다"
fi

# RTCF 서브도메인 설정 확인 및 수정
if [ -f /etc/nginx/sites-available/rtcf-llmclass ]; then
    sudo ln -sf /etc/nginx/sites-available/rtcf-llmclass /etc/nginx/sites-enabled/rtcf-llmclass
    echo "✅ RTCF 서브도메인 활성화됨"
else
    echo "⚠️ RTCF 서브도메인 설정이 없습니다"
fi

echo ""
echo "📋 최종 활성화된 사이트들:"
ls -la /etc/nginx/sites-enabled/

# Nginx 설정 테스트
echo ""
echo "🧪 Nginx 설정 테스트..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ 설정 테스트 통과!"
    
    # Nginx 재시작
    echo "🔄 Nginx 재시작..."
    sudo systemctl restart nginx
    
    # 상태 확인
    echo "📊 Nginx 상태 확인..."
    sudo systemctl status nginx --no-pager
    
    echo ""
    echo "🌐 테스트해보세요:"
    echo "- http://dev.llmclass.org/"
    echo "- http://3.107.236.141/"
    echo "- https://dev.llmclass.org/ (SSL 설정 후)"
    
    # 간단한 테스트
    echo ""
    echo "📋 로컬 테스트 결과:"
    curl -I http://dev.llmclass.org/ 2>/dev/null | head -3
    
else
    echo "❌ Nginx 설정에 오류가 있습니다!"
    echo "에러 로그 확인:"
    sudo nginx -t
fi