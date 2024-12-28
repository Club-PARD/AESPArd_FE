//
//  PostPresentation.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/28/24.
//

import Foundation

struct NewPresentation: Codable {
    var userId: String
    var presentationName: String
    var idealMinTime: Double
    var idealMaxTime: Double
    var eyeTrackingPercentage: Int
    var audioFilePath: String
    var videoKey: String
    var showTimeOnScreen: Bool
    var showMeOnScreen: Bool
}
