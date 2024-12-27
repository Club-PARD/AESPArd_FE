//
//  NetworkManager.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/27/24.
//


// MARK: - NewrkManager 중앙 매니저 여기서 모든 통신 메소드를 정의하고 ViewController 마다 NetwrkManager 불러서 사용하면 됨


import Moya
import Foundation

final class NetworkManager {
    // Singleton if you want a single shared instance
    // 싱글턴 패턴이란? 클래스 인스턴스를 여기저기 여러개 생성하는게 아니라 하나만 생성해서 여러군데서 같이 사용하는 것
    static let shared = NetworkManager()
    private init() {}
    
    // Create a MoyaProvider
    // Provider를 등록해주야 함. 만든 각각의 API에 대한 중계 유통업자임
    //private let authProvider = MoyaProvider<AuthService>()
    private let userServiceProvider = MoyaProvider<UserService>(
        plugins: [
            // 디버깅하는데 도움주는 Moya 플러그인 나중에는 주석 처리 할 것
            NetworkLoggerPlugin() // helpful for logging network requests
        ]
    )
    
    // MARK: - User 정보 불러오는 메소드
    
    func fetchUserById(userId: String, completion: @escaping (Result<[User], Error>) -> Void) {
        userServiceProvider.request(.getUserById(userId: userId)) { result in
            switch result {
            case .success(let response):
                do {
                    // Parse the JSON into [User]
                    let user = try JSONDecoder().decode(User.self, from: response.data)
                    completion(.success([user]))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}

