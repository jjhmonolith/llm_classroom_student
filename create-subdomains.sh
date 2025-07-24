#!/bin/bash

echo "🔧 서브도메인 설정 생성 중..."

# 1. Strategic 서브도메인 (Proto1 - FastAPI on port 8000)
sudo tee /etc/nginx/sites-available/strategic > /dev/null << 'EOF'
server {
    listen 80;
    server_name strategic.dev.llmclass.org;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 2. RTCF 서브도메인 (Proto2 - Next.js on port 3000, API on port 3001)
sudo tee /etc/nginx/sites-available/rtcf > /dev/null << 'EOF'
server {
    listen 80;
    server_name rtcf.dev.llmclass.org;
    
    # API 요청을 백엔드로 전달
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 나머지 요청을 프론트엔드로 전달
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 3. 설정 활성화
echo "✅ 서브도메인 설정 활성화..."
sudo ln -sf /etc/nginx/sites-available/strategic /etc/nginx/sites-enabled/strategic
sudo ln -sf /etc/nginx/sites-available/rtcf /etc/nginx/sites-enabled/rtcf

# 4. nginx 테스트
echo "🧪 nginx 설정 테스트..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ 설정 테스트 통과!"
    
    # 5. nginx 재시작
    echo "🔄 nginx 재시작..."
    sudo systemctl restart nginx
    
    # 6. 서비스 상태 확인
    echo "📊 서비스 상태 확인..."
    echo "=== nginx 상태 ==="
    sudo systemctl status nginx --no-pager
    
    echo ""
    echo "=== Proto1 (Strategic) 상태 ==="
    sudo systemctl status llm-classroom --no-pager
    
    echo ""
    echo "=== Proto2 (RTCF) 상태 ==="
    pm2 status || echo "PM2 서비스 없음"
    
    echo ""
    echo "=== 포트 리스닝 확인 ==="
    sudo netstat -tlnp | grep -E ":80|:8000|:3000|:3001"
    
    echo ""
    echo "✅ 서브도메인 설정 완료!"
    echo "🌐 테스트 URL:"
    echo "- http://dev.llmclass.org/ (Student Hub)"
    echo "- http://strategic.dev.llmclass.org/ (Proto1)"
    echo "- http://rtcf.dev.llmclass.org/ (Proto2)"
    
else
    echo "❌ nginx 설정 오류!"
    sudo nginx -t
fi