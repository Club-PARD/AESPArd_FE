

import Moya
import Foundation

enum ReportsService {
    case getReportsByAnalysisId(analysisId: Int)
    
}

extension ReportsService: TargetType {
    var baseURL: URL {
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .getReportsByAnalysisId(let analysisId):
            return "/reports/\(analysisId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getReportsByAnalysisId:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getReportsByAnalysisId:
            return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}
