#!/bin/bash

echo "🔍 dev.llmclass.org 연결 문제 진단 중..."

echo "1. EC2 인스턴스 상태 확인"
echo "AWS 콘솔에서 EC2 인스턴스가 running 상태인지 확인하세요"

echo ""
echo "2. DNS 확인"
nslookup dev.llmclass.org
dig dev.llmclass.org

echo ""
echo "3. 포트 연결 테스트"
nc -zv dev.llmclass.org 80
nc -zv dev.llmclass.org 443

echo ""
echo "4. ping 테스트"
ping -c 3 dev.llmclass.org

echo ""
echo "=== EC2에서 실행할 명령어들 ==="
echo "ssh ubuntu@dev.llmclass.org"
echo ""
echo "# 서버 상태 확인"
echo "sudo systemctl status nginx"
echo "sudo systemctl status llm-classroom"
echo ""
echo "# 포트 확인"
echo "sudo netstat -tlnp | grep :80"
echo "sudo netstat -tlnp | grep :8000"
echo ""
echo "# 로그 확인"
echo "sudo tail -n 50 /var/log/nginx/error.log"
echo "sudo journalctl -u nginx -n 20"
echo ""
echo "# 방화벽 확인"
echo "sudo ufw status"
echo ""
echo "# 프로세스 확인"
echo "ps aux | grep nginx"
echo "ps aux | grep python"