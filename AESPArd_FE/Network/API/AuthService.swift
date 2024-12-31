//
//  AuthService.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/27/24.
//

// 로그인 관련 API

import Moya
import Foundation

//MARK: - 애플 로그인 요청 모델
struct AppleLoginRequest: Encodable {
    let userID: String
    let firstName: String
    let lastName: String
    let email: String
    let authorizationCode: String
    let identifierToken: String
}

//MARK: - API 정의
enum LoginService {
    case postAppleLogin(data: AppleLoginRequest)
}

extension LoginService: TargetType {
    var baseURL: URL {
        return URL(string: URLClass().baseURL)!
    }

    var path: String {
        switch self {
        case .postAppleLogin:
            return "/users/appleLogin"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postAppleLogin:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .postAppleLogin(let data):
            return .requestJSONEncodable(data)
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        return Data()
    }
}
