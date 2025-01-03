//
//  PresentationService.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/28/24.
//

import Moya
import Foundation

//MARK: - 촬영 종료 후 새로운 발표 혹은 연습 서버에 보낼 때 사용하는 서비스

enum NewPresentationAndNewPracticeService {
    case postNewPresentation(newPresentation: NewPresentation)
    case postPracticeAndAudio(presentationId: String, videoKey: String, eyePercentage: Int, wavData: Data)
}

extension NewPresentationAndNewPracticeService: TargetType {
    var baseURL: URL {
        // Adjust to your actual base URL
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .postNewPresentation:
            return "/presentations/create-presentation"
        case .postPracticeAndAudio(let presentationId, _, _, _):
            return "/practices/\(presentationId)/add-practice"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postNewPresentation, .postPracticeAndAudio :
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postNewPresentation(let newPresentation):
            // Encode Presentation struct to JSON
            return .requestJSONEncodable(newPresentation)

        case .postPracticeAndAudio(_, let videoKey, let eyePercentage, let wavData):
            var multipartData: [MultipartFormData] = []
            
            if let videoKeyData = videoKey.data(using: .utf8) {
                let videoKeyMultipart = MultipartFormData(
                    provider: .data(videoKeyData),
                    name: "videoKey",
                    mimeType: "text/plain"
                )
                multipartData.append(videoKeyMultipart)
            } else {
                print("Failed to encode videoKey to data.")
            }
            
            // Add eyeTrackingPercentage as a separate text field
            let eyePercentageString = String(eyePercentage)
            if let eyePercentageData = eyePercentageString.data(using: .utf8) {
                let eyePercentageMultipart = MultipartFormData(
                    provider: .data(eyePercentageData),
                    name: "eyePercentage",
                    mimeType: "text/plain"
                )
                multipartData.append(eyePercentageMultipart)
            } else {
                print("Failed to encode eyeTrackingPercentage to data.")
            }
            
            // Add the audio file
            let audioMultipart = MultipartFormData(
                provider: .data(wavData),
                name: "audioFile",
                fileName: "audio.wav",
                mimeType: "audio/wav"
            )
            multipartData.append(audioMultipart)
            
            return .uploadMultipart(multipartData)
        }
    }
    
    
    var headers: [String : String]? {
        switch self {
        case .postPracticeAndAudio :
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

