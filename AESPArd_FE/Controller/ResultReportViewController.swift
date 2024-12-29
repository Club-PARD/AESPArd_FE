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
    
    //드롭다운 열렸을 경우 보여주는 값
    var evaluationList : [String] = ["내가 입력한 발표 시간", "발표에 적절한 WPM", "발표에 적절한 목소리 데시벨", "나의 발화 지연 횟수", "나의 불필요한 공백 횟수", "관객을 바라본 시선의 비율"]
    var myEvaluationlList : [String] = ["영상 발표 시간", "나의 WPM", "나의 목소리 데시벨"]
    
    var evaluationValuelList : [String] = ["05:30~07:30", "???WPM", "???dB", "9회", "5회", "???%"]
    var myEvaluationValuelList : [String] = ["07:44", "???WPM", "???dB"]
    
    //hep 버튼 텍스트
    var helpText : [String] = ["설정한 발표시간보다 부족하거나\n초과되었는지를 측정합니다","WPM은 말의 속도를 측정하는\n단위에요 사람이 알아듣기 가장\n적절한 WPM을 기준으로 설정했어요", "마이크를 사용하거나\n작은공간에서의 발표를\n기준으로 측정한 점수에요", "“음..”, “어..”와 같은 표현을\n발화 지연 표현이라고 해요", "3초 이상의 불필요한\n공백을 감지해요", "전체 영상 중 화면을\n바라본 비율을 측정해요 "]
    
    // 드롭다운 상태 저장
    var dropDownStates: [Bool] = Array(repeating: false, count: 6)
    
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6 // 마지막 섹션은 행은 평가 항목 갯수
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
            
            cell.configure(itemNameList: itemNameList[indexPath.row], itemTotalScore: itemTotalScore[indexPath.row], itemDetailList: itemDetailList[indexPath.row] , rowIndex: indexPath.row)
            
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
            cell.evaluationValueLabel.text = evaluationValuelList[indexPath.row]
            if(indexPath.row<3){
                cell.myValueLabel.text = myEvaluationValuelList[indexPath.row]
            }else{
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
}
