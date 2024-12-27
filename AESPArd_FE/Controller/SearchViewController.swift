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
        
        self.view.frame.origin.y = -448
        
        setUI()
    }
    
    func setUI(){
        
        view.addSubview(tableView)
        
        tableView.register(PresentationListTableCell.self, forCellReuseIdentifier: "PresentationListTableCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 애니메이션을 통해 448 포인트 아래에서 위로 올라오도록 설정
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = 0  // 화면 상단으로 이동
        })
    }
}

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
    
}
