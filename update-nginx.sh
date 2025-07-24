#!/bin/bash

echo "🔧 Student Hub Nginx 설정 업데이트 중..."

# Nginx 설정 파일 복사
sudo cp nginx-config/00-student-hub /etc/nginx/sites-available/00-student-hub

# 기존 설정 제거
sudo rm -f /etc/nginx/sites-enabled/llm-classroom-student

# 새 설정 활성화
sudo ln -sf /etc/nginx/sites-available/00-student-hub /etc/nginx/sites-enabled/00-student-hub

# Nginx 설정 테스트
echo "📋 Nginx 설정 테스트 중..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ 설정 테스트 성공!"
    
    # Nginx 재시작
    echo "🔄 Nginx 재시작 중..."
    sudo systemctl restart nginx
    
    # 상태 확인
    echo "📊 Nginx 상태 확인..."
    sudo systemctl status nginx --no-pager -l
    
    echo ""
    echo "✅ Student Hub 설정 완료!"
    echo "🌐 브라우저에서 https://dev.llmclass.org 테스트해보세요"
    echo ""
    echo "📋 활성화된 사이트 목록:"
    ls -la /etc/nginx/sites-enabled/
else
    echo "❌ Nginx 설정 테스트 실패!"
    echo "설정을 확인해주세요."
fi