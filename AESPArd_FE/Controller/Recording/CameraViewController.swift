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
    
    // MARK: - Overlay Window
        private var overlayWindow: UIWindow?
    
    // MARK: - 시선추적 변수 선언
    
    // 시선추적 변수들
    private var sceneView: ARSCNView!
    private let faceNode = SCNNode()
    private let leftEye = EyeNode(color: .clear)
    private let rightEye = EyeNode(color: .clear)
    private let viewPlane = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    
    
    // 시선 추적 타이머
    var lookTimer: Timer?
    var totalLookTime: TimeInterval = 0
    let edgeThreshold: CGFloat = 20 // 화면 가장자리에서 20만큼의 공간에 시선이 머물러 있으면 시야 벗어난 걸로 간주
    private var edgeTimer: Timer? // 지정한 시간보다 오래 나가 있는지를 측정하는 타이머
    
    
    // MARK: - 화면 녹화 변수 선언
    
    private let recorder = RPScreenRecorder.shared()
    
    // 촬영 시간 타이머
    private var recordingStartTime: Date?
    private var recordingTimer: Timer?
    
    private var isRecording = false
    
    
    // MARK: - Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // 카메라 권한 확인
        checkCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupSceneView()
                    self?.setupARConfiguration()
                    
                } else {
                    self?.showAlert(title: "카메라 사용 제한", message: "카메라 사용 권한이 필요합니다.")
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackButtonTapped), name: .backButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStartStopRecordingTapped), name: .startStopRecordingButtonTapped, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupOverlayWindow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        removeOverlayWindow()
    }
    
    deinit {
        sceneView.scene.rootNode.cleanup()
        lookTimer?.invalidate()
        recordingTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Overlay Window Setup
    private func setupOverlayWindow() {
        guard overlayWindow == nil else { return } // Prevent multiple overlays
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        let overlayVC = CameraOverlayViewController()
        
        let newOverlayWindow = UIWindow(windowScene: windowScene)
        self.overlayWindow = newOverlayWindow
        newOverlayWindow.windowLevel = UIWindow.Level.alert + 1 // Ensure it's above the main window
        newOverlayWindow.isOpaque = false
        newOverlayWindow.backgroundColor = .clear
        newOverlayWindow.rootViewController = overlayVC
        newOverlayWindow.makeKeyAndVisible()
    }
    
    private func removeOverlayWindow() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
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
    
    
    
    // MARK: - 공용함수
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func stopAllTimers() {
        lookTimer?.invalidate()
        lookTimer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
        totalLookTime = 0
    }
    
    private func stopEyeTrackingTimer() {
        lookTimer?.invalidate()
        lookTimer = nil
    }
    
    
    // MARK: - Button Actions
    @objc private func handleBackButtonTapped() {
        backButtonTapped()
    }
    
    @objc private func handleStartStopRecordingTapped() {
        toggleRecording()
    }
    
    @objc private func backButtonTapped() {
        sceneView.scene.rootNode.cleanup()
        stopAllTimers()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - 시선 추적 코드들
    
    // Setup ARKit Scene View
    private func setupSceneView() {
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
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device.")
        }
        // Configure AR session with face tracking
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true // Optional, for better visuals
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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
        
        if(isRecording){
            NotificationCenter.default.post(name: .updateGazePoint, object: nil, userInfo: ["gazePoint": NSValue(cgPoint: gazePoint)])

            let screenBounds = view.bounds
            
            // 현재 시선 포인트가 가장자리인지 확인
            let isLookingAway = gazePoint.x < edgeThreshold ||
            gazePoint.x > screenBounds.width - edgeThreshold ||
            gazePoint.y < edgeThreshold ||
            gazePoint.y > screenBounds.height - edgeThreshold
            
            
            if isLookingAway {
                // Start edgeTimer if not already started
                if edgeTimer == nil {
                    edgeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        self.stopEyeTrackingTimer()
                    }
                }
            } else {
                // Invalidate edgeTimer if it's running
                if let timer = edgeTimer {
                    timer.invalidate()
                    edgeTimer = nil
                }
                // Resume eye tracking timer if it's not running
                if lookTimer == nil {
                    startEyeTrackTimer()
                }
            }
            
        }
    }
    
    // Timer Logic
    private func startEyeTrackTimer() {
        if lookTimer == nil { // Start only if not already running
            lookTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.totalLookTime += 0.1
                let eyeTimeString = String(format: "Time: %.1fs", self.totalLookTime)
                NotificationCenter.default.post(name: .updateEyeTrackingTime, object: nil, userInfo: ["time": eyeTimeString])
            }
        }
    }
    
    
    // ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        DispatchQueue.main.async {
            self.faceNode.simdTransform = node.simdTransform
            self.eyeTracking(using: faceAnchor)
        }
    }
    
    // MARK: - 화면 녹화 로직
    
    @objc private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    
    private func startRecording() {
        guard recorder.isAvailable else {
            showAlert(title: "Error", message: "Screen recording is not available.")
            return
        }
        
        
        recorder.isMicrophoneEnabled = true
        recorder.startRecording { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self?.isRecording = true
                self?.recordingStartTime = Date()
                self?.startRecordingTimer()
                NotificationCenter.default.post(name: .updateStartStopButtonTitle, object: nil, userInfo: ["title": "촬영 마치기"])
            }
        }
    }
    
    private func stopRecording() {
        recorder.stopRecording { [weak self] previewController, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            self.isRecording = false
            stopAllTimers()
            NotificationCenter.default.post(name: .updateStartStopButtonTitle, object: nil, userInfo: ["title": "촬영 시작하기"])
            NotificationCenter.default.post(name: .updateEyeTrackingTime, object: nil, userInfo: ["time": "Time: 0.0s"])
            
            DispatchQueue.main.async {
                if let previewController = previewController {
                    previewController.previewControllerDelegate = self
                    previewController.modalPresentationStyle = .fullScreen
                    self.present(previewController, animated: true)
                }
            }
            
        }
    }
    
    
    // MARK: - 화면 녹화 타이머
    private func startRecordingTimer() {
        
        recordingTimer?.invalidate() // Cancel existing timer if any
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            
            let timeString = String(format: "%02d:%02d", minutes, seconds)
            NotificationCenter.default.post(name: .updateRecordingTime, object: nil, userInfo: ["time": timeString])
            
        }
    }

    
    // MARK: - RPPreviewViewControllerDelegate
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true)
    }
    
    // MARK: - RPScreenRecorderDelegate
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWithError error: Error?, previewViewController: RPPreviewViewController?) {
        if let error = error {
            showAlert(title: "Recording Stopped with Error", message: error.localizedDescription)
        }
    }
}

