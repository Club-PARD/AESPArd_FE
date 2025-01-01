//
//  CameraViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/20/24.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation // 카메라 권한을 위해서 씁니다
import ReplayKit // 화면 녹화를 위한 프레임워크
import Photos // 갤러리 접근 프레임워크

class CameraViewController: UIViewController, RPScreenRecorderDelegate, RPPreviewViewControllerDelegate, ARSessionDelegate, ARSCNViewDelegate {
    
    // MARK: - 이전 뷰컨에서 받아오는 데이터 값들
    private var newPresentation: NewPresentation?
    private var newPracticeAfterNewPresentation: NewPracticeAfterNewPresentation?
    private var newPractice: NewPractice?
    private var isShowingTimeSelected: Bool?
    private var isShowingMeSelected: Bool?
    // userId 안씀 그래서 나중에 userId 쓰는 라인들 지워주면 됨 혹시 몰라서 남김
    private var userId: String?
    
    // 새로운 발표를 만드는지 혹은 연습을 만드는지에 따라 다음 페이지에 전달하는 값이 달라짐
    private var isCreatingNewPresentation: Bool?
    private var isCreatingNewPractice: Bool?
    
    //MARK: - 생성자
    
    // 새로운 발표 생성자
    init(newPresentation: NewPresentation, isShowingTimeSelected: Bool, isShowingMeSelected: Bool){
        self.newPresentation = newPresentation
        self.newPracticeAfterNewPresentation = NewPracticeAfterNewPresentation()
        self.newPracticeAfterNewPresentation!.userId = newPresentation.userId
        self.isShowingTimeSelected = isShowingTimeSelected
        self.isShowingMeSelected = isShowingMeSelected
        self.newPresentation!.showMeOnScreen = isShowingMeSelected
        self.newPresentation!.showTimeOnScreen = isShowingTimeSelected
        self.minTime = newPresentation.idealMinTime
        self.maxTime = newPresentation.idealMaxTime
        self.userId = newPresentation.userId
        self.newPractice = NewPractice()
        isCreatingNewPresentation = true
        isCreatingNewPractice = false
        super.init(nibName: nil, bundle: nil)
    }
    
