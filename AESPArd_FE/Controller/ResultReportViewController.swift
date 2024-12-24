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
    
    var itemNameList : [String] = ["발표 시간", "말의 빠르기", "목소리 크기", "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리 비율", "발표 내용 AI 분석 기능"]
    var itemTotalScore : [Double] = [0.84, 0.44, 0.84, 0.84, 0.84, 0.84, -1.0]
    var itemDetailList : [String] = ["14초 초과되었어요", "조금 빠른 편이에요", "조금 작은 편이에요", "9회, 조금 많아요", "15회, 다소 많아요", "비율 기준치 작성", "유료 구독 시 이용 가능합니다"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
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
        
        //edit 창 토글
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditViewToggleNotification), name: .editPracticeNotification, object: nil)
        
        // edit 이름 수정 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editNameAlert), name: .editPracticeNameNotification, object: nil)
        
        //edit 폴더 삭제 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editDeletePresentaionAlert), name: .deletePracticeNotification, object: nil)
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: .editPracticeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .editPracticeNameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .deletePracticeNotification, object: nil)
    }
    
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
        
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        return view
    }()
    
    func setUI(){
        view.addSubview(tableView)
        view.addSubview(editPracticeView)
        
        // 각 섹션별 셀 등록
        tableView.register(VideoPlayerViewCell.self, forCellReuseIdentifier: "VideoPlayerViewCell")
        tableView.register(PracticeTotalScoreCell.self, forCellReuseIdentifier: "PracticeTotalScoreCell")
        tableView.register(DropDownDetailTableCell.self, forCellReuseIdentifier: "DropDownDetailTableCell") //드롭다운 닫힘
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            editPracticeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            editPracticeView.widthAnchor.constraint(equalToConstant: 262),
            editPracticeView.heightAnchor.constraint(equalToConstant: 96),
            editPracticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
        ])
    
    }
    
    // PracticeHeaderTableCellDelegate 메소드 - 뒤로가기 버튼
    func dismissPracticeViewController() {
        self.dismiss(animated: true, completion: nil)
        print("2차")
    }
    
    //edit 버튼 클릭시 UIview 등장/숨기기 토글
    @objc func handleEditViewToggleNotification() {
        if !editPracticeView.isHidden {
            editPracticeView.isHidden = true
        } else {
            editPracticeView.isHidden = false
        }
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
        return 3 // 섹션 3개
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 7 // 마지막 섹션은 행은 평가 항목 갯수
        } else {
            return 1 // 나머지 섹션은 각 1개 행
        }
    }
    
    // 섹션에 대한 헤더 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 0번 섹션에 대해서만 헤더 높이를 설정
        if section == 0 {
            return 48.0 // HeaderTableCell의 높이
        }
        return 0.0 // 나머지 섹션은 헤더를 표시하지 않음
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            // ListHeaderTableCell을 0번 섹션의 헤더로 설정
            let headerCell = PracticeHeaderTableCell(style: .default, reuseIdentifier: "PracticeHeaderTableCell")
                headerCell.delegate = self  // 델리게이트 설정
            headerCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48) // 헤더의 높이를 48로 설정
            
            //발표 연습 이름 데이터 전달
            headerCell.configure(practiceName: practiceName)
            return headerCell
        }
        return UIView() // 빈 뷰를 반환하여 간격 제거
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 섹션에 맞는 셀을 반환
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayerViewCell", for: indexPath) as! VideoPlayerViewCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeTotalScoreCell", for: indexPath) as! PracticeTotalScoreCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.totalScoreLabel.text = "\(practiceTotalScore)점"
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownDetailTableCell", for: indexPath) as! DropDownDetailTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.configure(itemNameList: itemNameList[indexPath.row], itemTotalScore: itemTotalScore[indexPath.row], itemDetailList: itemDetailList[indexPath.row] )
            
            if(indexPath.row == 6){
                cell.itemName.textColor =  UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
                cell.dropDownButton.setImage(UIImage(named: "false-chevron"), for: .normal)
//                cell.circularProgressBar.label = "???"
            }
            
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
            return 316 // 섹션 1의 셀 높이 - 발표 비디오 영상
        case 1:
            return 96 // 섹션 2의 셀 높이 - 발표 연습 총 점수
        case 2:
            return 88 // 박스 크기 80px + 아래 패딩 8px
            // or 190+8
        default:
            return 60 // 기본 셀 높이
        }
    }
}
