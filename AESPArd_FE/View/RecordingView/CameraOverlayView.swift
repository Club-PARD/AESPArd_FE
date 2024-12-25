//
//  OverlayView.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/25/24.
//

import UIKit

class CameraOverlayView: UIView {
    
    var isDebugMode: Bool = false {
        didSet {
            eyeTrackingTimeLabel.isHidden = !isDebugMode
            aimImageView.isHidden = !isDebugMode
        }
    }
    
    
   
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 촬영 시작 버튼
    let startStopRecordingButton: UIButton = {
        let config = UIButton.Configuration.filled()
        let button = UIButton(configuration: config)
        button.setTitle("촬영 시작하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // 촬영 시간 타이머 라벨
    let recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 화면 다 가릴때 쓰는 UIView
    private let fullScreenCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    
    // MARK: - 시선 추적 UI
    
    let eyeTrackingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    let aimImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Cursor"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        
        self.addSubview(backButton)
        
        self.addSubview(startStopRecordingButton)
        self.addSubview(recordingTimeLabel)
        
        self.addSubview(eyeTrackingTimeLabel)
        self.addSubview(aimImageView)
        
        NSLayoutConstraint.activate([
            
            // Back Button Constraints
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            startStopRecordingButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            startStopRecordingButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            
            recordingTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recordingTimeLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            eyeTrackingTimeLabel.topAnchor.constraint(equalTo: recordingTimeLabel.bottomAnchor, constant: 8),
            eyeTrackingTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            aimImageView.widthAnchor.constraint(equalToConstant: 30),
            aimImageView.heightAnchor.constraint(equalToConstant: 30),
            aimImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            aimImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
    }
    
    func toggleFullScreenCover(isHidden: Bool) {
        fullScreenCoverView.isHidden = isHidden
    }
    
}
