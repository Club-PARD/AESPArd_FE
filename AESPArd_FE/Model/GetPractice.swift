//
//  GetPractice.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/30/24.
//

import Foundation

struct GetPractice: Codable {
    var id: Int
    var practiceName: String
    var createdAt: String
    var totalScore: Int
    var analysisId: Int
    var videoKey: String
}
