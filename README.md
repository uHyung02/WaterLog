# WaterLog (워터로그) - SwiftUI 물 마시기 트래커

AI 도구(Google Gemini)와의 협업을 통해 개발한 SwiftUI 기반 iOS 물 마시기 트래커 앱입니다.

본 프로젝트는 AI와의 협업 능력, SwiftUI 코드 이해도, 문제 해결 과정의 논리성을 평가받기 위해 작성되었습니다.

---

## 🚀 주요 기능

본 앱은 기획서에 정의된 다음 5가지 필수 기능을 포함합니다.

1.  **목표 설정:** 사용자가 일일 목표 섭취량을 설정합니다.
2.  **물 섭취 기록:** 버튼 클릭으로 마신 물의 양을 간편하게 추가합니다.
3.  **진행률 시각화:** 목표 대비 달성률을 원형 그래프로 한눈에 보여줍니다.
4.  **섭취 기록 리스트:** 시간대별로 물을 마신 기록을 목록으로 제공합니다.
5.  **일일 자동 초기화:** 매일 자정이 되면 섭취 기록이 자동으로 0으로 초기화됩니다.
6.  **(추가) 알림 기능:** 설정한 시간마다 물 마시기 알림을 보냅니다.

---

## 🛠 기술 스택 (Development)

* **UI Framework:** `SwiftUI`
* **Data Management:**
    * `@AppStorage` (UserDefaults): 일일 목표 섭취량 등 사용자 설정값 저장
    * `Codable` & `JSONEncoder/Decoder`: `[DrinkLog]`(섭취 기록 배열)을 JSON으로 변환하여 `@AppStorage`에 저장
* **Notifications:** `UserNotifications`
* **IDE:** (macOS 환경 부재로 인해) GitHub 웹 인터페이스 및 AI 협업 도구를 통해 코드 작성
* **Version Control:** `Git` & `GitHub`

---

## 📂 프로젝트 구조

macOS 환경 부재로 인해 Xcode 프로젝트 파일(.xcodeproj)은 포함되지 않았으나, 표준 SwiftUI 앱 구조를 따릅니다.
