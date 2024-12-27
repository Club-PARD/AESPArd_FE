//import Foundation
//
//// 서버와 통신할 때 사용되는 기본 사용자 모델이에요!
//struct User: Codable {
//    let id: Int?
//    let name: String
//    let part: String
//    let age: Int
//}
//
//struct UpdateUserRequest: Codable {
//    let name: String
//    let part: String
//    let age: String
//}
//
//// 서버로부터의 성공/실패 응답을 처리하는 구조체입니당:)
//struct APIResponse: Codable {
//    let success: Bool
//}
//
//class APIService {
//    static let shared = APIService()
//    private let networkManager = NetworkManager.shared
//    
//    private init() {}
//    
//    // MARK: - 사용자 목록 조회 메서드에요~
//    // 특정 파트의 사용자들을 가져오는 GET 요청이에요!
//    // @escaping은 네트워크 작업은 시간이 걸리기에 함수가 끝나도 나중에 결과를 처리해야되기 때문에 존재!
//    func getUsers(part: String, completion: @escaping (Result<[User], Error>) -> Void) {
//        networkManager.request("/user",
//                             method: "GET",
//                             parameters: ["part": part],
//                             completion: completion)
//    }
//    
//    // MARK: - 새로운 사용자 생성 메서드에요~
//    // 새로운 사용자를 생성하는 POST 요청이에요!
//    func createUser(user: User, completion: @escaping (Result<APIResponse, Error>) -> Void) {
//        networkManager.request("/user",
//                             method: "POST",
//                             body: user,
//                             completion: completion)
//    }
//    
//    // MARK: - 사용자 정보 업데이트 메서드에요~
//    // 특정 ID의 사용자 정보를 수정하는 PATCH 요청이에요!
//    func updateUser(id: Int, user: UpdateUserRequest, completion: @escaping (Result<APIResponse, Error>) -> Void) {
//        networkManager.request("/user/\(id)",
//                             method: "PATCH",
//                             body: user,
//                             completion: completion)
//    }
//    
//    // MARK: - 사용자 삭제 메서드에요~
//    // 특정 ID의 사용자를 삭제하는 DELETE 요청이에요!
//    func deleteUser(id: Int, completion: @escaping (Result<APIResponse, Error>) -> Void) {
//        networkManager.request("/user/\(id)",
//                             method: "DELETE",
//                             completion: completion)
//    }
//}
