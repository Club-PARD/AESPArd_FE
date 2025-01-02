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
    var userName : String = "사용자"
    
    //막대 그래프 데이터
    var graphData: [CGFloat] = [0,0,0,0,0,0]
    
    // 필터링 모드
    var filterMode : String = "recent"
    // 삭제모드 여부
    var isDeleteMode : Bool = false
    //삭제하려고 선택한 리스트
    var selectedDeleteId : [String] = []
    
    
    // 필터 모드에 따라 데이터를 다시 로드
    @objc private func reloadDataBasedOnFilterMode() {
        if filterMode == "recent" {
            fetchPresentationList() // 최신순 데이터 요청
        } else if filterMode == "favorite" {
            fetchPresentationFavoriteList() // 중요도순 데이터 요청
        }
    }
    
    let header: HeaderLogoView = {
        let view = HeaderLogoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = false
        
        // 홈뷰에서 아래 함수들 없어도 되는지 확인하고 삭제할 것
//        getUserNameAPI()
//        getRecordsAverageAPI()
//        fetchPresentationList()
        
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
        
        //토글 patch시 중요도 순일 때
        NotificationCenter.default.addObserver(self,selector: #selector(patchToggleAPI(notification:)), name: .updateFavoriteNotification, object: nil)
        
        //my에서 서비스 초기화
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataBasedOnFilterMode), name: .didResetService, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .deleteCheckNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .selectedDeleteNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .searchButtonNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .latestNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .favoriteNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .updateFavoriteNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .didResetService, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserNameAPI()
        getRecordsAverageAPI()
        reloadDataBasedOnFilterMode()
    }
    
    //MARK: -  API
    
    //user
    @objc func getUserNameAPI() {
        networkManager.fetchUserById(userId: testId) { [weak self] result in
            switch result {
            case .success(let user):
                guard let userName = user.userName else {
                    print("User name is nil")
                    return
                }
                self?.userName = userName
                self?.tableView.reloadData()
            case .failure(let error):
                // Handle error
                print("Error fetching users: \(error)")
            }
        }
    }
    
    //막대그래프
    @objc func getRecordsAverageAPI() {
        networkManager.getRecordRecentAverage{ [weak self] result in
            switch result {
            case .success(let record):
                self?.graphData = record.map { CGFloat($0) }
                self?.tableView.reloadData()
            case .failure(let error):
                // Handle error
                print("Error fetching graph: \(error)")
            }
        }
    }
    
    // 발표 리스트를 최신순
    @objc func fetchPresentationList() {
        networkManager.fetchPresentaionLatestById(userId: testId) { [weak self] result in
            switch result {
            case .success(let presentationLatest):
                self?.ptList.removeAll()
                self?.ptList = presentationLatest
                self?.tableView.reloadData()
                
                self?.filterMode = "recent"
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error fetching recent presentations: \(error)")
            }
        }
    }
    
    // 발표 리스트를 중요도순
    @objc func fetchPresentationFavoriteList() {
        networkManager.fetchPresntaionFavoriteById(userId: testId) { [weak self] result in
            switch result {
            case .success(let presentationLatest):
                self?.ptList.removeAll()
                self?.ptList = presentationLatest
                self?.tableView.reloadData()
                
                self?.filterMode = "favorite"
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error fetching favorite presentations: \(error)")
            }
        }
    }
    
    // 토글 patch
    @objc func patchToggleAPI(notification: Notification) {
        if let userInfo = notification.userInfo,
           let ptId = userInfo["ptId"] as? String {
            networkManager.patchPTToggleFavoriteById(presentationId: ptId) { [weak self] result in
                switch result {
                case .success():
                    print("수정 성공")
                    self?.reloadDataBasedOnFilterMode()
                case .failure(let error):
                    // 실패 시 에러 처리
                    print("Error fetching presentations: \(error)")
                }
            }
        }
    }
    
    //MARK: -  제약조건
    
    func setUI(){
        
        view.addSubview(header)
        view.addSubview(tableView)
        
        // 각 섹션별 셀 등록
        tableView.register(ScoreGraphTableCell.self, forCellReuseIdentifier: "ScoreGraphTableCell")
        tableView.register(PTListFilterTableCell.self, forCellReuseIdentifier: "PTListFilterTableCell")
        tableView.register(PresentationListTableCell.self, forCellReuseIdentifier: "PresentationListTableCell")
        
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.heightAnchor.constraint(equalToConstant: 48),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
    
    // 삭제 버튼 상태를 토글하는 메서드
    @objc func handleButtonToggleNotification() {
        isDeleteMode.toggle()
        
        if !isDeleteMode {
            if(selectedDeleteId.count>0){
                deletePresenttaionAPI()
            }
            
            selectedDeleteId.removeAll()
        }else{
        }
        
        tableView.reloadData()
    }
    
    
    // 선택한 발표 리스트 삭제 API
    func deletePresenttaionAPI() {
        networkManager.deleteSelectedPresentation(presentationIds: selectedDeleteId){ [weak self] result in
            switch result {
            case .success():
                print("삭제 성공")
                self?.reloadDataBasedOnFilterMode()
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error fetching presentations: \(error)")
            }
        }
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
        // 섹션 1의 첫 번째 셀의 위치를 계산
        let section1FirstRowIndexPath = IndexPath(row: 0, section: 1)
        let section1FirstRowY = tableView.rectForRow(at: section1FirstRowIndexPath).origin.y
        
        // 테이블뷰의 콘텐츠 오프셋을 고려하여 최종 위치 계산
        let contentOffsetY = tableView.contentOffset.y
        let finalYPosition = section1FirstRowY + (contentOffsetY * -1)
        
        // SearchViewController에 finalYPosition을 전달
        let modalViewController = SearchViewController(finalYPosition: finalYPosition)
        modalViewController.modalPresentationStyle = .overCurrentContext
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
            if(selectedDeleteId.count  == 0){
                cell.deleteButton.setTitle("삭제하기", for: .normal)
            }
            else{
                cell.deleteButton.setTitle("\(selectedDeleteId.count)개 삭제하기", for: .normal)
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationListTableCell", for: indexPath) as! PresentationListTableCell
            let presentation = ptList[indexPath.row]
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.configure(presentationName: presentation.presentationName, ptDetailCount: presentation.totalPractices, presentationDate: presentation.updatedAtText, ptDetailTotalScore: presentation.totalPractices, barVaue: Double(presentation.totalScore) / 100.0, toggleFavorite: presentation.toggleFavorite, presentationId: presentation.presentationId, filterMode: filterMode)
            
            if(isDeleteMode){
                cell.bookmarkButton.isHidden = true
                cell.deleteCheckButton.isHidden = false
                
                // 삭제 선택한 리스트 있는지 확인
                if selectedDeleteId.contains(presentation.presentationId) {
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
            return 326 + 40 // 섹션 1의 셀 높이 - 중앙 그래프
        case 1:
            return 122 - 40// 섹션 2의 셀 높이 - 발표 리스트 필터
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
            
            let modalViewController = ListViewController(presentationData: ptList[indexPath.row])
            modalViewController.modalPresentationStyle = .overCurrentContext // 탭바를 보이게 설정
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