    // 기존 발표에 새로운 연습 생성자
    init(newPractice: NewPractice, isShowingTimeSelected: Bool, isShowingMeSelected: Bool, minTime: Double, maxTime: Double, userId: String){
        super.init(nibName: nil, bundle: nil)
        self.newPractice = newPractice
        self.isShowingTimeSelected = isShowingTimeSelected
        self.isShowingMeSelected = isShowingMeSelected
        self.minTime = minTime
        self.maxTime = maxTime
        self.userId = userId
        isCreatingNewPresentation = false
        isCreatingNewPractice = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overlay Window
    
    // 유저에게는 보이지만 스크린 녹화에는 보이지 않는 뷰컨을 만들기 위한 선언
    private var overlayWindow: UIWindow?
    
    // MARK: - 시선추적 변수 선언
    
    // 시선추적 변수들
    private var sceneView: ARSCNView!
    private let faceNode = SCNNode() // SCNNode: 3D 공간에서의 위치 정보를 가지는 클래스
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
    private var recordingTimer: Timer?
    private var totalRecordingTime: Double = 0
    
    private var isRecording = false
    
    
    // 유저 시간 설정 값
    private var minTime: Double?
    private var maxTime: Double?

    
    // MARK: - 생성 주기
    
    
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
       
//        debugPrint("            ")
//        debugPrint("            ")
//        debugPrint(newPresentation)
//        debugPrint("            ")
//        debugPrint("            ")
       
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackButtonTapped), name: .backButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStartStopRecordingTapped), name: .startStopRecordingButtonTapped, object: nil)
        
        if isCreatingNewPresentation! {
            uploadNewPresentation()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면에는 보이지만 스크린 녹화에는 안보이는 화면 활성화
        setupOverlayWindow()
        
        // 촬영시간 타이머 보이게 할건지 안할건지 전달해주는 노티피케이션
        NotificationCenter.default.post(name: .setTimeLabelVisibility, object: nil, userInfo: ["isVisible": isShowingTimeSelected!])
       
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
    
    
    
    // MARK: - 서버에 발표 보내는 함수
    
    private func uploadNewPresentation(){
        NetworkManager.shared.uploadPresentation(newPresentation: newPresentation!) { result in
            guard let newPresentation = self.newPresentation else {
                print("Error: newPresentation is nil.")
                return
            }
            
            switch result {
            case .success(let createdPresentation):
                print("Presentation uploaded successfully!")
                self.newPractice!.presentationId = createdPresentation.presentationId
            case .failure(let error):
                print("Failed to upload presentation: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - Overlay Window Setup
    private func setupOverlayWindow() {
        guard overlayWindow == nil else { return } // 이미 생성된 overlay가 없는지 체크
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        // connectedScenes: This property provides a set of all active UIScene objects that are currently connected to the app.
        
        //Using first
        //connectedScenes.first: This picks the first available scene in the connectedScenes set. This is sufficient for single-window apps.
        //In multi-window apps (e.g., on iPad), you may need to determine the specific scene you want to use.
        
        let overlayVC = CameraOverlayViewController()
        
        let newOverlayWindow = UIWindow(windowScene: windowScene)
        self.overlayWindow = newOverlayWindow
        newOverlayWindow.windowLevel = UIWindow.Level.alert + 1 // 메인 화면 위에 있도록 설정
        newOverlayWindow.isOpaque = false   // window가 투명하게 렌더링 되도록 설정
        newOverlayWindow.backgroundColor = .clear // 배경 투명하게 하면 밑에 있는 메인 윈도우가 보여짐
        newOverlayWindow.rootViewController = overlayVC
        newOverlayWindow.makeKeyAndVisible()
    }
    
    private func removeOverlayWindow() {
        overlayWindow?.isHidden = true
        overlayWindow?.isUserInteractionEnabled = false
        overlayWindow?.rootViewController = nil
        overlayWindow?.backgroundColor = .black
        overlayWindow = nil
    }
    
    // MARK: - 카메라 권한 확인 함수
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
        //recordingStartTime = nil
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
        if isRecording {
            // 촬영중이면 현재 촬영중인 영상을 중지하고 영상을 취소시켜야함
            recorder.stopRecording { [weak self] previewController, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Handle the error, possibly by informing the user
                    self.showAlert(title: "Stop Recording Error", message: error.localizedDescription)
                    return
                }
                
                // Optionally, present the previewController or decide to discard
                // Since you want to discard, proceed to call discardRecording
                self.recorder.discardRecording {
                    DispatchQueue.main.async {
                       
                        
                        // Successfully discarded the recording
                        print("Recording successfully discarded.")
                        
                        // Reset UI elements or states
                        self.isRecording = false
                        self.removeOverlayWindow()
                        self.sceneView.scene.rootNode.cleanup()
                        self.stopAllTimers()
                        
                        // Dismiss the view controller
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            // 촬영중이 아니면 그냥 깨끗하게 만들고 뒤로 가면 됨
            sceneView.scene.rootNode.cleanup()
            stopAllTimers()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - 시선 추적 코드들
    
    // Setup ARKit Scene View
    private func setupSceneView() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // 화면 회전등의 이유로 부모뷰의 사이즈가 바뀔때에 동적으로 같이 바뀌도록 함
        sceneView.delegate = self
        sceneView.session.delegate = self
        view.addSubview(sceneView)
        
        sceneView.scene.rootNode.addChildNode(faceNode) // All AR content is added to this root node, forming a hierarchical structure.
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
    
    
    // 눈위치 잡는 함수
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
                    // 1초 이상 시야가 벗어나면 시선추적 타이머 멈춤
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
//    private func startEyeTrackTimer() {
//        if lookTimer == nil { // Start only if not already running
//            lookTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//                guard let self = self else { return }
//                self.totalLookTime += 0.1
//                let eyeTimeString = String(format: "Time: %.1fs", self.totalLookTime)
//                NotificationCenter.default.post(name: .updateEyeTrackingTime, object: nil, userInfo: ["time": eyeTimeString])
//            }
//        }
//    }
    
    // MARK: - 시선추적 타이머
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
    
    
    // 얼마나 화면을 바라봤는지 비율 계산하는 함수
    private func calculateEyeTrackingTime() -> Int {
        var result = (totalLookTime / totalRecordingTime) * 100
//        debugPrint("totalLookTime: \(totalLookTime)")
//        debugPrint("totalRecordingTime: \(totalRecordingTime)")
//        debugPrint("result: \(result)")
        if result > 100 {
            result = 100.0
        }
        return Int(result.rounded())
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
            self.removeOverlayWindow()
            let alert = UIAlertController(title: "카메라 허용 거부됨", message: "화면 녹화를 할 수 없습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.backButtonTapped()
            })
            )
            present(alert, animated: true)
            return
        }
        
        recorder.isMicrophoneEnabled = true
        recorder.startRecording { [weak self] error in
            if let error = error {
                self?.removeOverlayWindow()
                let alert = UIAlertController(title: "에러", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self?.backButtonTapped()
                })
                )
                self?.present(alert, animated: true)
            } else {
                // MARK: - 타이머 시작
                //self?.recordingStartTime = Date()
                self?.startRecordingTimer()
                self?.isRecording = true
                if self?.isShowingMeSelected == false {
                    NotificationCenter.default.post(name: .coverScreenSelected, object: nil)
                }
                NotificationCenter.default.post(name: .updateUIAfterRecording, object: nil, userInfo: ["isRecording": true])
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
            
            // MARK: 분기 없앰
//            if isCreatingNewPresentation! {
//                newPracticeAfterNewPresentation!.eyePercentage = calculateEyeTrackingTime()
//            } else {
//                newPractice?.eyePercentage = calculateEyeTrackingTime()
//            }
            newPractice?.eyePercentage = calculateEyeTrackingTime()
            self.isRecording = false
            stopAllTimers()
            NotificationCenter.default.post(name: .updateUIAfterRecording, object: nil, userInfo: ["isRecording": false])
            NotificationCenter.default.post(name: .updateStartStopButtonTitle, object: nil, userInfo: ["title": "촬영 시작하기"])
            NotificationCenter.default.post(name: .updateEyeTrackingTime, object: nil, userInfo: ["time": "Time: 0.0s"])
            
            DispatchQueue.main.async {
                // 오버레이뷰를 없애줘야 터치가 되고 다음 화면에서도 안보임
                self.removeOverlayWindow()
                
                if let previewController = previewController {
                    previewController.previewControllerDelegate = self
                    previewController.modalPresentationStyle = .fullScreen
                    self.present(previewController, animated: true)
                }
            }
            
        }
    }
    
    // MARK: - 화면 녹화 타이머
    // 화면 녹화 타이머
    private func startRecordingTimer() {
        totalRecordingTime = 0
        recordingTimer?.invalidate() // Cancel existing timer if any
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            totalRecordingTime += 0.1
            let minutes = Int(totalRecordingTime) / 60
            let seconds = Int(totalRecordingTime) % 60
            
            let timeString = String(format: "%02d:%02d", minutes, seconds)
            NotificationCenter.default.post(name: .updateRecordingTime, object: nil, userInfo: ["time": timeString])
            
            if(totalRecordingTime < minTime! || totalRecordingTime > maxTime!){
                NotificationCenter.default.post(name: .timeoutOccurred, object: nil, userInfo: ["isInTime": false])
            } else {
                NotificationCenter.default.post(name: .timeoutOccurred, object: nil, userInfo: ["isInTime": true])
            }
            
        }
    }

    
    // MARK: - RPPreviewViewControllerDelegate
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // **Re-setup the overlay window after dismissing the preview**
            //self.setupOverlayWindow()
            
            // **Navigate to AnalyzingViewController**
            
//            debugPrint("previewControllerDidFinish 호출됨")
            self.determineUserActionAndNavigate()
        }
    }
   
    
    // MARK: - 프리뷰 창에서 다음 선택지 고르는 함수들
    
    // 유저가 프리뷰창에서 취소를 눌렀는지 저장을 눌렀는지 확인하고 다음 행동을 지정
    private func determineUserActionAndNavigate() {
        debugPrint("버튼 눌림")
        checkIfRecordingWasSaved { [weak self] wasSaved, assetIdentifier in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if wasSaved, let identifier = assetIdentifier {
//                    debugPrint("저장 누름")
                    // 저장을 눌렀을 경우 다음 페이지로 넘어감
                    self.navigateToAnalyzingViewController(with: identifier)
                } else {
                    // 취소를 누르면 HomeViewController로 돌아감
//                    debugPrint("취소 누름")
                    self.backButtonTapped()
                }
            }
        }
    }
    
    // 녹환된 비디오 저장하고 불러올때 저장된지 지정한 시간이내면 진행함
    private func checkIfRecordingWasSaved(completion: @escaping (Bool, String?) -> Void) {
//        debugPrint("checkIfRecordingWasSaved 함수 호출됨")
        // Request authorization to access Photos
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
//                    debugPrint("갤러리 권한 있음")
                    // 가장 최근 비디오 어셋을 가져옴
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.fetchLimit = 1 // 1개만 가져옴
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                    if let asset = fetchResult.firstObject, let creationDate = asset.creationDate {
//                        debugPrint("비디오 있음")
                        let timeSinceRecordingStopped = Date().timeIntervalSince(creationDate)
//                        debugPrint(timeSinceRecordingStopped)
                        // If the asset was created within the last 60 seconds, assume it was saved
                        if timeSinceRecordingStopped < 10 {
//                            debugPrint("10초내 생성된 비디오 확인됨")
                            completion(true, asset.localIdentifier)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                } else {
                    // If access is denied, assume the user canceled
                    completion(false, nil)
                }
            }
        }
    }
    
    // 다음 페이지로 넘어간다
    private func navigateToAnalyzingViewController(with identifier: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let analyzingVC: AnalyzingViewController
            
            // MARK: 분기 없앰
//            if isCreatingNewPresentation! {
//                newPracticeAfterNewPresentation!.videoKey = identifier
//                analyzingVC = AnalyzingViewController(newPracticeAfterNewPresentation: newPracticeAfterNewPresentation!)
//            } else {
//                analyzingVC = AnalyzingViewController(newPractice: newPractice!)
//            }
            
            newPractice!.videoKey = identifier
            analyzingVC = AnalyzingViewController(newPractice: newPractice!)
           
            
            if let navigationController = self.navigationController {
                navigationController.pushViewController(analyzingVC, animated: true)
            } else {
                // This block should rarely execute now, but kept for safety
                analyzingVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(analyzingVC, animated: true, completion: nil)
            }
        }
    }

    
    // MARK: - RPScreenRecorderDelegate
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWithError error: Error?, previewViewController: RPPreviewViewController?) {
        if let error = error {
            showAlert(title: "Recording Stopped with Error", message: error.localizedDescription)
        }
    }
}

