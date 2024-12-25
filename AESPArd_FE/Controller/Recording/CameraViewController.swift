//
//  CameraViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/20/24.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation // 카메라 권한 확인용
import ReplayKit

class CameraViewController: UIViewController, RPScreenRecorderDelegate, RPPreviewViewControllerDelegate, ARSessionDelegate, ARSCNViewDelegate {
    
    // 시선추적 변수들
    private var sceneView: ARSCNView!
    private let faceNode = SCNNode()
    private let leftEye = EyeNode(color: .red)
    private let rightEye = EyeNode(color: .blue)
    private let viewPlane = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    private let overlayView = CameraOverlayView()
    
    // 시선 추적 타이머
    var lookTimer: Timer?
    var totalLookTime: TimeInterval = 0
    let edgeThreshold: CGFloat = 20 // 화면 가장자리에서 20만큼의 공간에 시선이 머물러 있으면 시야 벗어난 걸로 간주
    
    
    // 촬영 시간 타이머
    private var recordingStartTime: Date?
    private var recordingTimer: Timer?
    private var isRecording = false
    
    
    
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = CameraOverlayView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
       
        // 카메라 권한 확인
        checkCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupSceneView()
                    self?.setupARConfiguration()
                    self?.setupOverlayView()
                } else {
                    self?.showPermissionAlert()
                }
            }
        }
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    deinit {
        sceneView.scene.rootNode.cleanup()
        lookTimer?.invalidate()
        recordingTimer?.invalidate()
    }
    
    
    // MARK: - Camera Authorization
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted
            completion(true)
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            // Permission denied or restricted
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "카메라 사용 권한",
                                      message: "카메라 사용 권한이 필요합니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: - 시선 추적 코드들
    
    // Setup ARKit Scene View
    private func setupSceneView() {
        debugPrint("setupSceneView")
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.session.delegate = self
        view.addSubview(sceneView)
        
        sceneView.scene.rootNode.addChildNode(faceNode)
        faceNode.addChildNode(leftEye)
        faceNode.addChildNode(rightEye)
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
    
    
    
    private func setupOverlayView() {
        overlayView.frame = view.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlayView)
    }

    
    // Eye Tracking Logic
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
    
    // Update Cursor and Timer
    private func updateCursorAndTimer(with gazePoint: CGPoint) {
        overlayView.aimImageView.center = gazePoint // 시선 추적 동그라미의 중심을 현재 보고있는 시선 포인트로 설정
        let screenBounds = view.bounds
        
        // 현재 시선 포인트가 가장자리인지 확인
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
    
    // Timer Logic
    private func startTimer() {
        if lookTimer == nil { // Start only if not already running
            lookTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.totalLookTime += 0.1
                self.overlayView.eyeTrackingTimeLabel.text = String(format: "Time: %.1fs", self.totalLookTime)
            }
        }
    }
    
    private func stopTimer() {
        lookTimer?.invalidate()
        lookTimer = nil
    }
    
    // ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        DispatchQueue.main.async {
            self.faceNode.simdTransform = node.simdTransform
            self.eyeTracking(using: faceAnchor)
        }
    }
    
//    // MARK: - Shutter Button Actions
//    @objc private func shutterButtonTapped() {
//        guard let movieFileOutput = self.movieFileOutput else { return }
//        debugPrint("Shutter button tapped")
//        debugPrint("AVCaptureSession is running: \(captureSession.isRunning)")
//        
//        if !isRecording {
//            // Start Recording
//            let outputDirectory = FileManager.default.temporaryDirectory
//            let fileName = UUID().uuidString + ".mov"
//            let outputURL = outputDirectory.appendingPathComponent(fileName)
//            
//            DispatchQueue.main.async {
//                self.previewLayer.connection?.isEnabled = false
//                self.previewLayer.connection?.isEnabled = true
//            }
//            // Record start time
//            recordingStartTime = Date()
//            // Start timer
//            startRecordingTimer()
//            
//            movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
//            isRecording = true
//            
//            debugPrint("AVCaptureSession is running after ar: \(captureSession.isRunning)")
//            
//            // Update UI on main thread
//            DispatchQueue.main.async {
//                self.shutterButton.setTitle("■", for: .normal)
//                self.shutterButton.setTitleColor(.red, for: .normal)
//                self.recordingTimeLabel.isHidden = false // Show label
//                if self.isScreenCovered {
//                    self.fullScreenBlueView.isHidden = false // Show blue screen cover
//                }
//            }
//        } else {
//            // Stop Recording
//            movieFileOutput.stopRecording()
//            isRecording = false
//            stopRecordingTimer() // Stop timer
//            stopTimer()
//            
//            DispatchQueue.main.async {
//                self.shutterButton.setTitle("●", for: .normal)
//                self.shutterButton.setTitleColor(.red, for: .normal)
//                self.recordingTimeLabel.isHidden = true // Hide label
//                self.recordingTimeLabel.text = "00:00" // Reset label
//                self.fullScreenBlueView.isHidden = true // Hide blue screen cover
//            }
//        }
//    }
//    
//    // MARK: - Recording Timer Methods
//    private func startRecordingTimer() {
//        recordingTimer?.invalidate() // Cancel existing timer
//        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            guard let startTime = self.recordingStartTime else { return }
//            let elapsed = Date().timeIntervalSince(startTime) // Calculate elapsed time
//            let minutes = Int(elapsed) / 60
//            let seconds = Int(elapsed) % 60
//            self.recordingTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
//            
//            // Change color if elapsed time >= 20 seconds
//            if elapsed >= 20 {
//                self.recordingTimeLabel.textColor = .red
//            } else {
//                self.recordingTimeLabel.textColor = .white
//            }
//        }
//    }
//    
//    private func stopRecordingTimer() {
//        recordingTimer?.invalidate() // Cancel timer
//        recordingTimer = nil
//    }
//    
//    // MARK: - Toggle Screen Cover
//    @objc private func toggleScreenCover() {
//        isScreenCovered.toggle() // Toggle screen cover state
//        
//        // Show or hide the blue screen cover based on the state
//        fullScreenBlueView.isHidden = !isScreenCovered
//    }
//    
//    private var isScreenCovered = false
//    
//    // MARK: - Back Button Action
//    @objc private func backButtonTapped() {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    // MARK: - AVCaptureFileOutputRecordingDelegate
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
//        // Save video to Photo Library
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                print("Photo Library access not granted.")
//                return
//            }
//            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
//        }
//    }
//    
//    // MARK: - Video Saved Callback
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
//                // Calculate recording duration
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
//                // Show success alert
//                let alert = UIAlertController(title: "Saved",
//                                              message: "Your video (\(recordingDuration)) has been saved to Photos.",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                    self.moveVideoPlayerModal(with: URL(fileURLWithPath: videoPath))
//                }))
//                self.present(alert, animated: true)
//            }
//        }
//    }
//    
//    // MARK: - Move to Video Player
//    @objc func moveVideoPlayerModal(with videoURL: URL) {
//        let videoPlayerController = VideoPlayerController()
//        videoPlayerController.videoURL = videoURL
//        videoPlayerController.modalPresentationStyle = .fullScreen
//        self.present(videoPlayerController, animated: true)
//    }
//    
//    // MARK: - ARSessionDelegate Methods
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
    
    // MARK: - ARSCNViewDelegate Methods
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
//        DispatchQueue.main.async {
//            self.face.simdTransform = node.simdTransform
//            self.eyeTracking(using: faceAnchor)
//        }
//    }
}


