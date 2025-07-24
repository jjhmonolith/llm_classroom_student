#!/bin/bash

# LLM Classroom Student Hub 배포 스크립트
echo "🎓 LLM Classroom Student Hub 배포를 시작합니다..."

# 현재 디렉토리 확인
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# 배포 디렉토리 생성
DEPLOY_DIR="/var/www/llm-classroom-student"
sudo mkdir -p "$DEPLOY_DIR"

# 파일 복사
echo "📁 파일을 배포 디렉토리로 복사 중..."
sudo cp index.html "$DEPLOY_DIR/"
sudo cp README.md "$DEPLOY_DIR/"

# 권한 설정
sudo chown -R www-data:www-data "$DEPLOY_DIR"
sudo chmod -R 755 "$DEPLOY_DIR"

# Nginx 설정 생성
echo "⚙️  Nginx 설정 생성 중..."
sudo tee /etc/nginx/sites-available/llm-classroom-student > /dev/null << 'EOF'
server {
    listen 80;
    server_name dev.llmclass.org;

    root /var/www/llm-classroom-student;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
        
        # 캐시 설정
        add_header Cache-Control "public, max-age=3600";
        
        # CORS 헤더
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
    }

    # 정적 리소스 캐싱
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header 'Access-Control-Allow-Origin' '*' always;
    }

    # 로그 설정
    access_log /var/log/nginx/student-hub.access.log;
    error_log /var/log/nginx/student-hub.error.log;

    # Gzip 압축
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

# 사이트 활성화
echo "🔗 사이트 활성화 중..."
sudo ln -sf /etc/nginx/sites-available/llm-classroom-student /etc/nginx/sites-enabled/

# Nginx 설정 테스트
echo "🔍 Nginx 설정 테스트 중..."
sudo nginx -t

if [ $? -eq 0 ]; then
    # Nginx 재시작
    echo "🔄 Nginx 재시작 중..."
    sudo systemctl restart nginx
    
    echo ""
    echo "✅ 배포 완료!"
    echo "🌐 접속 주소: http://dev.llmclass.org"
    echo ""
    echo "📊 상태 확인:"
    echo "  sudo systemctl status nginx"
    echo "  curl -I http://localhost"
else
    echo "❌ Nginx 설정에 오류가 있습니다."
    exit 1
fi