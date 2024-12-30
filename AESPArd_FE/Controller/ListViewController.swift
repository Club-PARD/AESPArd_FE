//
//  ListViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

class ListViewController : UIViewController, ListHeaderTableCellDelegate {
    
    // 클백 연결을 위한 NesworkManager 연결
    private let networkManager = NetworkManager.shared
    let testId : String = URLClass().testID
    
    var presentationData: PresentationList
    var practiceList : [GetPractice] = []
    
    // 초기화 메서드 정의
    init(presentationData: PresentationList) {
        self.presentationData = presentationData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //선 그래프 점수
    var scoreListData: [Double] = [82, 34, 67, 69, 89]
    
    
    // 삭제모드 여부
    var isDeleteMode : Bool = false
    //삭제하려고 선택한 리스트 
    var selectedDeleteId : [String] = []
    
    let header: ListHeaderView = {
        let view = ListHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    //edit 창 이외 클릭시에도 꺼지게 하도록 감지하는 투명 창
    let transparentOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear // 투명한 배경
        view.isHidden = true // 기본적으로 숨김
        return view
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
        
        //api
        getPracticeData()
        
        header.delegate = self
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
        header.headerLabel.text = presentationData.presentationName
        
        //edit 창 토글
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditViewToggleNotification), name: .editPresentationNotification, object: nil)
        
        // edit 이름 수정 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editNameAlert), name: .editNameNotification, object: nil)
        
        //edit 폴더 삭제 alert
        NotificationCenter.default.addObserver(self, selector: #selector(editDeletePresentaionAlert), name: .deletePresentationFolderNotification, object: nil)
        
        // 투명한 뷰에 터치 이벤트 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
        transparentOverlay.addGestureRecognizer(tapGesture)
        
        //삭제모드 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleButtonToggleNotification), name: .listDeleteCheckNotification, object: nil)
        
        //삭제할꺼 리스트 추가 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteSelection(_:)), name: .selectedDeletePracticeNotification, object: nil)
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: .editPresentationNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .editNameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .deletePresentationFolderNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .selectedDeletePracticeNotification, object: nil)
    }
    
    private func setUI() {
        
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(transparentOverlay) //edit창 이외 터치 이벤트 감지
        view.addSubview(editPresentationView)
        
        // 각 섹션별 셀 등록
        tableView.register(LineGraphTableCell.self, forCellReuseIdentifier: "LineGraphTableCell")
        tableView.register(DeleteSelectedListTableCell.self, forCellReuseIdentifier: "DeleteSelectedListTableCell")
        tableView.register(PracticeListTableCell.self, forCellReuseIdentifier: "PracticeListTableCell")
        
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.heightAnchor.constraint(equalToConstant: 48),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            transparentOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            transparentOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            transparentOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transparentOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            editPresentationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            editPresentationView.widthAnchor.constraint(equalToConstant: 262),
            editPresentationView.heightAnchor.constraint(equalToConstant: 96),
            editPresentationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //            editPresentationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    //MARK: - API
    @objc func getPracticeData() {
        networkManager.getPracticeByPresentationId(presentationId: presentationData.presentationId) { [weak self] result in
            switch result {
            case .success(let practices):
                self?.practiceList = practices
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error fetching practices: \(error)")
            }
        }
    }

    
    
    //MARK: - 버튼 메서드
    
    // ListHeaderTableCellDelegate 메소드 - 뒤로가기 버튼
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //edit 버튼 클릭시 UIview 등장/숨기기 토글
    @objc func handleEditViewToggleNotification() {
        if editPresentationView.isHidden {
            editPresentationView.isHidden = false
            transparentOverlay.isHidden = false // 투명 뷰 표시
        } else {
            hideEditView()
        }
    }
    
    @objc func handleOverlayTap() {
        hideEditView()
    }
    
    private func hideEditView() {
        editPresentationView.isHidden = true
        transparentOverlay.isHidden = true // 투명 뷰 숨기기
    }
    
    // 버튼 상태를 토글하는 메서드
    @objc func handleButtonToggleNotification() {
        isDeleteMode.toggle()
        
        if !isDeleteMode {
            //삭제 모드가 아니면 selectedDeleteId 배열 초기화
            selectedDeleteId.removeAll()
        }
        
        tableView.reloadData()
    }
    
    @objc func handleDeleteSelection(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let cellName = userInfo["cellName"] as? String else { return }
        
        if selectedDeleteId.contains(cellName) {
            selectedDeleteId.removeAll { $0 == cellName }
        } else {
            selectedDeleteId.append(cellName)
        }
        tableView.reloadData()

    }
 
    //MARK: -Alert 함수
    // 이름 수정하기 Alert
    @objc func editNameAlert() {
        // Alert 생성
        let alertController = UIAlertController(title: "이름 수정하기", message: "해당 발표 파일의 이름을 수정할 수 있어요.", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alertController.addTextField { textField in
            textField.text = self.presentationData.presentationName // 기존 이름을 텍스트 필드에 설정

        }
        
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 확인 버튼 추가
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            // 텍스트 필드에서 입력된 이름을 가져옴
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
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
            return practiceList.count // 마지막 섹션은 행은 발표 연습 갯수만큼
        } else {
            return 1 // 나머지 섹션은 각 1개 행
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 섹션에 맞는 셀을 반환
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphTableCell", for: indexPath) as! LineGraphTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            //데이터 전달
            cell.chartView.scoreData = scoreListData
            cell.chartView.setNeedsLayout() // 데이터 전달 후 차트 새로고침
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteSelectedListTableCell", for: indexPath) as! DeleteSelectedListTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.configure(practiceCount: practiceList.count)
        
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeListTableCell", for: indexPath) as! PracticeListTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.configure(practiceDate:practiceList[indexPath.row].createdAt, practiceScore: Double(practiceList[indexPath.row].totalScore) / 100.0, practiceId: practiceList[indexPath.row].id)
            
            //순서
            cell.recentCountButton.setTitle("\(indexPath[1]+1)", for: .normal)
            //발표 연습 이름 라벨
            cell.practiceNameLabel.text = "\(practiceList[indexPath.row].practiceName)"
            
            if(isDeleteMode){
                cell.recentCountButton.isHidden = true
                cell.selectedDeleteButton.isHidden = false
                
                // 삭제 선택한 리스트 있는지 확인
                if selectedDeleteId.contains("\(practiceList[indexPath.row].id)") {
                    // 이미 선택된 경우 체크 표시
                    cell.selectedDeleteButton.setImage(UIImage(named: "check_O"), for: .normal)
                } else {
                    // 선택되지 않은 경우 X 표시
                    cell.selectedDeleteButton.setImage(UIImage(named: "check_X"), for: .normal)
                }
            }
            else{
                cell.recentCountButton.isHidden = false
                cell.selectedDeleteButton.isHidden = true
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
            
            let modalViewController = ResultReportViewController()
            modalViewController.modalPresentationStyle = .overCurrentContext // 탭바를 보이게 설정
            self.definesPresentationContext = true // 현재 컨텍스트를 정의
            self.present(modalViewController, animated: true)
            
            // 선택된 셀을 강조 표시 (선택 해제 시 다시 원래 상태로 돌아가도록 설정)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

