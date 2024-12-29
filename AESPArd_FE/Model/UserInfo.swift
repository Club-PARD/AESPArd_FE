//
//  UserInfo.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/29/24.
//

import Foundation


struct UserInfo: Codable {
    let userID: String
    let firstName: String
    let lastName: String
    let email: String
    let authorizationCode: String
    let identityToken: String
}
