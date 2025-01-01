//
//  ReportResultViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit
import Photos
import AVKit

class ResultReportViewController: UIViewController,PracticeHeaderTableCellDelegate {
    
    // 클백 연결을 위한 NesworkManager 연결
    private let networkManager = NetworkManager.shared
    let testId : String = URLClass().testID
    
    var practiceData: GetPractice
    //Analysis get
    var reportsData : [GetReport] = []
    var mode: Bool = false
    
    //비디오 플레이어
    private var player: AVPlayer?
   
    // MARK: - 생성자
    // 셀 선택했을 때 분기
    init(practiceData: GetPractice) {
        self.practiceData = practiceData
        super.init(nibName: nil, bundle: nil)
        self.mode = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var itemNameList : [String] = ["발표 시간", "말의 빠르기", "목소리 크기", "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리"]
    
    //드롭다운 열렸을 경우 보여주는 값
    var evaluationList : [String] = ["내가 입력한 발표 시간", "발표에 적절한 WPM", "발표에 적절한 목소리 데시벨", "나의 발화 지연 횟수", "나의 불필요한 공백 횟수", "관객을 바라본 시선의 비율"]
    var myEvaluationlList : [String] = ["영상 발표 시간", "나의 WPM", "나의 목소리 데시벨"]
    
    //hep 버튼 텍스트
    var helpText : [String] = ["설정한 발표시간보다 부족하거나\n초과되었는지를 측정해요","WPM은 말의 속도를 나타내는 \n단위에요. 가장 이해하기 쉬운 \n속도를 기준으로 설정했어요", "마이크를 사용하거나\n작은공간에서의 발표를\n기준으로 측정한 점수에요", "“음..”, “어..”와 같은 표현을\n발화 지연 표현이라고 해요", "3초 이상의 불필요한\n공백을 감지해요", "전체 영상 중 화면을\n바라본 비율을 측정해요 "]
    
    // 드롭다운 상태 저장
    var dropDownStates: [Bool] = Array(repeating: false, count: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        practiceHeaderView.delegate =  self
        
        //탭바 중앙 버튼 클릭 감지
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoPlayback), name: .pauseVideoPlayerNotificaion, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoPlayback), name: .        stopVideonPlayerNotification, object: nil)
        
        //API
        if(!mode){
            getPracticeData()
        }
        
        setUI()
        
        // 섹션 구분선 숨기기
        tableView.separatorStyle = .none
        
        // 탭 바의 구분선 제거
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        //데이터 전달
        practiceHeaderView.configure(practiceName: practiceData.practiceName)
        
        //edit 창 토글
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditViewToggleNotification), name: .editPracticeNotification, object: nil)
        
        // edit 이름 수정 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editNameAlert), name: .editPracticeNameNotification, object: nil)
        
        //edit 폴더 삭제 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editDeletePresentaionAlert), name: .deletePracticeNotification, object: nil)
        
        // 투명한 뷰에 터치 이벤트 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
        transparentOverlay.addGestureRecognizer(tapGesture)
        
        //비디오 플레이어
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.fetchPHAssetFromIdentifier(identifier: self.practiceData.videoKey)
                } else {
                    print("사진 라이브러리 접근 권한이 필요합니다.")
                }
            }
        }
        
        //총 점수
        practiceTotalScoreView.totalScoreLabel.text = "\(practiceData.totalScore)점"
        
        if Double(practiceData.totalScore)/100.0 <= 0.6 {
            practiceTotalScoreView.totalScoreView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1) // 빨간색
        } else if Double(practiceData.totalScore)/100.0 <= 0.8 {
            practiceTotalScoreView.totalScoreView.backgroundColor = UIColor(red: 1, green: 0.717, blue: 0, alpha: 1) // 주황색
        } else {
            practiceTotalScoreView.totalScoreView.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0.2, alpha: 1) // 초록색
        }
        
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: .editPracticeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .editPracticeNameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .deletePracticeNotification, object: nil)
    }
    
    //MARK: - 클로저로 UI 생성
    let practiceHeaderView: PracticeHeaderView = {
        let view = PracticeHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let videoPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let practiceTotalScoreView: PracticeTotalScoreView = {
        let view = PracticeTotalScoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //        view.totalScoreLabel.text = "\(practiceTotalScore)점"
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    let editPracticeView: EditPracticeView = {
        let view = EditPracticeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // 기본적으로 숨김
        view.layer.cornerRadius = 13
        //        view.delegate = self
        
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        return view
    }()
    
    //edit 창 이외 클릭시에도 꺼지게 하도록 감지하는 투명 창
    let transparentOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear // 투명한 배경
        view.isHidden = true // 기본적으로 숨김
        return view
    }()
    
    // MARK: - API
    @objc func getPracticeData() {
        networkManager.getReportsByAnalysis(analysisId: practiceData.analysisId) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let desiredOrder = ["duration", "speechSpeed", "decibel", "fillers", "blanks", "eyeTracking"]
                    let sortedData = desiredOrder.compactMap { name in
                        return response.first { $0.name == name }
                    }
                    self?.reportsData = sortedData
                    self?.tableView.reloadData()
                } catch {
                    print("Error decoding practices: \(error)")
                }
            case .failure(let error):
                print("Error fetching practices: \(error)")
            }
        }
    }
    
    
    //MARK: - 제약조건
    func setUI(){
        
        view.addSubview(practiceHeaderView)
        view.addSubview(videoPlayerView)
        view.addSubview(practiceTotalScoreView)
        
        view.addSubview(tableView)
        view.addSubview(transparentOverlay) //edit창 이외 터치 이벤트 감지
        view.addSubview(editPracticeView)
        
        // 각 섹션별 셀 등록
        tableView.register(DropDownDetailTableCell.self, forCellReuseIdentifier: "DropDownDetailTableCell") //드롭다운 닫힘
        tableView.register(GoToEvaluationCell.self, forCellReuseIdentifier: "GoToEvaluationCell")
        
        NSLayoutConstraint.activate([
            
            practiceHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practiceHeaderView.heightAnchor.constraint(equalToConstant: 48),
            practiceHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            practiceHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            videoPlayerView.topAnchor.constraint(equalTo: practiceHeaderView.bottomAnchor),
            videoPlayerView.heightAnchor.constraint(equalToConstant: 225),
            videoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            practiceTotalScoreView.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor),
            practiceTotalScoreView.heightAnchor.constraint(equalToConstant: 80),
            practiceTotalScoreView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            practiceTotalScoreView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: practiceTotalScoreView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            transparentOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            transparentOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            transparentOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transparentOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            editPracticeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            editPracticeView.widthAnchor.constraint(equalToConstant: 262),
            editPracticeView.heightAnchor.constraint(equalToConstant: 96),
            editPracticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
        ])
        
    }
    
    //MARK: - 관련 메서드
    
    // PracticeHeaderTableCellDelegate 메소드 - 뒤로가기 버튼
    func dismissPracticeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //edit 버튼 클릭시 UIview 등장/숨기기 토글
    @objc func handleEditViewToggleNotification() {
        if editPracticeView.isHidden {
            editPracticeView.isHidden = false
            transparentOverlay.isHidden = false // 투명 뷰 표시
        } else {
            hideEditView()
        }
    }
    
    @objc func handleOverlayTap() {
        hideEditView()
    }
    
    private func hideEditView() {
        editPracticeView.isHidden = true
        transparentOverlay.isHidden = true // 투명 뷰 숨기기
    }
    
    //MARK: - 비디오 플레이어 관련 함수
    
    //비디오 관련 함수
    // videoKey로 PHAsset 찾기
    func fetchPHAssetFromIdentifier(identifier: String) {
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject {
            // PHAsset을 찾았다면 비디오를 가져와서 재생
            fetchVideoFromPHAsset(asset: asset)
        } else {
            print("해당 identifier에 대한 PHAsset을 찾을 수 없습니다.")
        }
    }

    // PHAsset에서 비디오 URL을 가져오는 함수
    func fetchVideoFromPHAsset(asset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] avAsset, audioMix, info in
            guard let self = self else { return }
            
            if let urlAsset = avAsset as? AVURLAsset {
                let videoURL = urlAsset.url
                
                DispatchQueue.main.async {
                    // 기존 플레이어 제거
                    self.removeCurrentVideoPlayer()
                    
                    // 새 비디오 로드 및 재생
                    self.setupVideoPlayer(with: videoURL)
                }
            }
        }
    }

    // AVPlayerViewController로 비디오를 재생
    private func setupVideoPlayer(with url: URL) {
        player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // 비디오를 띄울 UIView에 AVPlayerViewController의 view를 추가
        self.addChild(playerViewController)
        playerViewController.view.frame = self.videoPlayerView.customView.bounds
        self.videoPlayerView.customView.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        // 비디오 재생 시작
        player?.play()
    }


    // 기존 비디오 플레이어 제거
    private func removeCurrentVideoPlayer() {
        // 현재 화면에 있는 AVPlayerViewController를 찾아서 제거
        for child in children {
            if let playerViewController = child as? AVPlayerViewController {
                playerViewController.player?.pause() // 비디오 정지
                playerViewController.view.removeFromSuperview() // 화면에서 제거
                playerViewController.removeFromParent() // 자식 뷰컨트롤러에서 제거
            }
        }
    }
    
    //MARK: - alert 함수
    
    // 이름 수정하기 Alert
    @objc func editNameAlert() {
        // Alert 생성
        let alertController = UIAlertController(title: "이름 수정하기", message: "해당 연습 파일의 이름을 수정할 수 있어요.", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alertController.addTextField { textField in
            //            textField.placeholder = "새로운 이름"
            textField.text = self.practiceData.practiceName // 기존 이름을 텍스트 필드에 설정
            //            textField.autocorrectionType = .no
            //            textField.spellCheckingType = .no
        }
        
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 확인 버튼 추가
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            // 텍스트 필드에서 입력된 이름을 가져옴
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                self.practiceHeaderView.headerLabel.text = newName
            }
        }
        
        // 버튼들 추가
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        // 알림 표시
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    //연습 파일 삭제하기 Alert
    @objc func editDeletePresentaionAlert() {
        // 알림 컨트롤러 생성
        let alertController = UIAlertController(title: "연습 파일 삭제하기", message: "연습 파일을 삭제하시겠어요?\n이 작업은 되돌릴 수 없어요.", preferredStyle: .alert)
        
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 삭제 버튼 추가
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
            print("삭제됨")
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        // 알림 표시
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - 2. tableView extension 생성
extension ResultReportViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return reportsData.count // 마지막 섹션은 행은 평가 항목 갯수
        } else {
            return 1 // 나머지 섹션은 각 1개 행
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 섹션에 맞는 셀을 반환
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownDetailTableCell", for: indexPath) as! DropDownDetailTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.configure(itemNameList: itemNameList[indexPath.row], itemTotalScore: Double(reportsData[indexPath.row].score)/100.0, itemDetailList: reportsData[indexPath.row].feedbackMessage, rowIndex: indexPath.row)
            
            // 드롭다운 버튼 클릭 시 상태 변경
            cell.dropDownButton.addTarget(self, action: #selector(dropDownButtonTapped(_:)), for: .touchUpInside)
            cell.dropDownButton.tag = indexPath.row
            
            //드롭다운 열렸을 경우 보여줄 값 지정
            cell.evaluationLabel.text = evaluationList[indexPath.row]
            
            if(indexPath.row<3){
                cell.myEvaluationLabel.text = myEvaluationlList[indexPath.row]
            }else{
                cell.myEvaluationLabel.text = ""
            }
            //수정 필요
            switch indexPath.row {
            case 0:
                cell.evaluationValueLabel.text = "???"
                cell.myValueLabel.text = formatTime(seconds: reportsData[indexPath.row].counter)
            case 1:
                cell.evaluationValueLabel.text = "???WPM"
                cell.myValueLabel.text = "\(reportsData[indexPath.row].counter)WPM"
            case 2:
                cell.evaluationValueLabel.text = "???dB"
                cell.myValueLabel.text = "\(reportsData[indexPath.row].counter)dB"
            case 3:
                cell.evaluationValueLabel.text = "\(reportsData[indexPath.row].counter)회"
                cell.myValueLabel.text = ""
            case 4:
                cell.evaluationValueLabel.text = "\(reportsData[indexPath.row].counter)회"
                cell.myValueLabel.text = ""
            default:
                cell.evaluationValueLabel.text = "\(reportsData[indexPath.row].counter)%"
                cell.myValueLabel.text = ""
            }
            
            cell.helpLabel.text = helpText[indexPath.row]

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoToEvaluationCell", for: indexPath) as! GoToEvaluationCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // 셀의 높이를 다르게 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 각 섹션과 행에 대해 다르게 설정
        switch indexPath.section {
        case 0:
            if dropDownStates[indexPath.row] {
                // 드롭다운이 열려 있는 경우
                if indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 {
                    // 3, 4, 5번 행에 대해 높이를 143으로 설정
                    return 143
                } else {
                    // 그 외의 행에 대해서는 168로 설정
                    return 168
                }
            } else {
                // 드롭다운이 닫혀 있는 경우
                return 104
            }
        default:
            return 72
        }
    }

    
    // MARK: - 드롭다운 버튼 메서드
    @objc func dropDownButtonTapped(_ sender: UIButton) {
        
        let rowIndex = sender.tag
        dropDownStates[rowIndex].toggle() // 상태 토글
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // 초를 MM:SS 형태로 변환 메서드
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    @objc func stopVideoPlayback() {
        if var player = self.player, player.timeControlStatus == .playing {
            player.pause()
        }
    }
}



