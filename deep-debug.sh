#!/bin/bash

echo "🔍 심층 진단 시작..."

echo "=== 1. 기본 연결성 테스트 ==="
echo "IP 접속 테스트:"
curl -I http://3.107.236.141/ 2>&1 | head -5

echo ""
echo "도메인 접속 테스트:"
curl -I http://dev.llmclass.org/ 2>&1 | head -5

echo ""
echo "=== 2. Nginx 프로세스 확인 ==="
ps aux | grep nginx | grep -v grep

echo ""
echo "=== 3. 포트 리스닝 확인 ==="
sudo netstat -tlnp | grep :80

echo ""
echo "=== 4. 활성화된 Nginx 사이트 ==="
ls -la /etc/nginx/sites-enabled/

echo ""
echo "=== 5. Student Hub 설정 내용 ==="
if [ -f /etc/nginx/sites-available/00-student-hub ]; then
    echo "✅ 00-student-hub 파일 존재"
    cat /etc/nginx/sites-available/00-student-hub | grep -A5 -B5 server_name
else
    echo "❌ 00-student-hub 파일 없음"
fi

echo ""
echo "=== 6. 다른 설정 파일들 확인 ==="
for file in /etc/nginx/sites-enabled/*; do
    if [ -f "$file" ]; then
        echo "파일: $file"
        grep -n "server_name\|listen.*80" "$file" || echo "server_name/listen 설정 없음"
        echo "---"
    fi
done

echo ""
echo "=== 7. 메인 Nginx 설정 확인 ==="
grep -n "include.*sites-enabled" /etc/nginx/nginx.conf

echo ""
echo "=== 8. Nginx 에러 로그 ==="
echo "최근 에러 로그 (최근 20줄):"
sudo tail -20 /var/log/nginx/error.log

echo ""
echo "=== 9. Student Hub 특정 로그 ==="
if [ -f /var/log/nginx/student-hub.error.log ]; then
    echo "Student Hub 에러 로그:"
    sudo tail -10 /var/log/nginx/student-hub.error.log
else
    echo "Student Hub 에러 로그 파일 없음"
fi

echo ""
echo "=== 10. Nginx 설정 테스트 ==="
sudo nginx -t

echo ""
echo "=== 11. 시스템 상태 ==="
sudo systemctl status nginx --no-pager -l | head -10

echo ""
echo "=== 12. 호스트 파일 확인 ==="
grep -i llmclass /etc/hosts || echo "hosts 파일에 llmclass 관련 항목 없음"

echo ""
echo "=== 13. DNS 응답 확인 ==="
nslookup dev.llmclass.org | grep Address

echo ""
echo "=== 14. 로컬 curl 테스트 (서버 내부) ==="
echo "localhost 테스트:"
curl -H "Host: dev.llmclass.org" http://localhost/ -I 2>&1 | head -3

echo ""
echo "IP로 Host 헤더 테스트:"
curl -H "Host: dev.llmclass.org" http://3.107.236.141/ -I 2>&1 | head -3

echo ""
echo "=== 15. 웹 디렉토리 확인 ==="
ls -la /var/www/llm-classroom-student/ | head -10

echo ""
echo "=== 진단 완료 ==="
echo "위 정보를 분석해서 문제를 찾아보세요."