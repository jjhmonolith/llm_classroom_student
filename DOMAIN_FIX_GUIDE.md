# 🌐 도메인 접속 문제 해결 가이드

## 현재 상황
- ✅ IP 접속: `http://3.107.236.141/` 작동
- ❌ 도메인 접속: `http://dev.llmclass.org/` 작동 안함

## 원인
Nginx 설정에서 `server_name`이 올바르게 설정되지 않았거나, 다른 설정이 도메인 요청을 가로채고 있을 가능성

## 해결 방법

### EC2에서 실행할 명령어:

```bash
# 1. Student Hub 리포지토리 업데이트
cd /home/ubuntu/llm_classroom_student
git pull origin main

# 2. 도메인 수정 스크립트 실행
chmod +x fix-domain-access.sh
./fix-domain-access.sh
```

### 스크립트가 하는 일:

1. **server_name 수정**: `dev.llmclass.org`, IP, `_` (모든 요청) 처리
2. **기본 서버 설정**: `default_server`로 우선순위 보장
3. **충돌 설정 제거**: 다른 설정이 요청을 가로채지 않도록
4. **서브도메인 재활성화**: strategic, rtcf 서브도메인 복원

### 수동 확인 방법:

```bash
# Nginx 설정 확인
sudo nginx -t

# 활성화된 사이트 확인
ls -la /etc/nginx/sites-enabled/

# 설정 파일 내용 확인
sudo cat /etc/nginx/sites-available/00-student-hub

# 로그 확인
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/student-hub.error.log
```

### 테스트:

```bash
# 서버에서 테스트
curl -I http://dev.llmclass.org/
curl -I http://localhost/

# 브라우저에서 테스트
# http://dev.llmclass.org/
# https://dev.llmclass.org/ (SSL 설정 후)
```

### 예상 결과:

수정 후 다음이 모두 작동해야 합니다:
- ✅ `http://dev.llmclass.org/` → Student Hub
- ✅ `http://3.107.236.141/` → Student Hub  
- ✅ `https://strategic.dev.llmclass.org/` → Proto1
- ✅ `https://rtcf.dev.llmclass.org/` → Proto2

### 문제가 지속되면:

```bash
# DNS 캐시 초기화 (로컬)
sudo dscacheutil -flushcache

# 브라우저 캐시 초기화
# Chrome: Ctrl+Shift+Delete
```