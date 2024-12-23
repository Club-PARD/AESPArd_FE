//
//  MyViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/21/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    //클백 연결 시 해당 변수명 변경 필요
    var userName : String = "규희"
    var presentationCount :Int = 5
    
    //막대 그래프 데이터
    let graphData: [CGFloat] = [82, 89, 68, 23, 100, 30]
    
    //발표 정보
    var presentationName : String = "발표이름"
    var ptDetailCount : Int = 4
    var presentationDate : Int = 1
    var ptDetailTotalScore : Int = 88
    var barVaue: Double = 0.84
    
    
    // 필터링 모드
    var filterMode : String = "recent"
    // 삭제모드 여부
    var isDeleteMode : Bool = false
    //삭제하려고 선택한 리스트 갯수
    var selectDeleteCount : Int = 0
    
    
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

    }
    
    
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
}

// MARK: - 2. tableView extension 생성
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 섹션 4개
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return presentationCount // 마지막 섹션은 행은 발표 갯수만큼
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
            cell.configure(with: presentationCount)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationListTableCell", for: indexPath) as! PresentationListTableCell
            // 셀에 데이터 설정 (필요한 설정 추가)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.configure(presentationName: presentationName, ptDetailCount: ptDetailCount, presentationDate: presentationDate, ptDetailTotalScore: ptDetailTotalScore, barVaue: barVaue)
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

            if filterMode == "recent" {
                
            } else {
                
            }
            
            // 선택된 셀을 강조 표시 (선택 해제 시 다시 원래 상태로 돌아가도록 설정)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
