import Foundation

/**
 * 물 마시기 기록을 위한 데이터 모델 (기획서 3단계 '데이터 구조')
 *
 * - Identifiable: List에서 각 항목을 고유하게 식별하기 위해 필요합니다.
 * - Codable: 데이터를 JSON 형태로 변환하여 기기에 저장(Archiving)하기 위해 필요합니다.
 */
struct DrinkLog: Identifiable, Codable {
    
    /// 각 기록을 구별하기 위한 고유 ID (Identifiable 프로토콜 요구사항)
    var id = UUID()
    
    /// 물을 마신 정확한 날짜와 시간
    let date: Date
    
    /// 마신 물의 양 (단위: ml)
    let amount: Int
}
