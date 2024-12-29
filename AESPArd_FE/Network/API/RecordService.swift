

import Moya
import Foundation

enum RecordService {
    case getRecordAverage
    
}

extension RecordService: TargetType {
    var baseURL: URL {
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .getRecordAverage:
            return "/records/recent-average"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getRecordAverage:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getRecordAverage:
            return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}
