import SwiftUI
import UserNotifications // 알림 기능(추가 기능)을 사용하기 위해 필요합니다.

/**
 * 설정 화면 (기획서 2단계 '화면 설계 - 설정')
 *
 * - @ObservedObject: MainView가 생성한 waterData ViewModel을 '관찰'합니다.
 * 여기서 targetGoal을 변경하면 MainView에도 즉시 반영됩니다.
 */
struct SettingsView: View {
    
    /// MainView로부터 넘겨받은 ViewModel 데이터
    @ObservedObject var waterData: WaterData
    
    /// '알림 간격' Picker에서 선택된 값 (단위: 시간)
    /// @State: 이 뷰 안에서만 임시로 사용하는 값이므로 @State를 사용합니다.
    @State private var selectedInterval: Int = 1 // 기본값 1시간
    
    /// 알림 기능 활성화 여부
    @State private var notificationsEnabled: Bool = false
    
    var body: some View {
        // '설정' 메뉴 스타일을 만들기 위해 Form을 사용합니다.
        Form {
            
            // --- 1. 일일 목표 섭취량 설정 (필수 기능 1) ---
            Section(header: Text("목표 설정")) {
                
                VStack(alignment: .leading) {
                    Text("일일 목표 섭취량 (ml)")
                        .font(.headline)
                    
                    // targetGoal 값을 직접 수정할 수 있는 TextField
                    // $waterData.targetGoal: ViewModel의 값을 직접 바인딩(양방향 연결)
                    TextField("목표량 입력", value: $waterData.targetGoal, format: .number)
                        .keyboardType(.numberPad) // 숫자 키패드
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Text("현재 목표: \(waterData.targetGoal) ml")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
            
            // --- 2. 알림 설정 (추가 기능) ---
            Section(header: Text("알림 설정")) {
                
                // 알림 켜기/끄기 토글
                Toggle("물 마시기 알림", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { enabled in
                        if enabled {
                            // 알림 권한 요청 및 스케줄링
                            requestNotificationPermission()
                        } else {
                            // 예약된 모든 알림 취소
                            cancelAllNotifications()
                        }
                    }
                
                // 알림이 켜져 있을 때만 '알림 간격' 설정 표시
                if notificationsEnabled {
                    Picker("알림 간격", selection: $selectedInterval) {
                        Text("30분 마다").tag(0)
                        Text("1시간 마다").tag(1)
                        Text("2시간 마다").tag(2)
                    }
                    .onChange(of: selectedInterval) { _ in
                        // 간격이 변경되면 기존 알림을 취소하고 다시 스케줄링
                        scheduleNotifications()
                    }
                }
            }
            
            // --- 3. 데이터 초기화 (기획서 '설정 화면' 기능) ---
            Section(header: Text("데이터 관리")) {
                Button(action: {
                    // 모든 기록 삭제
                    waterData.dailyLogs.removeAll()
                    waterData.saveLogs() // ViewModel의 saveLogs() 함수를 직접 호출
                }) {
                    Text("오늘의 모든 기록 삭제하기")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("설정") // 네비게이션 바 제목
        .navigationBarTitleDisplayMode(.inline) // 작은 제목 스타일
    }
    
    // --- 알림 관련 함수들 ---
    
    /// 1. 사용자에게 알림 권한을 요청하는 함수
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한 획득")
                // 권한을 받으면 즉시 알림 스케줄링
                scheduleNotifications()
            } else if let error = error {
                print("알림 권한 거부됨: \(error.localizedDescription)")
                notificationsEnabled = false // 토글을 다시 끔
            }
        }
    }
    
    /// 2. 설정된 간격으로 반복 알림을 예약(스케줄링)하는 함수
    func scheduleNotifications() {
        // 일단 기존 알림 모두 취소
        cancelAllNotifications()
        
        // 알림 내용 설정
        let content = UNMutableNotificationContent()
        content.title = "💧 물 마실 시간이에요!"
        content.body = "건강을 위해 수분을 보충하세요. (현재 목표: \(waterData.targetGoal)ml)"
        content.sound = .default
        
        // 알림 간격(시간) 계산
        var timeInterval: TimeInterval
        switch selectedInterval {
            case 0: timeInterval = 30 * 60 // 30분
            case 1: timeInterval = 60 * 60 // 1시간
            case 2: timeInterval = 120 * 60 // 2시간
            default: timeInterval = 60 * 60
        }
        
        // 반복 알림 설정
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        
        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: "waterlog-reminder", content: content, trigger: trigger)
        
        // 알림 센터에 추가
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 스케줄링 실패: \(error.localizedDescription)")
            } else {
                print("\(timeInterval)초 간격으로 알림 예약됨")
            }
        }
    }
    
    /// 3. 예약된 모든 알림을 취소하는 함수
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("예약된 모든 알림 취소됨")
    }
}
