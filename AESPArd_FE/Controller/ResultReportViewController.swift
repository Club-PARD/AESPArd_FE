//
//  ReportResultViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit

class ResultReportViewController: UIViewController,PracticeHeaderTableCellDelegate {
    
    var practiceName: String = "1번째 테이크" //발표 연습 이름
    var practiceTotalScore: Int = 88
    var itembarVaue : Double =  0.84 //원형 프로그레스바
    
    var itemNameList : [String] = ["발표 시간", "말의 빠르기", "목소리 크기", "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리"]
    var itemTotalScore : [Double] = [0.84, 0.44, 0.84, 0.84, 0.84, 0.84]
    var itemDetailList : [String] = ["7초 초과되었어요.", "조금 느린 편이에요. 조금만 빠르게 말해볼까요?", "발표에 딱 맞는 목소리 크기였어요!", "의식적으로 발화 지연 표현을 고치려고 노력해보세요!", "너무 많아요. 발표 내용을 더 숙지해보세요.", "훌륭해요! 실전에서도 관객과의 소통이 중요해요."]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        practiceHeaderView.delegate =  self
        
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
        setUI()
        
        //데이터 전달
        practiceHeaderView.configure(practiceName: practiceName)
        
        //edit 창 토글
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditViewToggleNotification), name: .editPracticeNotification, object: nil)
        
        // edit 이름 수정 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editNameAlert), name: .editPracticeNameNotification, object: nil)
        
        //edit 폴더 삭제 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editDeletePresentaionAlert), name: .deletePracticeNotification, object: nil)
        
        // 투명한 뷰에 터치 이벤트 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
        transparentOverlay.addGestureRecognizer(tapGesture)
        
        //총 점수
        practiceTotalScoreView.totalScoreLabel.text = "\(practiceTotalScore)점"

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
        
        NSLayoutConstraint.activate([
            
            practiceHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practiceHeaderView.heightAnchor.constraint(equalToConstant: 48),
            practiceHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            practiceHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            videoPlayerView.topAnchor.constraint(equalTo: practiceHeaderView.bottomAnchor),
            videoPlayerView.heightAnchor.constraint(equalToConstant: 316),
            videoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            practiceTotalScoreView.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor),
            practiceTotalScoreView.heightAnchor.constraint(equalToConstant: 100),
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
        print("2차")
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
    
    
    // 이름 수정하기 Alert
    @objc func editNameAlert() {
        // Alert 생성
        let alertController = UIAlertController(title: "이름 수정하기", message: "해당 연습 파일의 이름을 수정할 수 있어요.", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alertController.addTextField { textField in
            //            textField.placeholder = "새로운 이름"
            textField.text = self.practiceName // 기존 이름을 텍스트 필드에 설정
            //            textField.autocorrectionType = .no
            //            textField.spellCheckingType = .no
        }
        
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 확인 버튼 추가
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            // 텍스트 필드에서 입력된 이름을 가져옴
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                // 새로운 이름을 presentationFolderName에 반영
                //                self.presentationFolderName = newName
                //                print("새로운 이름: \(self.presentationFolderName)")
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // 마지막 섹션은 행은 평가 항목 갯수
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownDetailTableCell", for: indexPath) as! DropDownDetailTableCell
        // 셀에 데이터 설정 (필요한 설정 추가)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.configure(itemNameList: itemNameList[indexPath.row], itemTotalScore: itemTotalScore[indexPath.row], itemDetailList: itemDetailList[indexPath.row] )
        
        if(indexPath.row == 6){
            cell.itemName.textColor =  UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
            cell.dropDownButton.setImage(UIImage(named: "false-chevron"), for: .normal)
        }
        
        return cell
    }
    
    // 셀의 높이를 다르게 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 104 // 박스 크기 96px + 아래 패딩 8px
    }
}
