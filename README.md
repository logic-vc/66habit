# 66 Habit - 66일 습관 형성 앱

66일간 습관을 추적하며 **롱프레스 인터랙션과 촉각/청각 피드백**으로 중독성 있는 성취감을 제공하는 습관 형성 앱

## 핵심 차별화 포인트

- 🎯 66일 과학적 습관 형성 기간 기반
- 👆 꾹 누르는 물리적 행위로 의도적 체크 유도
- 📸 찰칵 소리 + 햅틱 + 애니메이션 트리플 피드백
- 🔗 시각적 체인으로 연속성 강화

## 시작하기

### 필요 환경
- Flutter SDK 3.0.0 이상
- iOS 12.0+ / Android API 21+

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 실행 (iOS)
flutter run -d ios

# 실행 (Android)
flutter run -d android
```

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/     # 색상, 애니메이션 시간 등 상수
│   ├── database/      # SQLite 데이터베이스 헬퍼
│   └── utils/         # 유틸리티 함수
├── models/            # 데이터 모델 (Habit, CheckRecord 등)
├── providers/         # 상태 관리 (Provider)
├── services/          # 햅틱, 사운드, 저장소 서비스
├── widgets/           # 재사용 가능한 위젯
│   ├── check_button/  # 롱프레스 체크 버튼
│   └── chain_view/    # 66일 체인 시각화
└── screens/           # 화면 (홈, 습관 추가 등)
```

## 개발 현황

### Phase 1: 프로토타입 ✅
- [x] 프로젝트 셋업
- [x] 롱프레스 체크 버튼 프로토타입
- [x] 햅틱 피드백 시스템
- [x] 사운드 피드백 시스템
- [x] 파티클 효과

### Phase 2: 데이터베이스 ✅
- [x] SQLite 데이터베이스 스키마
- [x] Habit 모델 및 CRUD
- [x] CheckRecord 모델 및 CRUD
- [x] 연속 일수 계산 로직
- [x] Provider 상태 관리
- [x] UI 통합 (샘플 습관 추가, 체크, 삭제)

### Phase 3: UI 완성 ⏳
- [x] 체인 시각화 (기본)
- [ ] 습관 추가/수정 화면
- [ ] 66일 전체 체인 그리드
- [ ] 설정 화면
- [ ] 온보딩

### 다음 단계
- [ ] 습관 추가 폼 UI
- [ ] 전체 체인 그리드 뷰
- [ ] 사운드 에셋 추가
- [ ] 설정 기능 (햅틱/사운드 ON/OFF)
- [ ] 앱 아이콘 및 스플래시 화면

## 라이선스

MIT License
