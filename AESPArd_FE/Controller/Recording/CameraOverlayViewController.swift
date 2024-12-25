//
//  CameraOverlayerViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/26/24.
//

import UIKit

class CameraOverlayViewController: UIViewController {
    
    private var overlayView: CameraOverlayView!
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        // Initialize the overlayView without calling super.loadView()
        overlayView = CameraOverlayView()
        self.view = overlayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .clear
        
        setupActions()
    }
    
    private func setupActions() {
        overlayView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        overlayView.startStopRecordingButton.addTarget(self, action: #selector(startStopRecordingTapped), for: .touchUpInside)
    }
    
    
    @objc private func backButtonTapped() {
        NotificationCenter.default.post(name: .backButtonTapped, object: nil)
    }
    
    @objc private func startStopRecordingTapped() {
        NotificationCenter.default.post(name: .startStopRecordingButtonTapped, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecordingTimeLabel(_:)), name: .updateRecordingTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEyeTrackingTimeLabel(_:)), name: .updateEyeTrackingTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGazePoint(_:)), name: .updateGazePoint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateStartStopButtonTitle(_:)), name: .updateStartStopButtonTitle, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func updateRecordingTimeLabel(_ notification: Notification) {
        if let timeString = notification.userInfo?["time"] as? String {
            overlayView.recordingTimeLabel.text = timeString
        }
    }
    
    @objc private func updateEyeTrackingTimeLabel(_ notification: Notification) {
        if let timeString = notification.userInfo?["time"] as? String {
            overlayView.eyeTrackingTimeLabel.text = timeString
        }
    }
    
    @objc private func updateStartStopButtonTitle(_ notification: Notification) {
        if let title = notification.userInfo?["title"] as? String {
            self.overlayView.startStopRecordingButton.setTitle(title, for: .normal)
        }
    }
    
    @objc private func updateGazePoint(_ notification: Notification) {
        if let gazePointValue = notification.userInfo?["gazePoint"] as? NSValue {
            let gazePoint = gazePointValue.cgPointValue
            DispatchQueue.main.async {
                self.overlayView.aimImageView.center = gazePoint
            }
        }
    }
    
}
