//
//  SearchViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/27/24.
//

import UIKit

class SearchViewController: UIViewController {
    
    var presentationCount :Int = 10
    
    //발표 정보
    var presentationName : [String] = ["발표이름1", "발표이름2", "발표이름3", "발표이름4", "발표이름5", "발표이름6", "발표이름7", "발표이름8", "발표이름9", "발표이름10"]
    
    var ptDetailCount : Int = 4
    var presentationDate : Int = 1
    var ptDetailTotalScore : Int = 88
    var barVaue: [Double] = [0.84, 0.77, 0.33, 0.66, 0.55,0.44, 0.22, 0.66, 0.11, 0.24 ]
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        //        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
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
        
        //        self.view.frame.origin.y = -448 //헤더 미포함
        self.view.frame.origin.y = -388
        
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 애니메이션을 통해 388 포인트 아래에서 위로 올라오도록 설정
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = 0  // 화면 상단으로 이동
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
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
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
        
        // 모달이 사라지는 애니메이션
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = 400 // 모달을 아래로 내리는 애니메이션
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil) // 애니메이션 완료 후 모달 닫기
        })
    }
    
}

//MARK: -  테이블뷰
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationListTableCell", for: indexPath) as! PresentationListTableCell
        // 셀에 데이터 설정 (필요한 설정 추가)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.configure(presentationName: presentationName[indexPath.row], ptDetailCount: ptDetailCount, presentationDate: presentationDate, ptDetailTotalScore: ptDetailTotalScore, barVaue: barVaue[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88 // 박스 크기 80px + 아래 패딩 8px
    }
    
    
    // 셀 클릭 시 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        
        let modalViewController = ListViewController()
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
    }
}
