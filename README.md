# 🎓 LLM Classroom Student Hub

학생용 메인 허브 페이지 - 학습 모드 선택 및 라우팅

## 📖 개요

LLM Classroom의 학생용 메인 진입점으로, 다양한 학습 모드 중 하나를 선택할 수 있는 허브 페이지입니다.

## 🎯 기능

### 현재 지원 모드
1. **🌍 전략적 흐름 설계** 
   - 사회 문제 해결 프로젝트 기반 학습
   - URL: `https://strategic.dev.llmclass.org/`

2. **📝 RTCF 연습**
   - AI 프롬프트 작성 기법 학습
   - URL: `https://rtcf.dev.llmclass.org/`

### 향후 확장 예정
- 📊 학습 분석 도구
- 🤝 협업 학습 공간
- 📚 개인 학습 기록

## 🏗️ 구조

```
LLM Classroom Student Hub/
├── index.html          # 메인 허브 페이지
├── README.md          # 프로젝트 설명
├── deploy.sh          # 배포 스크립트
└── .gitignore         # Git 무시 파일
```

## 🚀 배포

### 정적 호스팅
단순한 HTML 페이지이므로 Nginx로 정적 파일 서빙

### URL 구조
- **메인 허브**: `https://dev.llmclass.org/`
- **전략적 흐름**: `https://strategic.dev.llmclass.org/`  
- **RTCF 연습**: `https://rtcf.dev.llmclass.org/`

## 🎨 디자인

- Proto1과 일관된 디자인 시스템
- 반응형 웹 디자인
- 애니메이션 효과
- 접근성 고려

## 🔧 기술 스택

- **HTML5**: 시맨틱 마크업
- **CSS3**: 그라디언트, 애니메이션, Flexbox
- **JavaScript**: 라우팅 및 인터랙션
- **Nginx**: 정적 파일 서빙

---

*LLM Classroom 생태계의 중심 허브*