//
//  UserService.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/27/24.
//

// MARK: - User API 유저 정보 가져올때 사용함

import Moya
import Foundation

// MARK: - enum을 하나 선언해서 사용될 target들을 작성합니다. 어떤 target? 사용할 메소드라고 보면됨 get, post, delete....
enum UserService {
    case getUserNameById(userId: String)
    // updateUser 안씀. Moya 구조 파악하기 위해서 보라고 남겨둘게
    case updateUser(id: Int, name: String, email: String)
}


// MARK: - Moya는 MoyaProvider<TargetType>으로 request를 수행하기 때문에, 위에서 정의한 API가 TargetType 프로토콜을 구현해야합니다. extension을 만들어 TargetType 프로토콜을 채택하면, 아래와 같은 프로퍼티들을 구현 해야합니다. 무슨 말이냐하면 Provider가 쿠팡 택배 기사임 근데 너가 어디로 배송할지 주소나 어디 문앞에 놓아주세요 같은거 적어야 배송기사가 배송해줄거 아님? 그 정보를 프로토콜로 적어놓는 거임
// baseURL: 서버의 endpoint 도메인
// path: 도메인 뒤에 추가 될 path (/users, /documents, ...)
// method: HTTP method (GET, POST, ...)
// sampleData: 테스트용 Mock Data
// task: request에 사용될 파라미터 .requestPlain: no param, .requestParameters(parameter:, encoding:)
// headers: HTTP Header


extension UserService: TargetType {
    var baseURL: URL {
        return URL(string: URLClass().baseURL)!
//        return URL(string: "https://api.example.com")!
    }
    
    var path: String {
        switch self {
        case .getUserNameById(let userId):
            return "/users/\(userId)/name"
        // upateUser 예시용 쓰지마
        case .updateUser(let id, _, _):
            return "/users/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserNameById:
            return .get
        // upateUser 예시용 쓰지마
        case .updateUser:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .getUserNameById:
            return .requestPlain
            
        // upateUser 예시용 쓰지마
        case .updateUser(_, let name, let email):
            let params = ["name": name, "email": email]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
