

import Moya
import Foundation

enum PracticeService {
    case getPractice(presentationId: String)
    case getRecentScores(presentationId: String)
    case getAnalysisIdInLoadingScreen(userId: String)
}

extension PracticeService: TargetType {
    var baseURL: URL {
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .getPractice:
            return "/practices"
        case .getRecentScores:
            return "/practices/recent-scores"
        case .getAnalysisIdInLoadingScreen:
            return "/practices/recent"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPractice:
            return .get
        case .getRecentScores:
            return .get
        case .getAnalysisIdInLoadingScreen:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getPractice(let presentationId):
            return .requestParameters(
                parameters: ["presentationId": presentationId],
                encoding: URLEncoding.default
            )
        case .getRecentScores(let presentationId):
            return .requestParameters(
                parameters: ["presentationId": presentationId],
                encoding: URLEncoding.default
            )
        case .getAnalysisIdInLoadingScreen(let userId):
            return .requestParameters(
                parameters: ["userId": userId],
                encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}
