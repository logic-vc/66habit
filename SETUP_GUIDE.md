# 66 Habit - 개발 환경 설정 가이드

## 📋 사전 요구사항

1. **Flutter SDK 3.0.0 이상**
   - [Flutter 설치 가이드](https://docs.flutter.dev/get-started/install)

2. **개발 도구**
   - Android Studio (Android 개발용) 또는
   - Xcode (iOS 개발용, macOS만)
   - VS Code (선택사항)

3. **실제 기기 또는 에뮬레이터**
   - 햅틱 피드백 테스트를 위해 **실제 기기 강력 권장**
   - iOS 시뮬레이터는 햅틱 피드백 테스트 불가

---

## 🚀 설치 및 실행

### 1. Flutter 설치 확인

```bash
flutter --version
flutter doctor
```

`flutter doctor` 명령어로 설치 상태를 확인하세요.

### 2. 의존성 설치

```bash
cd 66habit
flutter pub get
```

### 3. 실행

#### Android

```bash
# 연결된 Android 기기/에뮬레이터 확인
flutter devices

# 실행
flutter run
```

#### iOS (macOS만)

```bash
# CocoaPods 설치
cd ios
pod install
cd ..

# 실행
flutter run -d ios
```

---

## 🎵 사운드 파일 추가 (선택사항)

현재는 사운드 파일 없이도 앱이 작동하지만, 완전한 경험을 위해 사운드 파일을 추가하세요.

### 필요한 파일

`assets/sounds/` 폴더에 다음 파일들을 추가:

1. **shutter.mp3** - 체크 완료 소리
2. **tick.mp3** - 게이지 틱 소리 (선택)
3. **success.mp3** - 성공 소리
4. **milestone.mp3** - 마일스톤 소리

### 무료 사운드 다운로드

- [Freesound.org](https://freesound.org/) - 검색어: "camera shutter", "click", "success"
- [Zapsplat](https://www.zapsplat.com/)
- [Mixkit](https://mixkit.co/free-sound-effects/)

### 사운드 파일 요구사항

- 포맷: MP3 (권장)
- 크기: 10-30KB
- 길이: 0.5-2초

---

## 🧪 테스트 방법

### 롱프레스 인터랙션 테스트

1. 앱 실행 후 메인 화면의 체크 버튼 확인
2. 원형 버튼을 **1.5초간 꾹 눌러** 게이지가 채워지는지 확인
3. 다음 피드백이 작동하는지 확인:
   - ✅ 진동 피드백 (25%, 50%, 75%, 100% 시점)
   - ✅ 게이지 애니메이션 (0% → 100%)
   - ✅ 파티클 효과 (별 터짐)
   - ✅ 사운드 재생 (파일이 있는 경우)

### 플랫폼별 확인사항

#### iOS
- **진동 강도**: iPhone 6s 이상에서 Taptic Engine 작동 확인
- **사운드**: 무음 모드에서도 소리 나는지 확인 (현재는 시스템 설정 따름)

#### Android
- **진동 패턴**: Android 8.0+ 에서 더블 탭 진동 확인
- **진동 권한**: AndroidManifest.xml에 VIBRATE 권한 포함됨

---

## 🐛 문제 해결

### "flutter: command not found"
- Flutter SDK가 PATH에 추가되지 않음
- `.bashrc` 또는 `.zshrc`에 Flutter 경로 추가

### "No devices found"
- Android: USB 디버깅 활성화
- iOS: Xcode에서 기기 신뢰 설정

### 햅틱 피드백이 작동하지 않음
- **실제 기기**에서 테스트하세요 (시뮬레이터/에뮬레이터는 햅틱 미지원)
- Android: 진동 권한 확인
- iOS: 시스템 설정 > 사운드 및 햅틱 > 시스템 햅틱 활성화

### 사운드가 재생되지 않음
- `assets/sounds/` 폴더에 파일 있는지 확인
- `pubspec.yaml`의 assets 경로 확인
- 파일 이름 확인 (shutter.mp3, success.mp3 등)

### Gradle 빌드 오류 (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## 📁 프로젝트 구조

```
lib/
├── core/
│   ├── constants/        # 색상, 애니메이션 시간, 햅틱 패턴
│   ├── database/         # SQLite DB (미구현)
│   └── utils/            # 유틸리티 함수
├── models/               # 데이터 모델 (미구현)
├── providers/            # 상태 관리 (미구현)
├── services/
│   ├── haptic_service.dart    # ✅ 햅틱 피드백
│   └── sound_service.dart     # ✅ 사운드 재생
├── widgets/
│   └── check_button/
│       ├── long_press_check_button.dart  # ✅ 메인 버튼
│       ├── circular_gauge_painter.dart   # ✅ 게이지 애니메이션
│       └── particle_painter.dart         # ✅ 파티클 효과
└── screens/
    └── home_screen.dart  # ✅ 홈 화면 (프로토타입)
```

---

## ✅ 현재 구현 상태

### 완료 ✅
- [x] Flutter 프로젝트 구조
- [x] 롱프레스 체크 버튼 프로토타입
- [x] 원형 게이지 애니메이션
- [x] 햅틱 피드백 시스템
- [x] 사운드 재생 시스템
- [x] 파티클 효과
- [x] 기본 홈 화면

### 미구현 ⏳
- [ ] 습관 CRUD (데이터베이스)
- [ ] 66일 체인 시각화 (상세)
- [ ] 연속 일수 계산 로직
- [ ] 재시작 기능
- [ ] 설정 화면
- [ ] 마일스톤 피드백 (3일, 7일 등)
- [ ] 온보딩

---

## 🎯 다음 단계

### Phase 1: 데이터베이스 (우선순위 높음)
1. SQLite 스키마 설계
2. Habit 모델 구현
3. CheckRecord 모델 구현
4. CRUD 기능 구현

### Phase 2: 상태 관리
1. Provider 설정
2. HabitProvider 구현
3. CheckProvider 구현

### Phase 3: UI 완성
1. 습관 추가 화면
2. 66일 체인 그리드
3. 설정 화면
4. 온보딩

---

## 📝 커스터마이징

### 롱프레스 시간 변경

`lib/widgets/check_button/long_press_check_button.dart`:

```dart
LongPressCheckButton(
  isChecked: false,
  onCheckComplete: () {},
  pressDuration: Duration(milliseconds: 1000), // 1초로 변경
)
```

### 햅틱 강도 변경

`lib/services/haptic_service.dart`:

```dart
HapticService().setStrength(HapticStrength.heavy); // 강하게
```

### 게이지 색상 변경

`lib/core/constants/colors.dart`:

```dart
static const gaugeFilling = Color(0xFFFF5722); // 오렌지로 변경
```

---

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. `flutter doctor` 출력
2. 에러 메시지 전체
3. 사용 중인 기기/OS 버전
4. Flutter SDK 버전

---

**Happy Coding! 🚀**
