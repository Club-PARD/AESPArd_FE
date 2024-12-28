//
//  MyViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/21/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    // 클백 연결을 위한 NesworkManager 연결
    private let networkManager = NetworkManager.shared
    let testId : String = URLClass().testID
    var ptList : [PresentationList]  = []//발표리스트 최신순
    
    
    //클백 연결 시 해당 변수명 변경 필요
    var userName : String = "규희"
    var presentationCount :Int = 10
    
    //막대 그래프 데이터
    //    let graphData: [CGFloat] = [82, 89, 68, 23, 100, 30]
    let graphData: [CGFloat] = [10,20,0,0,0,0]
    
    //발표 정보
    var presentationName : [String] = ["발표이름1", "발표이름2", "발표이름3", "발표이름4", "발표이름5", "발표이름6", "발표이름7", "발표이름8", "발표이름9", "발표이름10"]
    
    var ptDetailCount : Int = 4
    var presentationDate : String = ""
    var ptDetailTotalScore : Int = 88
    var barVaue: [Double] = [0.84, 0.77, 0.33, 0.66, 0.55,0.44, 0.22, 0.66, 0.11, 0.24 ]
    
    
    // 필터링 모드
    var filterMode : String = "recent"
    // 삭제모드 여부
    var isDeleteMode : Bool = false
    //삭제하려고 선택한 리스트
    var selectedDeleteId : [String] = []
    
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPresentationList()
        
        // 탭 바 컨트롤러의 delegate 설정
        self.tabBarController?.delegate = self
        
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
        
        //삭제 모드인지 확인
        NotificationCenter.default.addObserver(self, selector: #selector(handleButtonToggleNotification), name: .deleteCheckNotification, object: nil)
        
        //삭제할꺼 리스트 추가 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteSelection(_:)), name: .selectedDeleteNotification, object: nil)
        
        //검색버튼 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchNotification), name: .searchButtonNotification, object: nil)
        
        //최신순, 중요도순
        NotificationCenter.default.addObserver(self, selector: #selector(fetchPresentationList), name: .latestNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchPresentationFavoriteList), name: .favoriteNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .deleteCheckNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .selectedDeleteNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .searchButtonNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .latestNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .favoriteNotification, object: nil)
    }
    
    //MARK: -  API
    
    // 발표 리스트를 최신순
    @objc func fetchPresentationList() {
        networkManager.fetchPresentaionLatestById(userId: testId) { [weak self] result in
            switch result {
            case .success(let presentationLatest):
                // 기존 리스트를 비우고 새로 받은 데이터로 업데이트
                print("확인용- 최신", presentationLatest)
                self?.ptList.removeAll()
                self?.ptList = presentationLatest
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error fetching presentations: \(error)")
            }
        }
    }
    
    // 발표 리스트를 중요도순
    @objc func fetchPresentationFavoriteList() {
        networkManager.fetchPresntaionFavoriteById(userId: testId) { [weak self] result in
            switch result {
            case .success(let presentationLatest):
                // 기존 리스트를 비우고 새로 받은 데이터로 업데이트
                print("확인용", presentationLatest)
                self?.ptList.removeAll()
                self?.ptList = presentationLatest
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error fetching presentations: \(error)")
            }
        }
    }
    
    //MARK: -  제약조건
    
    func setUI(){
        
        view.addSubview(tableView)
        
        // 각 섹션별 셀 등록
        tableView.register(ScoreGraphTableCell.self, forCellReuseIdentifier: "ScoreGraphTableCell")
        tableView.register(PTListFilterTableCell.self, forCellReuseIdentifier: "PTListFilterTableCell")
        tableView.register(PresentationListTableCell.self, forCellReuseIdentifier: "PresentationListTableCell")
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
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
    
    //삭제 리스트 추가
    @objc func handleDeleteSelection(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let cellName = userInfo["cellName"] as? String else { return }
        
        if selectedDeleteId.contains(cellName) {
            selectedDeleteId.removeAll { $0 == cellName }
        } else {
            selectedDeleteId.append(cellName)
        }
        tableView.reloadData()
        //        print("Updated selectedDeleteId: \(selectedDeleteId)")
    }
    
    // 검색버튼 클릭 감지
    @objc func handleSearchNotification() {
        let modalViewController = SearchViewController()
        modalViewController.modalPresentationStyle = .overCurrentContext // 탭바를 보이게 설정
        self.definesPresentationContext = true // 현재 컨텍스트를 정의
        
        self.present(modalViewController, animated: true)
    }
    
}

// MARK: - 2. tableView extension 생성
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 섹션 3개
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return ptList.count // 마지막 섹션은 행은 발표 갯수만큼
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
            // HeaderTableCell을 0번 섹션의 헤더로 설정
            let headerCell = HeaderTableCell(style: .default, reuseIdentifier: "HeaderTableCell")
            headerCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48) // 헤더의 높이를 48로 설정
            return headerCell
        }
        return UIView() // 빈 뷰를 반환하여 간격 제거
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 섹션에 맞는 셀을 반환
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreGraphTableCell", for: indexPath) as! ScoreGraphTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            // 사용자 이름을 설정
            cell.configure(with: userName)
            cell.barGraphView.percentages = graphData //막대그래프 정보 전달
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PTListFilterTableCell", for: indexPath) as! PTListFilterTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.configure(with: ptList.count)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationListTableCell", for: indexPath) as! PresentationListTableCell
            let presentation = ptList[indexPath.row]
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.configure(presentationName: presentation.presentationName, ptDetailCount: presentation.totalPractices, presentationDate: presentation.updatedAtText, ptDetailTotalScore: presentation.totalPractices, barVaue: Double(presentation.totalScore) / 100.0, toggleFavorite: presentation.toggleFavorite, presentationId: presentation.presentationId)
            
            if(isDeleteMode){
                cell.bookmarkButton.isHidden = true
                cell.deleteCheckButton.isHidden = false
                
                // 삭제 선택한 리스트 있는지 확인
                if selectedDeleteId.contains(presentationName[indexPath.row]) {
                    // 이미 선택된 경우 체크 표시
                    cell.deleteCheckButton.setImage(UIImage(named: "check_O"), for: .normal)
                } else {
                    // 선택되지 않은 경우 X 표시
                    cell.deleteCheckButton.setImage(UIImage(named: "check_X"), for: .normal)
                }
            }
            else{
                cell.bookmarkButton.isHidden = false
                cell.deleteCheckButton.isHidden = true
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
            return 326 // 섹션 1의 셀 높이 - 중앙 그래프
        case 1:
            return 122 // 섹션 2의 셀 높이 - 발표 리스트 필터
        case 2:
            return 88 // 박스 크기 80px + 아래 패딩 8px
        default:
            return 60 // 기본 셀 높이
        }
    }
    
    // 셀 클릭 시 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 섹션 2의 셀이 클릭되었을 때
        if indexPath.section == 2 {
            
            let modalViewController = ListViewController()
            modalViewController.modalPresentationStyle = .overCurrentContext // 탭바를 보이게 설정
            //            modalViewController.view.backgroundColor = UIColor(white: 0, alpha: 0.5) // 배경을 투명하게 설정
            self.definesPresentationContext = true // 현재 컨텍스트를 정의
            self.present(modalViewController, animated: true)
            
        }
    }
}

// MARK: - 모달 창 열렸을 때 홈 버튼 클릭시 모달 꺼지도록 함
extension HomeViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 현재 선택된 탭이 HomeViewController일 때
        if let navController = viewController as? UINavigationController,
           let homeVC = navController.viewControllers.first as? HomeViewController {
            
            // 모든 모달 창 닫기
            dismissModalsRecursively(from: homeVC, isLastModal: true)
        }
        
        return true
    }
    
    private func dismissModalsRecursively(from viewController: UIViewController, isLastModal: Bool) {
        // 현재 모달 창이 있으면
        if let presentedVC = viewController.presentedViewController {
            // 먼저 뒤의 모달 창을 닫음
            dismissModalsRecursively(from: presentedVC, isLastModal: false)
            
            // 마지막 모달 창 여부에 따라 애니메이션 설정
            presentedVC.dismiss(animated: isLastModal)
        }
    }
}


