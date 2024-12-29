//
//  UploadAudioResponse.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/29/24.
//

import Foundation

struct UploadAudioResponse: Codable {
    let success: Bool
    let message: String
    let audioURL: String? // If the server returns a URL or path to the uploaded audio
}
