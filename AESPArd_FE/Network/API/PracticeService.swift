

import Moya
import Foundation

enum PracticeService {
    case getPractice(presentationId: String)
    case getRecentScores(presentationId: String)
    case getSinglePracticeInLoadingScreen(presentationId: String)
    
    case deleteOnePracticeByPracticeId(practiceId: String)
    case deleteSelectedPractice(practiceIds: [String])
    case patchPracticeNameByPracticeId(practiceId: String, name: String)
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
        case .getSinglePracticeInLoadingScreen:
            return "/practices/recent"

        case .deleteOnePracticeByPracticeId(let practiceId):
            return "/practices/\(practiceId)/one-delete"
        case .deleteSelectedPractice :
            return "/practices/batch-delete"
        case .patchPracticeNameByPracticeId(let practiceId, _):
            return "/practices/\(practiceId)/update-name"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPractice:
            return .get
        case .getRecentScores:
            return .get
        case .getSinglePracticeInLoadingScreen:
            return .get
        case .deleteOnePracticeByPracticeId :
            return .delete
        case .deleteSelectedPractice :
            return .delete
        case .patchPracticeNameByPracticeId:
            return .patch
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
        case .getSinglePracticeInLoadingScreen(let presentationId):
            return .requestParameters(
                parameters: ["presentationId": presentationId],
                encoding: URLEncoding.default)
            
        case .deleteOnePracticeByPracticeId(let practiceId):
            return .requestPlain
            
        case .deleteSelectedPractice(let practiceIds):
            return .requestCustomJSONEncodable(practiceIds, encoder: JSONEncoder())
        
        case .patchPracticeNameByPracticeId(let practiceId, let name):
            return .requestCustomJSONEncodable(name, encoder: JSONEncoder())
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}
