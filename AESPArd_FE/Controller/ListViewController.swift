//
//  ListViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

class ListViewController : UIViewController, ListHeaderTableCellDelegate {
    
    //발표 폴더 이름
    var presentationFolderName :String = "협체발표"
    //발표연습 갯수
    var practiceCount :Int = 5
    
    //섹션 2
    //발표 연습 이름
    var practiceName : String = "번째 테이크"
    //발표 연습 날짜
    var practiceDate : String = "2023. 12. 20"
    //발표 연습 점수
    var practiceScore : Double =  0.84
    
    
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    let editPresentationView: EditPresentationView = {
        let view = EditPresentationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // 기본적으로 숨김
        view.layer.cornerRadius = 13
        //        view.clipsToBounds = true
        
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        return view
    }()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditViewToggleNotification), name: .editPresentationNotification, object: nil)
        
        // edit 이름 수정 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editNameAlert), name: .editNameNotification, object: nil)
        
        //edit 폴더 삭제 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editDeletePresentaionAlert), name: .deletePresentationFolderNotification, object: nil)
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: .editPresentationNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .editNameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .deletePresentationFolderNotification, object: nil)
    }
    
    private func setUI() {
        
        view.addSubview(tableView)
        view.addSubview(editPresentationView)
        
        // 각 섹션별 셀 등록
        tableView.register(LineGraphTableCell.self, forCellReuseIdentifier: "LineGraphTableCell")
        tableView.register(DeleteSelectedListTableCell.self, forCellReuseIdentifier: "DeleteSelectedListTableCell")
        tableView.register(PracticeListTableCell.self, forCellReuseIdentifier: "PracticeListTableCell")
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // EditPresentationView 레이아웃 설정
            editPresentationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            editPresentationView.widthAnchor.constraint(equalToConstant: 262),
            editPresentationView.heightAnchor.constraint(equalToConstant: 96),
            editPresentationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //            editPresentationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    
    
    // ListHeaderTableCellDelegate 메소드 - 뒤로가기 버튼
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
        print("2차")
    }
    
    //edit 버튼 클릭시 UIview 등장/숨기기 토글
    @objc func handleEditViewToggleNotification() {
        if !editPresentationView.isHidden {
            editPresentationView.isHidden = true
        } else {
            editPresentationView.isHidden = false
        }
    }
    
    // 이름 수정하기 Alert
    @objc func editNameAlert() {
        // Alert 생성
        let alertController = UIAlertController(title: "이름 수정하기", message: "해당 발표 파일의 이름을 수정할 수 있어요.", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alertController.addTextField { textField in
//            textField.placeholder = "새로운 이름"
            textField.text = self.presentationFolderName // 기존 이름을 텍스트 필드에 설정
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


    
    //발표 파일 삭제하기 Alert
    @objc func editDeletePresentaionAlert() {
        // 알림 컨트롤러 생성
        let alertController = UIAlertController(title: "발표 파일 삭제하기", message: "발표 파일을 삭제하시겠어요?\n이 작업은 되돌릴 수 없어요.", preferredStyle: .alert)
        
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
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 섹션 3개
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return practiceCount // 마지막 섹션은 행은 발표 연습 갯수만큼
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
            let headerCell = ListHeaderTableCell(style: .default, reuseIdentifier: "ListHeaderTableCell")
            headerCell.delegate = self  // 델리게이트 설정
            headerCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48) // 헤더의 높이를 48로 설정
            
            //폴더 이름 데이터 전달
            headerCell.configure(presentationFolderName: presentationFolderName)
            return headerCell
        }
        return UIView() // 빈 뷰를 반환하여 간격 제거
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 섹션에 맞는 셀을 반환
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphTableCell", for: indexPath) as! LineGraphTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteSelectedListTableCell", for: indexPath) as! DeleteSelectedListTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.configure(practiceCount: practiceCount)
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeListTableCell", for: indexPath) as! PracticeListTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.configure(practiceDate:practiceDate, practiceScore:practiceScore)
            
            //순서
            cell.recentCountButton.setTitle("\(indexPath[1]+1)", for: .normal)
            //발표 연습 이름 라벨
            cell.practiceNameLabel.text = "\(indexPath[1]+1)\(practiceName)"
            
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
            return 272 // 섹션 1의 셀 높이 - 중앙 선 그래프
        case 1:
            return 80 // 섹션 2의 셀 높이 - 발표 리스트 삭제 버튼
        case 2:
            return 68 // 박스 크기 60px + 아래 패딩 8px
        default:
            return 60 // 기본 셀 높이
        }
    }
    
    // 셀 클릭 시 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 섹션 2의 셀이 클릭되었을 때
        if indexPath.section == 2 {
            
            //            let modalViewController = ListViewController()
            //            modalViewController.modalPresentationStyle = .overCurrentContext // 탭바를 보이게 설정
            //            self.definesPresentationContext = true // 현재 컨텍스트를 정의
            //            self.present(modalViewController, animated: true)
            //
            //            // 선택된 셀을 강조 표시 (선택 해제 시 다시 원래 상태로 돌아가도록 설정)
            //            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

