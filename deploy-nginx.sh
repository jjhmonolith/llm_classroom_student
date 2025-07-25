#!/bin/bash

echo "🔧 Nginx 설정 배포 시작..."

# Student Hub 디렉토리 및 파일 생성
sudo mkdir -p /var/www/llm-classroom-student
sudo cp ~/llm_classroom_student/index.html /var/www/llm-classroom-student/
sudo chown -R www-data:www-data /var/www/llm-classroom-student

# 모든 기존 sites-enabled 제거
sudo rm -f /etc/nginx/sites-enabled/*

# Nginx 설정 파일들 복사
sudo cp ~/llm_classroom_student/nginx-config/student-hub /etc/nginx/sites-available/
sudo cp ~/llm_classroom_student/nginx-config/strategic /etc/nginx/sites-available/
sudo cp ~/llm_classroom_student/nginx-config/rtcf /etc/nginx/sites-available/

# 설정 활성화
sudo ln -sf /etc/nginx/sites-available/student-hub /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/strategic /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/rtcf /etc/nginx/sites-enabled/

# 설정 테스트
echo "📋 Nginx 설정 테스트..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ 설정 테스트 성공!"
    sudo systemctl restart nginx
    echo "🌐 Nginx 재시작 완료!"
    
    echo ""
    echo "✅ 배포 완료! 브라우저에서 테스트:"
    echo "- http://dev.llmclass.org"
    echo "- http://strategic.dev.llmclass.org"
    echo "- http://rtcf.dev.llmclass.org"
else
    echo "❌ Nginx 설정 테스트 실패!"
fi