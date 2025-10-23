import Foundation
import SwiftUI // @AppStorage, @Published 등을 사용하기 위해 필요합니다.

/**
 * 앱의 모든 데이터와 비즈니스 로직을 관리하는 ViewModel (기획서 3단계 '핵심 관리 데이터')
 *
 * - ObservableObject: SwiftUI 뷰가 이 객체의 변경사항을 감지하고 UI를 자동으로 업데이트할 수 있게 합니다.
 */
class WaterData: ObservableObject {
    
    /// 1. 일일 목표 섭취량 (필수 기능 1)
    /// - @AppStorage: 앱을 껐다 켜도 값이 유지되도록 UserDefaults에 저장합니다.
    @AppStorage("targetGoal") var targetGoal: Int = 2000 // 기본값 2000ml
    
    /// 4. 시간별 기록 리스트 (필수 기능 4)
    /// - @Published: 이 배열이 변경될 때마다(추가/삭제) UI(View)가 자동으로 새로고침됩니다.
    @Published var dailyLogs: [DrinkLog] = []
    
    /// `dailyLogs` 배열을 JSON 데이터로 변환하여 저장하기 위한 @AppStorage
    /// (DrinkLog.swift에서 정의한 'Codable' 프로토콜이 여기서 사용됩니다)
    @AppStorage("dailyLogsData") private var dailyLogsData: Data = Data()
    
    
    // --- 계산된 프로퍼티 (Computed Properties) ---
    
    /// 오늘 마신 총량 (ml)
    var totalToday: Int {
        // dailyLogs 배열의 모든 'amount' 값을 더합니다.
        dailyLogs.reduce(0) { $0 + $1.amount }
    }
    
    /// 목표 달성률 (0.0 ~ 1.0 사이 값) (필수 기능 3: 시각화 데이터)
    var progress: Double {
        if targetGoal == 0 { return 0 } // 목표가 0일 때 0으로 나누기 방지
        // 100% (1.0)를 넘지 않도록 min() 함수 사용
        return min(1.0, Double(totalToday) / Double(targetGoal))
    }
    
    
    // --- 초기화 함수 ---
    
    /// WaterData 객체가 처음 생성될 때(앱 실행 시) 1회 호출됩니다.
    init() {
        loadLogs() // 기기에 저장된 로그 불러오기
        checkAndResetLogs() // 날짜가 바뀌었는지 확인하고 초기화
    }
    
    
    // --- 핵심 기능 함수 (Methods) ---
    
    /// 2. 물 마신 양 추가 (필수 기능 2)
    func addLog(amount: Int) {
        // 새 기록 생성 (DrinkLog 모델 사용)
        let newLog = DrinkLog(date: Date(), amount: amount)
        // 리스트의 맨 앞에 추가 (최신순으로 보여주기 위함)
        dailyLogs.insert(newLog, at: 0)
        // 변경된 리스트를 기기에 저장
        saveLogs()
    }
    
    /// 5. 일일 초기화 기능 (필수 기능 5)
    func checkAndResetLogs() {
        // 마지막 기록(배열의 첫 번째)의 날짜를 가져옴
        guard let lastLogDate = dailyLogs.first?.date else {
            // 기록이 아예 없으면 아무것도 안 함
            return
        }
        
        // 마지막 기록의 날짜가 '오늘'이 아니면 (즉, 날짜가 바뀌었으면)
        if !Calendar.current.isDateInToday(lastLogDate) {
            dailyLogs.removeAll() // 모든 로그 삭제
            saveLogs() // 비워진 상태를 기기에 저장
        }
    }
    
    
    // --- 데이터 저장/불러오기 Helper 함수 ---
    
    /// `dailyLogs` 배열을 JSON으로 인코딩하여 `dailyLogsData`에 저장
    private func saveLogs() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(dailyLogs) {
            dailyLogsData = encodedData
        }
    }
    
    /// `dailyLogsData`의 JSON을 디코딩하여 `dailyLogs` 배열로 불러오기
    private func loadLogs() {
        let decoder = JSONDecoder()
        if let decodedLogs = try? decoder.decode([DrinkLog].self, from: dailyLogsData) {
            dailyLogs = decodedLogs
        }
    }
}
