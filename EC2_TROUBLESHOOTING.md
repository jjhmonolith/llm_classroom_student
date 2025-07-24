# 🚨 EC2 연결 문제 해결 가이드

## 현재 상황
- DNS: ✅ 정상 (3.107.236.141)
- Ping: ❌ 100% 패킷 손실
- HTTP(80): ❌ 연결 타임아웃
- HTTPS(443): ❌ 연결 거부

## 해결 단계

### 1. AWS 콘솔에서 확인해야 할 것들

#### EC2 인스턴스 상태
```
1. AWS 콘솔 → EC2 → 인스턴스
2. dev.llmclass.org 인스턴스 상태 확인
   - 상태: running 이어야 함
   - 상태 검사: 2/2 통과 이어야 함
```

#### 보안 그룹 설정
```
1. 인스턴스 선택 → 보안 탭 → 보안 그룹 클릭
2. 인바운드 규칙 확인:
   - HTTP(80): 0.0.0.0/0
   - HTTPS(443): 0.0.0.0/0
   - SSH(22): 0.0.0.0/0 (또는 특정 IP)
```

### 2. EC2 인스턴스 재시작

AWS 콘솔에서:
```
1. 인스턴스 선택
2. 인스턴스 상태 → 인스턴스 재부팅
```

### 3. SSH 접속 가능한 경우

**인스턴스 키 페어로 접속:**
```bash
ssh -i "your-key.pem" ubuntu@3.107.236.141
```

**서버 상태 확인:**
```bash
# 시스템 상태
sudo systemctl status nginx
sudo systemctl status llm-classroom

# 포트 리스닝 확인
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# 서비스 재시작
sudo systemctl restart nginx
sudo systemctl restart llm-classroom

# 방화벽 확인 및 비활성화
sudo ufw status
sudo ufw disable  # 임시로 비활성화해서 테스트
```

### 4. 보안 그룹 설정 예시

정확한 인바운드 규칙:
```
Type        Protocol    Port Range    Source
HTTP        TCP         80           0.0.0.0/0
HTTPS       TCP         443          0.0.0.0/0
SSH         TCP         22           0.0.0.0/0
Custom TCP  TCP         8000         0.0.0.0/0  # Proto1용
Custom TCP  TCP         3000         0.0.0.0/0  # Proto2 frontend용
Custom TCP  TCP         3001         0.0.0.0/0  # Proto2 backend용
```

### 5. 임시 해결책

**IP로 직접 접속 테스트:**
```
http://3.107.236.141/
```

### 6. 긴급 복구 절차

만약 모든 것이 실패하면:
```bash
# 새 EC2 인스턴스에 재배포
# 또는 현재 인스턴스 중지 후 재시작
```

## 다음 단계

1. ✅ AWS 콘솔에서 EC2 상태 확인
2. ✅ 보안 그룹 인바운드 규칙 확인  
3. ✅ 인스턴스 재부팅
4. ✅ SSH 접속 후 서비스 상태 확인
5. ✅ 방화벽 설정 확인

**우선순위: EC2 인스턴스와 보안 그룹 확인이 가장 중요합니다!**