//
//  SearchViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/27/24.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var finalYPosition: CGFloat = 0.0
    private var searchBarWidthConstraint: NSLayoutConstraint?
    
    init(finalYPosition: CGFloat) {
        self.finalYPosition = finalYPosition
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 클백 연결을 위한 NesworkManager 연결
    private let networkManager = NetworkManager.shared
    let testId : String = URLClass().testID
    var ptList : [PresentationList]  = []//발표리스트 최신순
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 0)
        searchBarWidthConstraint?.isActive = true
        
        //발표 리스트 최신순 API
        networkManager.fetchPresentaionLatestById(userId: testId) { [weak self] result in
            switch result {
            case .success(let presentationLatest):
                self?.ptList = presentationLatest
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                // Handle error
                print("Error fetching users: \(error)")
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
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
        
        self.view.frame.origin.y =  self.finalYPosition * -1
        
        setUI()
        
        //토글 patch
        NotificationCenter.default.addObserver(self,selector: #selector(patchToggleAPI(notification:)), name: .updateFavoriteNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 애니메이션 시작
        UIView.animate(withDuration: 0.4, animations: {
            if let searchBarWidthConstraint = self.searchBar.constraints.first(where: { $0.firstAttribute == .width }) {
                searchBarWidthConstraint.constant = self.view.frame.width - 32
            }
            
            self.view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
                self.closeButton.isHidden = false
            })
    }


    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        // 보더를 제거하려면 아래 코드 추가
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
        
        return view
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "연습 목록을 검색하세요"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // 서치바 배경색 설정
        searchBar.backgroundColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.layer.cornerRadius = 20 // 둥근 모서리 설정
        searchBar.clipsToBounds = true
        
        // 서치바의 테두리 제거 (선 안 보이게)
        searchBar.layer.borderWidth = 0
        searchBar.layer.borderColor = UIColor.clear.cgColor
        
        searchBar.searchTextField.leftView = nil
        searchBar.searchTextField.leftViewMode = .never
        searchBar.searchTextField.clearButtonMode = .never
        
        // 서치바 스타일 제거
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.searchTextField.backgroundColor = .clear
        //        searchBar.layer.masksToBounds = false
        searchBar.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        searchBar.layer.shadowOpacity = 1
        searchBar.layer.shadowRadius = 15
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // 서치바의 텍스트 필드 커스터마이징
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear // 텍스트 필드 배경색을 서치바와 동일하게 설정
            textField.textColor = .black
            textField.font = UIFont(name: "Pretendard-Medium", size: 16)
            
            textField.layer.borderWidth = 0 // 텍스트 필드 테두리 제거
            textField.layer.borderColor = UIColor.clear.cgColor
            
            // 플레이스홀더 속성 설정
            let placeholderColor = UIColor(red: 0.824, green: 0.827, blue: 0.835, alpha: 1)
            textField.attributedPlaceholder = NSAttributedString(
                string: "연습 목록을 검색하세요",
                attributes: [
                    .foregroundColor: placeholderColor,
                ]
            )
            
        }
        return searchBar
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "x-close"), for: .normal)
        button.addTarget(self, action: #selector(searchBarCloseButtonTapped), for: .touchUpInside)
        //        button.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        button.isHidden = true
        return button
    }()
    
    func setUI(){
        
        
        view.addSubview(containerView)
        containerView.addSubview(searchBar)
        containerView.addSubview(closeButton)
        view.addSubview(tableView)
        
        tableView.register(PresentationListTableCell.self, forCellReuseIdentifier: "PresentationListTableCell")
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            searchBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
//            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -28),
            
            tableView.topAnchor.constraint(equalTo: containerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func searchBarCloseButtonTapped() {
        searchBar.text = ""
        searchBar.resignFirstResponder() // 키보드 숨기기
        tableView.reloadData()
            
        // 모달이 사라지면서 검색바 너비 줄이기
        UIView.animate(withDuration: 0.5, animations: {
            // 검색바 너비 줄이기
            if let searchBarWidthConstraint = self.searchBar.constraints.first(where: { $0.firstAttribute == .width }) {
                searchBarWidthConstraint.constant = 0 // 검색바 너비를 0으로 줄임
            }
            
            // 모달 뷰 위치 변경
            self.view.frame.origin.y = self.finalYPosition + 48
            
            // 레이아웃 업데이트
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.closeButton.isHidden = true
            // 애니메이션 완료 후 모달 닫기
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    //MARK: - API
    // 토글 patch
    @objc func patchToggleAPI(notification: Notification) {
        if let userInfo = notification.userInfo,
           let ptId = userInfo["ptId"] as? String {
            networkManager.patchPTToggleFavoriteById(presentationId: ptId) { [weak self] result in
                switch result {
                case .success():
                    print("수정 성공")
                case .failure(let error):
                    // 실패 시 에러 처리
                    print("Error fetching presentations: \(error)")
                }
            }
        }
    }
    
    func searchPresentationsAPI(searchTerm: String) {
        networkManager.searchPresentations(searchTerm: searchTerm) { [weak self] result in
            switch result {
            case .success(let presentations):
                print("검색 성공: \(presentations)")
                self?.ptList = presentations
                self?.tableView.reloadData()
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error searching presentations: \(error)")
            }
        }
    }

    
}

//MARK: -  테이블뷰
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ptList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationListTableCell", for: indexPath) as! PresentationListTableCell
        let presentation = ptList[indexPath.row]
        // 셀에 데이터 설정 (필요한 설정 추가)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.configure(presentationName: presentation.presentationName, ptDetailCount: presentation.totalPractices, presentationDate: presentation.updatedAtText, ptDetailTotalScore: presentation.totalPractices, barVaue: Double(presentation.totalScore) / 100.0, toggleFavorite: presentation.toggleFavorite, presentationId: presentation.presentationId, filterMode: "recent")
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88 // 박스 크기 80px + 아래 패딩 8px
    }
    
    
    // 셀 클릭 시 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        
        let modalViewController = ListViewController(presentationData: ptList[indexPath.row])
        modalViewController.modalPresentationStyle = .overCurrentContext // 탭바를 보이게 설정
        self.definesPresentationContext = true // 현재 컨텍스트를 정의
        self.present(modalViewController, animated: true)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

//MARK: - SearchBar
extension SearchViewController: UISearchBarDelegate {
    // 검색 버튼 클릭
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // 키보드 숨기기
        
        // 입력된 텍스트 가져오기
        if let searchTerm = searchBar.text, !searchTerm.isEmpty {
            // 입력된 텍스트가 있을 때 searchPresentationsAPI 호출
            searchPresentationsAPI(searchTerm: searchTerm)
        }
    }
}
