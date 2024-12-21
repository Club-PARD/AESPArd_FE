//
//  MyViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/21/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableVIew = UITableView()
        tableVIew.translatesAutoresizingMaskIntoConstraints = false
        return tableVIew
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        setUI()
        
        // 섹션 구분선 숨기기
        tableView.separatorStyle = .none
    }
    
    
    func setUI(){
        
        view.addSubview(tableView)
        
        // 각 섹션별 셀 등록
        tableView.register(HeaderTableCell.self, forCellReuseIdentifier: "HeaderTableCell")
        tableView.register(ScoreGraphTableCell.self, forCellReuseIdentifier: "ScoreGraphTableCell")
        tableView.register(PTListFilterTableCell.self, forCellReuseIdentifier: "PTListFilterTableCell")
        tableView.register(PresentationListTableCell.self, forCellReuseIdentifier: "PresentationListTableCell")
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
}

// MARK: - 2. tableView extension 생성
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // 섹션 4개
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return 5 // 마지막 섹션은 행이 5개
        } else {
            return 1 // 나머지 섹션은 각 1개 행
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 섹션에 맞는 셀을 반환
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableCell", for: indexPath)
            // 셀에 데이터 설정 (필요한 설정 추가)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreGraphTableCell", for: indexPath)
            // 셀에 데이터 설정 (필요한 설정 추가)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PTListFilterTableCell", for: indexPath)
            // 셀에 데이터 설정 (필요한 설정 추가)
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationListTableCell", for: indexPath)
            // 셀에 데이터 설정 (필요한 설정 추가)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    // 셀의 높이를 다르게 설정
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        // 각 섹션과 행에 대해 다르게 설정
    //        switch indexPath.section {
    //        case 0:
    //            return 100 // 섹션 0의 셀 높이
    //        case 1:
    //            return 150 // 섹션 1의 셀 높이
    //        case 2:
    //            return 80 // 섹션 2의 셀 높이
    //        case 3:
    //            // 섹션 3의 행에 따라 다르게 설정
    //            if indexPath.row == 0 {
    //                return 120 // 섹션 3의 첫 번째 행은 높이를 120으로 설정
    //            } else if indexPath.row == 1 {
    //                return 80 // 섹션 3의 두 번째 행은 높이를 80으로 설정
    //            } else {
    //                return 60 // 나머지 행은 높이를 60으로 설정
    //            }
    //        default:
    //            return 60 // 기본 셀 높이
    //        }
    //    }
}
