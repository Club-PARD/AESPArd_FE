//
//  CameraViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/20/24.
//

import UIKit
import AVFoundation
import Photos
import Vision

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    private var captureSession: AVCaptureSession!
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // 녹화 시작 시간을 기록할 변수 추가
    private var recordingStartTime: Date?
    //실시간 타이머
    private var recordingTimer: Timer?
    
    private var isRecording = false
    private var isScreenCovered = false // 화면 가리기 상태 변수
    
    
    private let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("●", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 녹화 시간 표시 라벨
    private let recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // 기본적으로 숨김
        return label
    }()
    
    //화면 가리기 파란색 UIView
    private let fullScreenBlueView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue // 배경색을 파란색으로 설정
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // 기본적으로 숨김
        return view
    }()
    
    // 화면 가리기 버튼
    private let toggleScreenCoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cover Screen", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(toggleScreenCover), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Check permission
        checkCameraAuthorization()
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        case .authorized:
            setupSession()
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Access Needed",
                                      message: "Please enable camera access in Settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No back camera available.")
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                self.videoDeviceInput = cameraInput
            } else {
                print("Unable to add camera input.")
                return
            }
        } catch {
            print("Error: \(error)")
            return
        }
        
        // 오디오 입력 장치 설정
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              captureSession.canAddInput(audioInput) else {
            print("Cannot add audio input")
            return
        }
        captureSession.addInput(audioInput)
        
        let movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
            movieFileOutput = movieOutput
        }
        
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        view.addSubview(fullScreenBlueView)
        
        // Bring shutter button to front
        view.addSubview(shutterButton)
        view.addSubview(recordingTimeLabel)
        view.addSubview(toggleScreenCoverButton)
        
        NSLayoutConstraint.activate([
            fullScreenBlueView.topAnchor.constraint(equalTo: view.topAnchor),
            fullScreenBlueView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fullScreenBlueView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fullScreenBlueView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shutterButton.widthAnchor.constraint(equalToConstant: 80),
            shutterButton.heightAnchor.constraint(equalToConstant: 80),
            
            recordingTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recordingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toggleScreenCoverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleScreenCoverButton.bottomAnchor.constraint(equalTo: shutterButton.topAnchor, constant: -20)
            
        ])
        
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        
        captureSession.startRunning()
    }
    
    @objc private func shutterButtonTapped() {
        guard let movieFileOutput = self.movieFileOutput else { return }
        
        if !isRecording {
            // Start recording
            let outputDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".mov"
            let outputURL = outputDirectory.appendingPathComponent(fileName)
            
            // 녹화 시작 시간 기록
            recordingStartTime = Date()
            // 타이머 시작
            startRecordingTimer()
            
            movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
            isRecording = true
            
            DispatchQueue.main.async {
                self.shutterButton.setTitle("■", for: .normal)
                self.shutterButton.setTitleColor(.red, for: .normal)
                self.recordingTimeLabel.isHidden = false // 라벨 표시
                if self.isScreenCovered {
                    self.fullScreenBlueView.isHidden = false // 파란색 화면(화면 가리기) 표시
                }
            }
        } else {
            // Stop recording
            movieFileOutput.stopRecording()
            isRecording = false
            stopRecordingTimer() // 타이머 중지
            
            DispatchQueue.main.async {
                self.shutterButton.setTitle("●", for: .normal)
                self.shutterButton.setTitleColor(.red, for: .normal)
                self.recordingTimeLabel.isHidden = true // 라벨 숨김
                self.recordingTimeLabel.text = "00:00" // 초기화
                self.fullScreenBlueView.isHidden = true // 파란색 화면 숨김
            }
        }
    }
    
    @objc private func toggleScreenCover() {
        isScreenCovered.toggle() // 화면 가리기 상태 변경
        
        // 화면 가리기 여부에 따라 파란색 화면을 보이거나 숨김
        fullScreenBlueView.isHidden = !isScreenCovered
    }
    
    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let startTime = self.recordingStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            self.recordingTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
            
            // 20초이 넘으면 색상을 빨간색으로 변경
            if elapsed >= 20 {
                self.recordingTimeLabel.textColor = .red
            } else {
                self.recordingTimeLabel.textColor = .white
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
            return
        }
        
        // Save the recorded video to the photo library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo Library access not granted.")
                return
            }
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func videoSaved(_ videoPath: String,
                                  didFinishSavingWithError error: Error?,
                                  contextInfo: Any?) {
        DispatchQueue.main.async {
            if let error = error {
                let alert = UIAlertController(title: "Save Error",
                                              message: "Video could not be saved: \(error.localizedDescription)",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                // 녹화 시간을 계산
                let recordingDuration: String
                if let startTime = self.recordingStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    let minutes = Int(duration) / 60
                    let seconds = Int(duration) % 60
                    recordingDuration = String(format: "%02d:%02d", minutes, seconds)
                } else {
                    recordingDuration = "Unknown"
                }
                
                let alert = UIAlertController(title: "Saved",
                                              message: "Your video (\(recordingDuration)) has been saved to Photos.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
