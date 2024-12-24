//
//  CameraViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/20/24.
//

import UIKit
import AVFoundation
import Photos
import ARKit
import SceneKit

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, ARSessionDelegate, ARSCNViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Capture Session Properties
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - Recording Properties
    private var recordingStartTime: Date?
    private var recordingTimer: Timer?
    private var isRecording = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let videoDataOutputQueue = DispatchQueue(label: "video data output queue")
    
    // MARK: - UI Elements
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("●", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let fullScreenBlueView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let toggleScreenCoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cover Screen", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(toggleScreenCover), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Eye Tracking Properties
    var sceneView: ARSCNView!
    let face = SCNNode()
    let leftEye = EyeNode(color: .clear)
    let rightEye = EyeNode(color: .clear)
    let viewPlane = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    let aimImageView = UIImageView(image: UIImage(named: "Cursor"))
    
    var lookTimer: Timer?
    var totalLookTime: TimeInterval = 0
    var timerLabel: UILabel!
    let edgeThreshold: CGFloat = 20 // Pixels from screen edge considered as "looking away"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Setup UI
        setupUI()
        
        // Check Camera Authorization
        checkCameraAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        captureSession.stopRunning()
    }
    
    deinit {
        sceneView.scene.rootNode.cleanup()
        aimImageView.removeFromSuperview()
        sceneView = nil
        lookTimer?.invalidate()
        recordingTimer?.invalidate()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Add UI elements
        view.addSubview(fullScreenBlueView)
        view.addSubview(backButton)
        view.addSubview(shutterButton)
        view.addSubview(recordingTimeLabel)
        view.addSubview(toggleScreenCoverButton)
        view.addSubview(aimImageView)
        
        aimImageView.frame.size = CGSize(width: 30, height: 30)
        aimImageView.center = view.center
        aimImageView.isUserInteractionEnabled = false
        
        // Setup Constraints
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
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
        
        // Setup Timer Label
        setupTimerLabel()
        setupSceneView()
        
        // Bring UI elements to front
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(recordingTimeLabel)
        view.bringSubviewToFront(toggleScreenCoverButton)
        view.bringSubviewToFront(aimImageView)
        DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.captureSession.startRunning()
                } // 카메라 세션 시작
    }
    
    private func setupTimerLabel() {
        timerLabel = UILabel()
        timerLabel.frame = CGRect(x: 20, y: 50, width: 200, height: 40)
        timerLabel.textColor = .white
        timerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        timerLabel.text = "Time: 0.0s"
        view.addSubview(timerLabel)
    }
    
    // MARK: - Camera Authorization
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession() // 권한 허용시 세션 설정
                    } else {
                        self.showPermissionAlert() // 권한 거부시 알림
                    }
                }
            }
        case .authorized:
            // Already authorized
            setupSession()
            //setupSceneView()
            setupARConfiguration()
            //setupLayout()
