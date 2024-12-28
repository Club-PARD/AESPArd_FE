//
//  PresentationService.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/28/24.
//

import Moya
import Foundation


enum PresentationService {
    case postNewPresentation(newPresentation: NewPresentation, wavData: Data)
}

extension PresentationService: TargetType {
    var baseURL: URL {
        // Adjust to your actual base URL
        return URL(string: URLClass().baseURL)!
    }
    
    var path: String {
        switch self {
        case .postNewPresentation:
            return "/presentations/new-presentation-with-practice"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postNewPresentation:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postNewPresentation(let newPresentation, let wavData):
            // 1) Convert NewPresentation to JSON
            guard let jsonData = try? JSONEncoder().encode(newPresentation) else {
                // If encoding fails, you could handle error or return empty
                return .requestPlain
            }
            
            // 2) Create an array of MultipartFormData
            var formData = [MultipartFormData]()
            
            // Part A: The audio file
            formData.append(
                MultipartFormData(
                    provider: .data(wavData),
                    name: "audioFile",            // The form field name for audio
                    fileName: "audio.wav",
                    mimeType: "audio/wav"
                )
            )
            
            // Part B: The JSON for NewPresentation
            //   We'll name it "json". The server should parse this
            //   as a JSON object in the second part.
            formData.append(
                MultipartFormData(
                    provider: .data(jsonData),
                    name: "json",                // The form field name for JSON
                    fileName: "presentation.json",
                    mimeType: "application/json"
                )
            )
            
            // 3) Return an uploadMultipart task
            return .uploadMultipart(formData)
        }
    }
    
    var headers: [String : String]? {
        // Include any auth headers if necessary
        return ["Content-Type": "multipart/form-data"]
    }
    
    // Mock or example data for testing in the simulator or with unit tests
    var sampleData: Data {
        switch self {
        case .postNewPresentation:
            return """
                {
                  "userId": "1234",
                  "presentationName": "My Sample",
                  "idealMinTime": 5.0,
                  "idealMaxTime": 8.0,
                  "eyeTrackingPercentage": 80,
                  "audioFilePath": "unusedInThisApproach",
                  "videoKey": "myVideoKey",
                  "showTimeOnScreen": true,
                  "showMeOnScreen": false
                }
                """.data(using: .utf8)!
        }
    }
}
