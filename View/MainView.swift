import SwiftUI

/**
 * 앱의 메인 화면 (기획서 2단계 '화면 설계 - 메인')
 *
 * - @StateObject: WaterData(ViewModel) 인스턴스를 생성하고, 이 뷰의 생명주기(Life Cycle) 동안 유지합니다.
 * 앱이 켜져 있는 동안 데이터가 살아있어야 하므로 @StateObject를 사용합니다.
 */
struct MainView: View {
    
    /// WaterData ViewModel의 인스턴스를 생성하여 이 뷰에서 사용할 수 있게 합니다.
    /// ViewModel의 @Published 변수(@waterData)가 변경되면 이 뷰가 자동으로 새로고침됩니다.
    @StateObject private var waterData = WaterData()
    
    /// "직접 입력" 버튼을 눌렀을 때 표시할 Alert(알림창)을 제어합니다.
    @State private var showingCustomAlert = false
    /// Alert 내부의 TextField에 입력된 물의 양을 임시로 저장합니다.
    @State private var customAmountText = ""
    
    var body: some View {
        // '설정' 화면으로 이동하기 위해 NavigationView가 필요합니다.
        NavigationView {
            
            // 뷰 요소를 수직으로 쌓습니다 (VStack)
            VStack(spacing: 20) {
                
                // --- 1. 헤더 (설정 버튼) ---
                HStack {
                    // 오른쪽 정렬을 위한 빈 공간
                    Spacer()
                    
                    // '설정' 화면으로 이동하는 버튼 (기획서 2-2 '화면 설계')
                    NavigationLink(destination: SettingsView(waterData: waterData)) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // --- 2. 진행률 시각화 (필수 기능 3) ---
                // (기획서 2-1 '화면 설계 - 중앙')
                // ZStack: 원형 그래프와 텍스트를 겹쳐서 표시
                ZStack {
                    // 원형 프로그레스 바
                    ProgressView(value: waterData.progress)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(3) // 크기 3배 확대
                    
                    // 중앙에 표시될 텍스트
                    VStack {
                        Text("\(waterData.totalToday) / \(waterData.targetGoal) ml")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(String(format: "%.0f %%", waterData.progress * 100))
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 40) // 위아래로 여백을 주어 다른 요소와 겹치지 않게 함
                
                
                // --- 3. 물 추가 버튼 (필수 기능 2) ---
                // (기획서 2-1 '화면 설계 - 중하단')
                VStack(spacing: 15) {
                    Text("빠른 추가")
                        .font(.headline)
                    
                    // 버튼들을 수평으로 배치 (HStack)
                    HStack(spacing: 20) {
                        // +200ml 버튼
                        Button("+200 ml") {
                            waterData.addLog(amount: 200)
                        }
                        .buttonStyle(WaterButtonStyle())
                        
                        // +500ml 버튼
                        Button("+500 ml") {
                            waterData.addLog(amount: 500)
                        }
                        .buttonStyle(WaterButtonStyle())
                        
                        // 직접 입력 버튼
                        Button("직접 입력") {
                            customAmountText = "" // 입력창 초기화
                            showingCustomAlert = true // 알림창 띄우기
                        }
                        .buttonStyle(WaterButtonStyle(isPrimary: false))
                    }
                }
                
                // --- 4. 시간별 기록 리스트 (필수 기능 4) ---
                // (기획서 2-1 '화면 설계 - 하단')
                VStack {
                    Text("오늘의 기록")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                        .padding(.horizontal)
                    
                    // 스크롤 가능한 리스트
                    List {
                        // waterData의 dailyLogs 배열을 순회하며 동적으로 뷰 생성
                        ForEach(waterData.dailyLogs) { log in
                            HStack {
                                Text("\(log.amount) ml")
                                    .fontWeight(.bold)
                                Spacer()
                                Text(log.date, style: .time) // 시간을 "오후 2:30" 형식으로 표시
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    // List의 기본 스타일을 깔끔하게 변경
                    .listStyle(PlainListStyle())
                }
                
                Spacer() // 모든 요소를 화면 상단으로 밀어 올림
            }
            .navigationTitle("WaterLog (오늘의 수분)") // 화면 상단 제목
            .navigationBarHidden(true) // 기본 네비게이션 바는 숨기고 커스텀 헤더(설정 버튼) 사용
            
            // "직접 입력" 알림창(Alert) 정의
            .alert("얼마나 마셨나요?", isPresented: $showingCustomAlert) {
                // 숫자를 입력받는 TextField (iOS 16+ 스타일)
                TextField("ml 단위로 입력 (예: 350)", text: $customAmountText)
                    .keyboardType(.numberPad) // 숫자 키패드만 표시
                
                Button("추가") {
                    // 입력된 텍스트를 숫자로 변환
                    if let amount = Int(customAmountText) {
                        waterData.addLog(amount: amount)
                    }
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

/// 메인 화면에서 사용할 커스텀 버튼 스타일
struct WaterButtonStyle: ButtonStyle {
    var isPrimary: Bool = true // 기본 버튼(true)인지 보조 버튼(false)인지
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 100)
            .background(isPrimary ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isPrimary ? .white : .blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // 눌렀을 때 작아지는 효과
    }
}
