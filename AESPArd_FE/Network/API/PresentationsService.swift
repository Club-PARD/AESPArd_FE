
import Moya
import Foundation




// MARK: - 홈페이지에&모달창에서 발표 리스트를 불러오거나 삭제 할때 사용하는 서비스

enum PresentationsService {
    case getPresentationLatestById(userId: String)
    case getPresentationFavoritesById(userId: String)
    case patchToggleFavofiteById(presentationId: String)
    case deleteSelectedPresentations(presentationIds: [String])
    case getAllPresentations(userId: String)
    case deleteAllDeletePresentation(userId: String)
    case searchPresentations(userId: String, searchTerm: String)
    
    case deleteOnePresentation(presentationId: String)
    case pathPresentationNameByPresentaion(presentationId: String, name: String)
}

extension PresentationsService: TargetType {
    var baseURL: URL {
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .getPresentationLatestById(let userId):
            return "/presentations/user/\(userId)/latest"
        case .getPresentationFavoritesById(let userId):
            return "/presentations/user/\(userId)/favorites"
        case .patchToggleFavofiteById(let presentationId):
            return "/presentations/\(presentationId)/toggle-favorite"
        case .deleteSelectedPresentations:
            return "/presentations/batch-delete"
        case .getAllPresentations(let userId):
            return "/presentations/user/\(userId)/modal-list"
        case .deleteAllDeletePresentation(let userId):
            return "/presentations/\(userId)/all-delete"
        case .searchPresentations(let userId, _):
            return "/presentations/search/\(userId)"
        
        case .deleteOnePresentation(let presentationId):
            return "/presentations/\(presentationId)/one-delete"
        case .pathPresentationNameByPresentaion(let presentationId, _):
            return "/presentations/\(presentationId)/update-name"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPresentationLatestById:
            return .get
        case .getPresentationFavoritesById:
            return .get
        case .patchToggleFavofiteById:
            return .patch
        case .deleteSelectedPresentations:
            return .delete
        case .getAllPresentations:
            return .get
        case .deleteAllDeletePresentation:
            return .delete
        case .searchPresentations:
            return .get
        case .deleteOnePresentation:
            return .delete
        case .pathPresentationNameByPresentaion :
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .getPresentationLatestById:
            return .requestPlain
            
        case .getPresentationFavoritesById:
            return .requestPlain
            
        case .patchToggleFavofiteById:
            return .requestPlain
            
        case .deleteSelectedPresentations(let presentationIds):
            return .requestCustomJSONEncodable(presentationIds, encoder: JSONEncoder())
        case .getAllPresentations:
            return .requestPlain
        
        case .deleteAllDeletePresentation:
            return .requestPlain
            
        case .searchPresentations(_, let searchTerm):
            return .requestParameters(parameters: ["searchTerm": searchTerm], encoding: URLEncoding.default)
            
        case .deleteOnePresentation(let presentationId):
            return .requestPlain
            
        case .pathPresentationNameByPresentaion(let presentationId, let name):
            return .requestCustomJSONEncodable(name, encoder: JSONEncoder())
        }
        
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}
