//
//  Notifications.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/26/24.
//

import Foundation

extension Notification.Name {
    static let backButtonTapped = Notification.Name("BackButtonTapped")
    static let startStopRecordingButtonTapped = Notification.Name("StartStopRecordingButtonTapped")
    static let updateRecordingTime = Notification.Name("UpdateRecordingTime")
    static let updateEyeTrackingTime = Notification.Name("UpdateEyeTrackingTime")
    static let updateStartStopButtonTitle = Notification.Name("UpdateStartStopButtonTitle")
    static let updateGazePoint = Notification.Name("UpdateGazePoint")
}
