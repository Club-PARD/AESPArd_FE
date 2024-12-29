//
//  PresentationList.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/29/24.
//

import Foundation

struct PresentationList: Codable {
    let presentationId: String
    let presentationName: String
    let toggleFavorite: Bool
    let totalScore: Int
    let totalPractices: Int
    let updatedAtText: String
    let showMeOnScreen: Bool
    let showTimeOnScreen: Bool
}
