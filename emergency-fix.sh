#!/bin/bash

echo "🚨 긴급 수정 시작..."
echo "모든 nginx 설정을 처음부터 다시 설정합니다."

# 1. 모든 sites-enabled 삭제
echo "1. 기존 설정 완전 삭제..."
sudo rm -f /etc/nginx/sites-enabled/*

# 2. sites-available 백업 및 정리
echo "2. sites-available 백업..."
sudo cp -r /etc/nginx/sites-available /etc/nginx/sites-available.backup.$(date +%Y%m%d_%H%M%S)

# 3. 기본 설정 삭제
sudo rm -f /etc/nginx/sites-available/default

# 4. Student Hub만 단순하게 설정
echo "3. Student Hub 단순 설정 생성..."
sudo tee /etc/nginx/sites-available/student-hub > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    
    root /var/www/llm-classroom-student;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# 5. 활성화
echo "4. Student Hub 활성화..."
sudo ln -sf /etc/nginx/sites-available/student-hub /etc/nginx/sites-enabled/student-hub

# 6. 웹 디렉토리 확인 및 생성
echo "5. 웹 디렉토리 확인..."
if [ ! -d /var/www/llm-classroom-student ]; then
    echo "웹 디렉토리 생성..."
    sudo mkdir -p /var/www/llm-classroom-student
    sudo chown -R www-data:www-data /var/www/llm-classroom-student
fi

# 7. 임시 테스트 페이지 생성
echo "6. 임시 테스트 페이지 생성..."
sudo tee /var/www/llm-classroom-student/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>LLM Classroom Student Hub - Test</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>🎯 Student Hub 테스트 페이지</h1>
    <p>이 페이지가 보인다면 nginx 설정이 작동합니다!</p>
    <p>Domain: <span id="domain"></span></p>
    <p>Time: <span id="time"></span></p>
    
    <h2>모드 선택</h2>
    <button onclick="goToStrategic()">전략적 흐름 설계</button>
    <button onclick="goToRTCF()">RTCF 연습</button>
    
    <script>
        document.getElementById('domain').textContent = window.location.host;
        document.getElementById('time').textContent = new Date().toLocaleString();
        
        function goToStrategic() {
            window.location.href = 'https://strategic.dev.llmclass.org/';
        }
        
        function goToRTCF() {
            window.location.href = 'https://rtcf.dev.llmclass.org/';
        }
    </script>
</body>
</html>
EOF

# 8. 권한 설정
sudo chown -R www-data:www-data /var/www/llm-classroom-student/
sudo chmod -R 755 /var/www/llm-classroom-student/

# 9. nginx 테스트 및 재시작
echo "7. Nginx 테스트..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "8. Nginx 재시작..."
    sudo systemctl restart nginx
    
    echo "9. 상태 확인..."
    sudo systemctl status nginx --no-pager
    
    echo ""
    echo "✅ 긴급 수정 완료!"
    echo ""
    echo "테스트해보세요:"
    echo "- http://dev.llmclass.org/"
    echo "- http://3.107.236.141/"
    echo ""
    echo "간단한 테스트:"
    curl -I http://localhost/ 2>/dev/null | head -3
    
else
    echo "❌ Nginx 설정 오류!"
    sudo nginx -t
fi