//            setupTimerLabel()
        case .denied, .restricted:
            // Access denied
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
    
    // MARK: - Setup Capture Session
    private func setupSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            // Add video input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("No front camera available.")
                self.captureSession.commitConfiguration()
                return
            }
            
            do {
                let cameraInput = try AVCaptureDeviceInput(device: camera)
                if self.captureSession.canAddInput(cameraInput) {
                    self.captureSession.addInput(cameraInput)
                    self.videoDeviceInput = cameraInput
                } else {
                    print("Unable to add camera input.")
                    self.captureSession.commitConfiguration()
                    return
                }
            } catch {
                print("Error: \(error)")
                self.captureSession.commitConfiguration()
                return
            }
            
            // Add audio input
            guard let audioDevice = AVCaptureDevice.default(for: .audio),
                  let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
                  self.captureSession.canAddInput(audioInput) else {
                print("Cannot add audio input")
                self.captureSession.commitConfiguration()
                return
            }
            self.captureSession.addInput(audioInput)
            
            // Add movie file output
            let movieOutput = AVCaptureMovieFileOutput()
            if self.captureSession.canAddOutput(movieOutput) {
                self.captureSession.addOutput(movieOutput)
                self.movieFileOutput = movieOutput
            } else {
                print("Unable to add movie file output.")
                self.captureSession.commitConfiguration()
                return
            }
            
            // Add video data output for eye tracking
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
                self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
                self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
                self.videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
                ]
            } else {
                print("Unable to add video data output.")
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.commitConfiguration()
            
            // Setup preview layer on main thread
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
            
            // Start running the session
            self.captureSession.startRunning()
            
            if self.captureSession.isRunning {
                print("AVCaptureSession is running")
            } else {
                print("AVCaptureSession setup but not yet running")
            }
        }
    }
    
    private func setupPreviewLayer() {
        DispatchQueue.main.async {
            self.previewLayer.frame = self.view.bounds
            self.previewLayer.connection?.videoOrientation = .portrait
        }
    }
    
    // MARK: - Setup ARKit Scene View
    private func setupSceneView() {
        debugPrint("setupSceneView")
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.backgroundColor = UIColor.clear
        view.addSubview(sceneView)
        view.sendSubviewToBack(sceneView)
        
        sceneView.scene.rootNode.addChildNode(face)
        face.addChildNode(leftEye)
        face.addChildNode(rightEye)
        sceneView.scene.rootNode.addChildNode(viewPlane)
        
        // Optional: Enable debug options to verify AR functionality
        // sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    private func setupARConfiguration() {
        print("setupARConfiguration")
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device.")
        }
        // Configure AR session with face tracking
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true // Optional, for better visuals
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Layout Setup
    private func setupLayout() {
        debugPrint("setupLayout")
        aimImageView.frame.size = CGSize(width: 30, height: 30)
        aimImageView.center = view.center // Initially center the cursor on screen
        view.addSubview(aimImageView)
        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(toggleScreenCoverButton)
        view.bringSubviewToFront(recordingTimeLabel)
    }
    
    // MARK: - Timer Label Setup
