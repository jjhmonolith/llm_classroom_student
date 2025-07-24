# EC2 수정 가이드

## dev.llmclass.org 리다이렉트 문제 해결

### EC2에서 실행할 명령어들

```bash
# 1. Student Hub 리포지토리에서 최신 수정사항 가져오기
cd /home/ubuntu/llm_classroom_student
git pull origin main

# 2. 수정 스크립트 실행 권한 부여
chmod +x ec2-fix-script.sh

# 3. 수정 스크립트 실행
./ec2-fix-script.sh
```

### 스크립트가 하는 일:

1. **기존 충돌 설정 제거**: 다른 서비스들이 dev.llmclass.org을 가로채는 것을 방지
2. **Student Hub 우선순위 설정**: `00-student-hub`로 파일명을 변경해 가장 먼저 로드
3. **default_server 설정**: Student Hub가 기본 서버로 동작하도록 설정
4. **서브도메인 재활성화**: strategic, rtcf 서브도메인 설정 복원
5. **Nginx 재시작**: 변경사항 적용

### 실행 후 테스트:

```bash
# HTTP 응답 헤더 확인
curl -I http://dev.llmclass.org/

# 브라우저에서 테스트
# https://dev.llmclass.org - Student Hub 모드 선택 페이지
# https://strategic.dev.llmclass.org - Proto1 서비스
# https://rtcf.dev.llmclass.org - Proto2 서비스
```

### 문제 해결:

만약 여전히 문제가 있다면:

```bash
# Nginx 에러 로그 확인
sudo tail -f /var/log/nginx/error.log

# Student Hub 로그 확인
sudo tail -f /var/log/nginx/student-hub.error.log
```