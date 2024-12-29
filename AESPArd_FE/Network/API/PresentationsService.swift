//
//  UserService.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/27/24.
//

import Moya
import Foundation

// MARK: - enum을 하나 선언해서 사용될 target들을 작성합니다. 어떤 target? 사용할 메소드라고 보면됨 get, post, delete....
enum PresentationsService {
    case getPresentationLatestById(userId: String)
    case getPresentationFavoritesById(userId: String)
    case patchToggleFavofiteById(presentationId: String)
    case deleteSelectedPresentations(presentationIds: [String])
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
        }
        
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}