//    private func setupTimerLabel() {
//        debugPrint("setupTimerLabel")
//        timerLabel = UILabel()
//        timerLabel.frame = CGRect(x: 20, y: 50, width: 200, height: 40)
//        timerLabel.textColor = .white
//        timerLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        timerLabel.text = "Time: 0.0s"
//        view.addSubview(timerLabel)
//    }
    
    // MARK: - Eye Tracking Logic
    func eyeTracking(using anchor: ARFaceAnchor) {
        leftEye.simdTransform = anchor.leftEyeTransform
        rightEye.simdTransform = anchor.rightEyeTransform
        
        let intersectPoints = [leftEye, rightEye].compactMap { eye -> CGPoint? in
            let hitTest = viewPlane.hitTestWithSegment(from: eye.target.worldPosition, to: eye.worldPosition)
            return hitTest.first?.screenPosition
        }
        
        guard let leftPoint = intersectPoints.first,
              let rightPoint = intersectPoints.last else { return }
        
        let currentGazePoint = CGPoint(
            x: (leftPoint.x + rightPoint.x) / 2,
            y: -(leftPoint.y + rightPoint.y) / 2
        )
        
        DispatchQueue.main.async {
            self.updateCursorAndTimer(with: currentGazePoint)
        }
    }
    
    // MARK: - Update Cursor and Timer
    private func updateCursorAndTimer(with gazePoint: CGPoint) {
        aimImageView.center = gazePoint
        
        // Check if the gaze is near the screen edge
        let screenBounds = view.bounds
        let isLookingAway = gazePoint.x < edgeThreshold ||
            gazePoint.x > screenBounds.width - edgeThreshold ||
            gazePoint.y < edgeThreshold ||
            gazePoint.y > screenBounds.height - edgeThreshold
        
        if isLookingAway {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    // MARK: - Timer Logic
    private func startTimer() {
        if lookTimer == nil { // Start only if not already running
            lookTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.totalLookTime += 0.1
                self.timerLabel.text = String(format: "Time: %.1fs", self.totalLookTime)
            }
        }
    }
    
    private func stopTimer() {
        lookTimer?.invalidate()
        lookTimer = nil
    }
    
    // MARK: - Shutter Button Actions
    @objc private func shutterButtonTapped() {
        guard let movieFileOutput = self.movieFileOutput else { return }
        debugPrint("Shutter button tapped")
        debugPrint("AVCaptureSession is running: \(captureSession.isRunning)")
        
        if !isRecording {
            // Start Recording
            let outputDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".mov"
            let outputURL = outputDirectory.appendingPathComponent(fileName)
            
            DispatchQueue.main.async {
                self.previewLayer.connection?.isEnabled = false
                self.previewLayer.connection?.isEnabled = true
            }
            // Record start time
            recordingStartTime = Date()
            // Start timer
            startRecordingTimer()
            
            movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
            isRecording = true
            
            debugPrint("AVCaptureSession is running after ar: \(captureSession.isRunning)")
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.shutterButton.setTitle("■", for: .normal)
                self.shutterButton.setTitleColor(.red, for: .normal)
                self.recordingTimeLabel.isHidden = false // Show label
                if self.isScreenCovered {
                    self.fullScreenBlueView.isHidden = false // Show blue screen cover
                }
            }
        } else {
            // Stop Recording
            movieFileOutput.stopRecording()
            isRecording = false
            stopRecordingTimer() // Stop timer
            stopTimer()
            
            DispatchQueue.main.async {
                self.shutterButton.setTitle("●", for: .normal)
                self.shutterButton.setTitleColor(.red, for: .normal)
                self.recordingTimeLabel.isHidden = true // Hide label
                self.recordingTimeLabel.text = "00:00" // Reset label
                self.fullScreenBlueView.isHidden = true // Hide blue screen cover
            }
        }
    }
    
    // MARK: - Recording Timer Methods
    private func startRecordingTimer() {
        recordingTimer?.invalidate() // Cancel existing timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let startTime = self.recordingStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime) // Calculate elapsed time
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            self.recordingTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
            
            // Change color if elapsed time >= 20 seconds
            if elapsed >= 20 {
                self.recordingTimeLabel.textColor = .red
            } else {
                self.recordingTimeLabel.textColor = .white
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate() // Cancel timer
        recordingTimer = nil
    }
    
    // MARK: - Toggle Screen Cover
    @objc private func toggleScreenCover() {
        isScreenCovered.toggle() // Toggle screen cover state
        
        // Show or hide the blue screen cover based on the state
        fullScreenBlueView.isHidden = !isScreenCovered
    }
    
    private var isScreenCovered = false
    
    // MARK: - Back Button Action
    @objc private func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
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
        
        // Save video to Photo Library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo Library access not granted.")
                return
            }
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // MARK: - Video Saved Callback
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
                // Calculate recording duration
                let recordingDuration: String
                if let startTime = self.recordingStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    let minutes = Int(duration) / 60
                    let seconds = Int(duration) % 60
                    recordingDuration = String(format: "%02d:%02d", minutes, seconds)
                } else {
                    recordingDuration = "Unknown"
                }
                
                // Show success alert
                let alert = UIAlertController(title: "Saved",
                                              message: "Your video (\(recordingDuration)) has been saved to Photos.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.moveVideoPlayerModal(with: URL(fileURLWithPath: videoPath))
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Move to Video Player
    @objc func moveVideoPlayerModal(with videoURL: URL) {
        let videoPlayerController = VideoPlayerController()
        videoPlayerController.videoURL = videoURL
        videoPlayerController.modalPresentationStyle = .fullScreen
        self.present(videoPlayerController, animated: true)
    }
    
    // MARK: - ARSessionDelegate Methods
    func session(_ session: ARSession, didFailWithError error: Error) {
        debugPrint("ARSession failed with error: \(error.localizedDescription)")
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        debugPrint("ARSession camera tracking state changed: \(camera.trackingState)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        debugPrint("ARSession was interrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        debugPrint("ARSession interruption ended")
        // Optionally reset or restart the session if needed
    }
    
    // MARK: - ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        DispatchQueue.main.async {
            self.face.simdTransform = node.simdTransform
            self.eyeTracking(using: faceAnchor)
        }
    }
}





