//
//  ListViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

class ListViewController : UIViewController, ListHeaderTableCellDelegate {
    
    //발표연습 갯수
    var practiceCount :Int = 5
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
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
    }
    
    private func setUI() {
        
        view.addSubview(tableView)
        
        // 각 섹션별 셀 등록
        tableView.register(LineGraphTableCell.self, forCellReuseIdentifier: "LineGraphTableCell")
        tableView.register(DeleteSelectedListTableCell.self, forCellReuseIdentifier: "DeleteSelectedListTableCell")
        tableView.register(PracticeListTableCell.self, forCellReuseIdentifier: "PracticeListTableCell")
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    
    
    // ListHeaderTableCellDelegate 메소드 - 뒤로가기 버튼
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
        print("2차")
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
 
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeListTableCell", for: indexPath) as! PracticeListTableCell
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
            return 272 // 섹션 1의 셀 높이 - 중앙 선 그래프
        case 1:
            return 80 // 섹션 2의 셀 높이 - 발표 리스트 삭제 버튼
        case 2:
            return 68 // 박스 크기 60px + 아래 패딩 8px
        default:
            return 60 // 기본 셀 높이
        }
    }
    
    
}
