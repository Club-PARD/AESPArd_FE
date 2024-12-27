//
//  User.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/27/24.
//

import Foundation

struct User: Codable {
    let userId: String?
    let userName: String?
    let email: String?
    let presentations: [Presentation]?
}


struct Presentation: Codable {
    let presentationId: String?
    let user: String?
    let presentationName: String?
    let createdAt: String?
    let updatedAt: String?
    let totalPractices: Int?
    let totalScore: Int?
    let toggleFavorite: Bool?
    let idealMaxTime: String?
    let idealMinTime: String?
}
