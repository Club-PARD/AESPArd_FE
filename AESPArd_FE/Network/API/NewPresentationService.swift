//
//  PresentationService.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/28/24.
//

import Moya
import Foundation

//MARK: - 촬영 종료 후 새로운 발표 혹은 연습 서버에 보낼 때 사용하는 서비스

enum NewPresentationService {
    case postNewPresentation(newPresentation: NewPresentation)
    case postAudio(wavData: Data)
}

extension NewPresentationService: TargetType {
    var baseURL: URL {
        // Adjust to your actual base URL
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .postNewPresentation:
            return "/presentations/new-presentation-with-practice"
        case .postAudio:
            return  "/audio/upload"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postNewPresentation, .postAudio:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postNewPresentation(let newPresentation):
            // Encode Presentation struct to JSON
            return .requestJSONEncodable(newPresentation)
            
        case .postAudio(let wavData):
            // Create MultipartFormData for audio file
            let formData = MultipartFormData(
                provider: .data(wavData),
                name: "audioFile",             // Ensure this matches your server's expected field name
                fileName: "audio.wav",         // Corrected filename
                mimeType: "audio/wav"
            )
            return .uploadMultipart([formData])
        }
    }
    
    var headers: [String : String]? {
        switch self{
        case .postAudio:
            return ["Content-Type": "multipart/form-data"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    
    
    
    
    // Mock or example data for testing in the simulator or with unit tests
//    var sampleData: Data {
//        switch self {
//        case .postNewPresentation:
//            return """
//                {
//                  "userId": "1234",
//                  "presentationName": "My Sample",
//                  "idealMinTime": 5.0,
//                  "idealMaxTime": 8.0,
//                  "eyeTrackingPercentage": 80,
//                  "videoKey": "myVideoKey",
//                  "showTimeOnScreen": true,
//                  "showMeOnScreen": false
//                }
//                """.data(using: .utf8)!
//        case .postAudio:
//            return "".data(using: .utf8)!
//        }
//    }
}
