//
//  Notifications.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/26/24.
//

import Foundation

// CamaeraViewController 와 CameraOveralyViewController에서 쓰이는 노티피케이션들

extension Notification.Name {
    static let backButtonTapped = Notification.Name("BackButtonTapped")
    static let startStopRecordingButtonTapped = Notification.Name("StartStopRecordingButtonTapped")
    static let updateRecordingTime = Notification.Name("UpdateRecordingTime")
    static let updateEyeTrackingTime = Notification.Name("UpdateEyeTrackingTime")
    static let updateStartStopButtonTitle = Notification.Name("UpdateStartStopButtonTitle")
    static let updateGazePoint = Notification.Name("UpdateGazePoint")
    static let timeoutOccurred = Notification.Name("TimeoutOccurred")
    static let coverScreenSelected = Notification.Name("CoverScreenSelected")
    static let updateUIAfterRecording = Notification.Name("UpdateUIAfterRecording")
    static let setTimeLabelVisibility = Notification.Name("SetTimeLabelVisibility")
}
