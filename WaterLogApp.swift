import SwiftUI

/**
 * WaterLog 앱의 메인 진입점 (Entry Point)
 *
 * - @main: Swift 컴파일러에게 이 struct가 앱 실행의 시작점임을 알립니다.
 *
 * Xcode 프로젝트에서는 이 파일이 최상위 폴더에 위치하며,
 * 앱의 전체적인 생명주기와 씬(Scene)을 관리합니다.
 */
@main
struct WaterLogApp: App {
    
    // body는 앱이 표시할 화면(Scene)을 정의합니다.
    var body: some Scene {
        WindowGroup {
            // 앱이 실행될 때 사용자에게 보여줄 '첫 번째 화면'을 지정합니다.
            // 우리는 기획서에서 설계한 MainView를 첫 화면으로 설정합니다.
            MainView()
        }
    }
}