//class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, ARSessionDelegate,ARSCNViewDelegate {
//    
//    private var captureSession: AVCaptureSession!
//    private var videoDeviceInput: AVCaptureDeviceInput!
//    private var movieFileOutput: AVCaptureMovieFileOutput?
//    private var previewLayer: AVCaptureVideoPreviewLayer!
//    
//    // 녹화 시작 시간을 기록할 변수 추가
//    private var recordingStartTime: Date?
//    //실시간 타이머
//    private var recordingTimer: Timer?
//    
//    private var isRecording = false //녹화 상태
//    private var isScreenCovered = false // 화면 가리기 상태 변수
//    
//    // 시선추적
//    var sceneView: ARSCNView!
//    let face = SCNNode()
//    let leftEye = EyeNode(color: .clear)
//    let rightEye = EyeNode(color: .clear)
//    let viewPlane = SCNNode(geometry: SCNPlane(width: 1, height: 1))
//    let aimImageView = UIImageView(image: UIImage(named: "Cursor"))
//    
//    // 시선추적 Timer Properties
//    var lookTimer: Timer?
//    var totalLookTime: TimeInterval = 0
//    var timerLabel: UILabel!
//    let edgeThreshold: CGFloat = 20 // Pixels from screen edge considered as "looking away"
//    
//    //뒤로가기 버튼
//    private let backButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Back", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
//        button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    //녹화 시작/끝 버튼
//    private let shutterButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("●", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
//        button.setTitleColor(.red, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // 녹화 시간 표시 라벨
//    private let recordingTimeLabel: UILabel = {
//        let label = UILabel()
//        label.text = "00:00"
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.isHidden = true // 기본적으로 숨김
//        return label
//    }()
//    
//    //화면 가리기 파란색 UIView
//    private let fullScreenBlueView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .blue // 배경색을 파란색으로 설정
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isHidden = true // 기본적으로 숨김
//        return view
//    }()
//    
//    // 화면 가리기 버튼
//    private let toggleScreenCoverButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Cover Screen", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
//        button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(toggleScreenCover), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        
//        // 카메라 권한 확인
//        checkCameraAuthorization()
//        
//        // 시선추적 함수들
////        setupSceneView()
////        setupLayout()
////        setupTimerLabel()
//    }
//    
//    
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
//    
//    deinit {
//        sceneView.scene.rootNode.cleanup()
//        aimImageView.removeFromSuperview()
//        sceneView = nil
//        lookTimer?.invalidate() // Stop the timer
//    }
//    
//    
//    // MARK: 시선추적 함수
//    private func setupSceneView() {
//        debugPrint("setupSceneView")
//        sceneView = ARSCNView(frame: view.bounds)
//        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        sceneView.delegate = self
//        sceneView.session.delegate = self
//        sceneView.backgroundColor = UIColor.clear
//        view.addSubview(sceneView)
//        view.sendSubviewToBack(sceneView)
//        
//        sceneView.scene.rootNode.addChildNode(face)
//        face.addChildNode(leftEye)
//        face.addChildNode(rightEye)
//        sceneView.scene.rootNode.addChildNode(viewPlane)
//        
//        
//
//        // Optional: Enable debug options to verify AR functionality
////        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
//    }
//    
//    private func setupARConfiguration() {
//        print("setupARConfiguration")
//        guard ARFaceTrackingConfiguration.isSupported else {
//            fatalError("Face tracking is not supported on this device.")
//        }
//        // Configure AR session with face tracking
//        let configuration = ARFaceTrackingConfiguration()
//        configuration.isLightEstimationEnabled = true // Optional, for better visuals
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//    }
//    
//   
//    
//    private func setupLayout() {
//        debugPrint("setupLayout")
//        aimImageView.frame.size = CGSize(width: 30, height: 30)
//        aimImageView.center = view.center // Initially center the cursor on screen
//        view.addSubview(aimImageView)
//        view.bringSubviewToFront(shutterButton)
//        view.bringSubviewToFront(backButton)
//        view.bringSubviewToFront(toggleScreenCoverButton)
//        view.bringSubviewToFront(recordingTimeLabel)
//        
//    }
//    
//    private func setupTimerLabel() {
//        debugPrint("setupTimerLabel")
//        timerLabel = UILabel()
//        timerLabel.frame = CGRect(x: 20, y: 50, width: 200, height: 40)
//        timerLabel.textColor = .white
//        timerLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        timerLabel.text = "Time: 0.0s"
//        view.addSubview(timerLabel)
//    }
//    
//    func eyeTracking(using anchor: ARFaceAnchor) {
//        leftEye.simdTransform = anchor.leftEyeTransform
//        rightEye.simdTransform = anchor.rightEyeTransform
//        
//        let intersectPoints = [leftEye, rightEye].compactMap { eye -> CGPoint? in
//            let hitTest = viewPlane.hitTestWithSegment(from: eye.target.worldPosition, to: eye.worldPosition)
//            return hitTest.first?.screenPosition
//        }
//        
//        guard let leftPoint = intersectPoints.first,
//              let rightPoint = intersectPoints.last else { return }
//        
//        let currentGazePoint = CGPoint(
//            x: (leftPoint.x + rightPoint.x) / 2,
//            y: -(leftPoint.y + rightPoint.y) / 2
//        )
//        
//        //print("Calculated gaze point: \(currentGazePoint)") // Debug
//
//        
//        DispatchQueue.main.async {
//            self.updateCursorAndTimer(with: currentGazePoint)
//        }
//    }
//    
//    // 시선 추적Timer Logic
//    private func updateCursorAndTimer(with gazePoint: CGPoint) {
//        aimImageView.center = gazePoint
//        
//        // Check if the gaze is near the screen edge
//        let screenBounds = view.bounds
//        let isLookingAway = gazePoint.x < edgeThreshold ||
//        gazePoint.x > screenBounds.width - edgeThreshold ||
//        gazePoint.y < edgeThreshold ||
//        gazePoint.y > screenBounds.height - edgeThreshold
//        
//        if isLookingAway {
//            stopTimer()
//        } else {
//            startTimer()
//        }
//    }
//    
//    // 시선 추적 시작 타이머
//    private func startTimer() {
//        if lookTimer == nil { // Start only if not already running
//            lookTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//                guard let self = self else { return }
//                self.totalLookTime += 0.1
//                self.timerLabel.text = String(format: "Time: %.1fs", self.totalLookTime)
//            }
//        }
//    }
//    
//    // 시선 추적 타이머 중지
//    private func stopTimer() {
//        lookTimer?.invalidate()
//        lookTimer = nil
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
//        DispatchQueue.main.async {
//            self.face.simdTransform = node.simdTransform
//            self.eyeTracking(using: faceAnchor)
//        }
//        
//    }
//    
//    // MARK: 카메라 촬영 및 녹화 설정
//    //카메라 권환 확인 메서드
//    private func checkCameraAuthorization() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .notDetermined: //권한 허용 안 했을 때 권한 허용을 받음
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
////                        self.setupSceneView()
////                        self.setupARConfiguration()
////                        self.setupLayout()
////                        self.setupTimerLabel()
//                        self.setupSession() // 권한 허용시 세션 설정
//                    } else {
//                        self.showPermissionAlert() //권한 거부시 알림
//                    }
//                }
//            }
//        case .authorized: //권한이 이미 허용된 경우 세션 설정
//            setupSession()
//            setupSceneView()
//            setupARConfiguration()
//            setupLayout()
//            setupTimerLabel()
//        case .denied, .restricted: //권한 거부된 경우 알림 표시
//            showPermissionAlert()
//        @unknown default:
//            break
//        }
//    }
//    
//    //카메라 권한 없을 때 알림을 띄우는 메서드
//    private func showPermissionAlert() {
//        // UIAlertController가 AlertDialog(화면 중간에 생기는 경고창) 만드는 것
//        let alert = UIAlertController(title: "Camera Access Needed",
//                                      message: "Please enable camera access in Settings.",
//                                      preferredStyle: .alert)
//        // addAction이 경고 창 밑에 보면 "확인", "취소" 이런게 있잖음? 그런거 만드는 거
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    //MARK: - 세션 설정 및 제약조건 설정
//    //AVCaptureSession을 설정하는 메서드
//    private func setupSession() {
//        debugPrint("카메라 세션")
//        captureSession = AVCaptureSession() // 세션 생성
//        captureSession.sessionPreset = .high //고화질 설정
//        
//        //카메라 장치 설정 - 앞면 카메라 설정
//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
//            print("No back camera available.")
//            return
//        }
//        
//        do {
//            //카메라 입력 장치 설정
//            // AVCaptureDeviceInput: 선택한 입력 장치로 만들어내는 입력값을 capture session에 제공하는 객체임. 한마디로 너가 영상 열심히 찍고 매니저한테 가져다 주는 거임.
//            let cameraInput = try AVCaptureDeviceInput(device: camera)
//            if captureSession.canAddInput(cameraInput) {
//                captureSession.addInput(cameraInput) // 세션에 카메라 입력 추가
//                self.videoDeviceInput = cameraInput
//            } else {
//                print("Unable to add camera input.")
//                return
//            }
//        } catch {
//            print("Error: \(error)")
//            return
//        }
//        
//        // 오디오 입력 장치 설정
//        guard let audioDevice = AVCaptureDevice.default(for: .audio),
//              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
//              captureSession.canAddInput(audioInput) else {
//            print("Cannot add audio input")
//            return
//        }
//        captureSession.addInput(audioInput) // 세션에 오디오 입력 추가
//        
//        //비디오 출력 장치 설정
//        // AVCaptureMovieFileOutput: 영상 촬영하고 다오는 출력값. 한마디로 촬영한 영상 파일
//        let movieOutput = AVCaptureMovieFileOutput()
//        if captureSession.canAddOutput(movieOutput) {
//            captureSession.addOutput(movieOutput) // 세션에 비디오 출력 추가
//            movieFileOutput = movieOutput
//        }
//        
//        
//        // 미리보기 레이어 설정
//        // 사진 촬영할때 보면 찍기 전에 그리고 찍을 때 카메라가 찍고 있는거 보여 주잖아? 그거 말하는 거임
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = .resizeAspectFill // 비디오 크기 비율 설정
//        previewLayer.frame = view.bounds // 미리보기 레이어 크기 설정
//        
//        view.layer.addSublayer(previewLayer) // 뷰에 미리보기 레이어 추가
//        //view.layer.insertSublayer(previewLayer, at: 0) // 화면 제일 밑에 있게 설정하는 듯
//        view.addSubview(fullScreenBlueView) //화면 가리기 뷰
//        
//        
//        // 버튼들을 화면에 추가
//        view.addSubview(backButton)
//        view.addSubview(shutterButton)
//        view.addSubview(recordingTimeLabel)
//        view.addSubview(toggleScreenCoverButton)
//        
//        //setupSceneView()
//        
//        NSLayoutConstraint.activate([
//            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//                    backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            
//            fullScreenBlueView.topAnchor.constraint(equalTo: view.topAnchor),
//            fullScreenBlueView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            fullScreenBlueView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            fullScreenBlueView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
//            shutterButton.widthAnchor.constraint(equalToConstant: 80),
//            shutterButton.heightAnchor.constraint(equalToConstant: 80),
//            
//            recordingTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            recordingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            toggleScreenCoverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            toggleScreenCoverButton.bottomAnchor.constraint(equalTo: shutterButton.topAnchor, constant: -20)
//            
//        ])
//        
//        
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            self?.captureSession.startRunning()
//        } // 카메라 세션 시작
//        
//        if captureSession.isRunning {
//                debugPrint("AVCaptureSession is now running")
//        } else {
//                debugPrint("AVCaptureSession setup but not yet running")
//        }
//    }
//    
//    //MARK: 녹화 시작~중
//    
//    // 셔터 버튼 클릭시 녹화 시작 / 종료
//    @objc private func shutterButtonTapped() {
//        guard let movieFileOutput = self.movieFileOutput else { return }
//        debugPrint("Shutter button tapped")
//            debugPrint("AVCaptureSession is running: \(captureSession.isRunning)")
//            //debugPrint("ARSession is running: \(sceneView.session.isRunning)")
//        
//        if !isRecording {
//            // 녹화 시작
//            let outputDirectory = FileManager.default.temporaryDirectory
//            let fileName = UUID().uuidString + ".mov"
//            let outputURL = outputDirectory.appendingPathComponent(fileName)
//            
//
//            DispatchQueue.main.async {
//                self.previewLayer.connection?.isEnabled = false
//                self.previewLayer.connection?.isEnabled = true
//            }
//            // 녹화 시작 시간 기록
//            recordingStartTime = Date()
//            // 타이머 시작
//            startRecordingTimer()
//            
//            movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
//            isRecording = true
////            setupARConfiguration()
//            
//            debugPrint("AVCaptureSession is running after ar: \(captureSession.isRunning)")
//            
//            // DispatchQueue: main thread에서의 비동기 실행을 위한 오브젝트
//            DispatchQueue.main.async {
//                self.shutterButton.setTitle("■", for: .normal)
//                self.shutterButton.setTitleColor(.red, for: .normal)
//                self.recordingTimeLabel.isHidden = false // 라벨 표시
//                if self.isScreenCovered {
//                    self.fullScreenBlueView.isHidden = false // 파란색 화면(화면 가리기) 표시
//                }
//            }
//        } else {
//            // 녹화 종료
//            movieFileOutput.stopRecording()
//            isRecording = false
//            stopRecordingTimer() // 타이머 중지
//            
//            DispatchQueue.main.async {
//                self.shutterButton.setTitle("●", for: .normal)
//                self.shutterButton.setTitleColor(.red, for: .normal)
//                self.recordingTimeLabel.isHidden = true // 라벨 숨김
//                self.recordingTimeLabel.text = "00:00" // 초기화
//                self.fullScreenBlueView.isHidden = true // 파란색 화면 숨김
//            }
//        }
//    }
//    
//    // 화면 가리기 버튼 클릭시 화면 가리기 상태 변경
//    @objc private func toggleScreenCover() {
//        isScreenCovered.toggle() // 화면 가리기 상태 변경
//        
//        // 화면 가리기 여부에 따라 파란색 화면을 보이거나 숨김
//        fullScreenBlueView.isHidden = !isScreenCovered
//    }
//    
//    //녹화 시간 타이머 시작
//    private func startRecordingTimer() {
//        recordingTimer?.invalidate() // 기존 타이머 취소
//        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            guard let startTime = self.recordingStartTime else { return }
//            let elapsed = Date().timeIntervalSince(startTime) // 경과 시간 계산
//            let minutes = Int(elapsed) / 60
//            let seconds = Int(elapsed) % 60
//            self.recordingTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
//            
//            // 20초이 넘으면 색상을 빨간색으로 변경
//            if elapsed >= 20 {
//                self.recordingTimeLabel.textColor = .red
//            } else {
//                self.recordingTimeLabel.textColor = .white
//            }
//        }
//    }
//    
//    //녹화 시작 타이머 중지
//    private func stopRecordingTimer() {
//        recordingTimer?.invalidate() // 타이머 취소
//        recordingTimer = nil
//    }
//    
//    // MARK: - 녹화 끝: AVCaptureFileOutputRecordingDelegate
//    
//    // 녹화가 끝났을 때 호출되는 메서드
//    func fileOutput(_ output: AVCaptureFileOutput,
//                    didFinishRecordingTo outputFileURL: URL,
//                    from connections: [AVCaptureConnection],
//                    error: Error?) {
//        
//        if let error = error {
//            print("Error recording movie: \(error.localizedDescription)")
//            return
//        }
//        
//        // 비디오를 사진 라이브러리에 저장
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                print("Photo Library access not granted.")
//                return
//            }
//            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
//        }
//    }
//    
//    // 비디오 저장 완료 후 호출되는 메서드
//    @objc private func videoSaved(_ videoPath: String,
//                                  didFinishSavingWithError error: Error?,
//                                  contextInfo: Any?) {
//        DispatchQueue.main.async {
//            if let error = error {
//                let alert = UIAlertController(title: "Save Error",
//                                              message: "Video could not be saved: \(error.localizedDescription)",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
//            } else {
//                // 녹화 시간을 계산
//                let recordingDuration: String
//                if let startTime = self.recordingStartTime {
//                    let duration = Date().timeIntervalSince(startTime)
//                    let minutes = Int(duration) / 60
//                    let seconds = Int(duration) % 60
//                    recordingDuration = String(format: "%02d:%02d", minutes, seconds)
//                } else {
//                    recordingDuration = "Unknown"
//                }
//                
//                //계산된 녹화시간을 알림에 표시
//                let alert = UIAlertController(title: "Saved",
//                                              message: "Your video (\(recordingDuration)) has been saved to Photos.",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
////                    // 비디오 플레이어 모달로 이동
//                    self.moveVideoPlayerModal(with: URL(fileURLWithPath: videoPath))
//                }))
//                self.present(alert, animated: true)
//            }
//        }
//    }
//    
//    //비디오 플레이어 모달창으로 이동
//    @objc func moveVideoPlayerModal(with videoURL: URL) {
//        let videoPlayerController = VideoPlayerController()
//        videoPlayerController.videoURL = videoURL
//        videoPlayerController.modalPresentationStyle = .fullScreen
//        self.present(videoPlayerController, animated: true)
//    }
//    
//    //뒤로 가기
//    @objc private func backButtonTapped() {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    
//    // MARK: 디버깅
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        debugPrint("ARSession failed with error: \(error.localizedDescription)")
//    }
//
//    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//        debugPrint("ARSession camera tracking state changed: \(camera.trackingState)")
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        debugPrint("ARSession was interrupted")
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        debugPrint("ARSession interruption ended")
//        // Optionally reset or restart the session if needed
//    }
//}

