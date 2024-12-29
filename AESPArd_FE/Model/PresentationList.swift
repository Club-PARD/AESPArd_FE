//
//  PresentationList.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/28/24.
//


import Foundation

struct PresentationList: Codable {
    let presentationId: String
    let presentationName: String
    let toggleFavorite: Bool
    let totalScore: Int
    let totalPractices: Int
    let updatedAtText: String
}
