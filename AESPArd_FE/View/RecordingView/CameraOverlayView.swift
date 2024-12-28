//
//  OverlayView.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/25/24.
//

import UIKit



class CameraOverlayView: UIView {
    
    var isDebugMode: Bool = false
    
    var isInTime: Bool = false {
        didSet {
            recordingTimeLabel.textColor = isInTime ? .black : .white
            recordingTimeLabel.backgroundColor = isInTime ? .white : .red
        }
    }
    
    var isFullScreen: Bool = false {
        didSet {
            fullScreenCoverView.isHidden = !isFullScreen
            fullScreenDescriptionLabel.isHidden = !isFullScreen
        }
    }
    
    
    private var aimCenterXConstraint: NSLayoutConstraint?
    private var aimCenterYConstraint: NSLayoutConstraint?
    
    
    // 시선 동그라미가 중심에서 시작하게 하기 위해서 필요한 코드
    var isRecording : Bool = false {
        didSet{
            updateAimConstraintsForRecording(isRecording)
        }
    }
    
    
    let backButton: UIButton = {
        let button = UIButton()
        
        // Load the image and set its rendering mode to .alwaysTemplate
        if let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(backImage, for: .normal)
        }
        
        // Set the tintColor to white
        button.tintColor = .white
        
        // Disable autoresizing mask to use Auto Layout
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
   
    
    // 촬영 시작 버튼
    let startStopRecordingButton: UIButton = {
        let button = UIButton()
        button.setTitle("촬영 시작하기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
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
        label.backgroundColor = .red
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 화면 다 가릴때 쓰는 UIView
    private let fullScreenCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.43, green: 0.44, blue: 0.47, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    
    let fullScreenDescriptionLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "촬영 중 화면은 보이지 않지만,\n촬영이 끝난 후 리포트에선\n녹화 화면을 볼 수 있어요!"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        label.textColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    
    // MARK: - 시선 추적 UI
    
    let eyeTrackingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    let aimImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Cursor"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.isHidden = true
        return imageView
    }()
    
    let faceGuideImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "FaceGuide"))
        imageView.contentMode = .scaleAspectFit  // 비율 유지
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false
        return imageView
    }()
    
    let descriptionLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "얼굴을 프레임에 맞추고\n중심의 점을 바라봐주세요"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        label.textColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
        return label
    }()
    
    private let centerCircleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        view.isHidden = false
        return view
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
       
        self.insertSubview(fullScreenCoverView, at: 0)  // Cover at bottom
        self.insertSubview(fullScreenDescriptionLabel, at: 1)
        
        self.addSubview(backButton)
        
        self.addSubview(startStopRecordingButton)
        self.addSubview(recordingTimeLabel)
        
        self.addSubview(eyeTrackingTimeLabel)
        self.addSubview(aimImageView)
        
        self.addSubview(faceGuideImageView)
        self.addSubview(descriptionLabel)
        self.addSubview(centerCircleView)
        
        
        // 1) Create constraints
        aimCenterXConstraint = aimImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        aimCenterYConstraint = aimImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        
        // 2) Activate center constraints initially
        //    Because we want the aimImageView to start in the center
        aimCenterXConstraint?.isActive = true
        aimCenterYConstraint?.isActive = true
        
        
        NSLayoutConstraint.activate([
            
            // Back Button Constraints
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 12),
            
            startStopRecordingButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            startStopRecordingButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            startStopRecordingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            startStopRecordingButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            startStopRecordingButton.heightAnchor.constraint(equalToConstant: 52),
            
            recordingTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recordingTimeLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 12),
            recordingTimeLabel.widthAnchor.constraint(equalToConstant: 94),
            recordingTimeLabel.heightAnchor.constraint(equalToConstant: 32),
            
            eyeTrackingTimeLabel.topAnchor.constraint(equalTo: recordingTimeLabel.bottomAnchor, constant: 8),
            eyeTrackingTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            aimImageView.widthAnchor.constraint(equalToConstant: 30),
            aimImageView.heightAnchor.constraint(equalToConstant: 30),
            
            fullScreenCoverView.topAnchor.constraint(equalTo: self.topAnchor),
            fullScreenCoverView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            fullScreenCoverView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            fullScreenCoverView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            fullScreenDescriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            fullScreenDescriptionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            fullScreenDescriptionLabel.widthAnchor.constraint(equalToConstant: 213),
            fullScreenDescriptionLabel.heightAnchor.constraint(equalToConstant: 67),
            
            // 녹화 시작하면 사라질 요소들
            
            // 얼굴 프레임
            faceGuideImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),
            faceGuideImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 60),
            faceGuideImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            // If you want to ensure it also can't exceed the view's width (useful on smaller screens)
            faceGuideImageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.8),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 48),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 213),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 50),
            
            centerCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            centerCircleView.widthAnchor.constraint(equalToConstant: 10), // Adjust size as needed
            centerCircleView.heightAnchor.constraint(equalTo: centerCircleView.widthAnchor), // Maintain aspect ratio
            
        ])
        
        
        if isDebugMode {
            eyeTrackingTimeLabel.isHidden = false
            aimImageView.isHidden = false
        } else {
            eyeTrackingTimeLabel.isHidden = true
            aimImageView.isHidden = true
        }
        
    }
    
    private func updateAimConstraintsForRecording(_ recording: Bool) {
        if recording {
            aimCenterXConstraint?.isActive = false
            aimCenterYConstraint?.isActive = false
            
            faceGuideImageView.isHidden = true
            descriptionLabel.isHidden = true
            centerCircleView.isHidden = true
        } else {
            aimCenterXConstraint?.isActive = true
            aimCenterYConstraint?.isActive = true
            
            faceGuideImageView.isHidden = false
            descriptionLabel.isHidden = false
            centerCircleView.isHidden = false
        }
        
        // Animate constraint changes if desired
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerCircleView.layer.cornerRadius = centerCircleView.frame.width / 2
    }
    
}


