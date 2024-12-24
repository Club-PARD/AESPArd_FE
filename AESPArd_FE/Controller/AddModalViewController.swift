//
//  AddModalViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/23/24.
//

import UIKit

class AddModalViewController: UIViewController {

    // 클백할 때 이거 변수 다시 설정하기
    var presentationName: String = "발표이름"
    var presentationDate: Int = 1
    var presentationDetailCount: Int = 4
    private var previouslySelectedIndexPath: IndexPath?
    

    // 발표 영상 촬영하기 버튼
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("발표 영상 촬영하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        button.backgroundColor = UIColor(red: 0.82, green: 0.83, blue: 0.84, alpha: 1)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(moveTocameraViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 나가기 버튼
    let exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "X-iCon"), for: .normal)
        button.addTarget(self, action: #selector(exit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 새로 만드는 버튼
    let extraAddButton: UIButton = {
        let button = UIButton()
        button.setTitle(" 새로 추가하기", for: .normal)
        button.setTitleColor(UIColor(red: 0.62, green: 0.62, blue: 0.65, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.setImage(UIImage(named: "Plus-iCon"), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(moveToNewExtraModal), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 흰색 모달창
    let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 검은색 배경
    let backgroundOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var initialPanLocation: CGPoint = .zero // 배경이 움직이는 기준이 되는 포인트
    
    let tableView: UITableView = {
        let tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.backgroundColor = .white
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupPanGesture() // 드래그 제스처 활성화
        tableView.delegate = self
        tableView.dataSource = self
    }
    // MARK: - 2. 제약조건 생성 및 애니메이션 설정
    func setUI() {
        view.addSubview(backgroundOverlay)
        view.addSubview(modalView)
        modalView.addSubview(addButton)
        modalView.addSubview(exitButton)
        modalView.addSubview(extraAddButton)
        modalView.addSubview(tableView)
        
        

        NSLayoutConstraint.activate([
            backgroundOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            modalView.leadingAnchor.constraint(equalTo: backgroundOverlay.leadingAnchor),
            modalView.trailingAnchor.constraint(equalTo: backgroundOverlay.trailingAnchor),
            modalView.topAnchor.constraint(equalTo: backgroundOverlay.centerYAnchor),
            modalView.heightAnchor.constraint(equalTo: backgroundOverlay.heightAnchor, multiplier: 0.5),
            
            addButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: modalView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 52),

            exitButton.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 20),
            exitButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),

            extraAddButton.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 20),
            extraAddButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -10), // 추가
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20), // 추가
            
                ])

    }
    // 모달 뷰 애니메이션 설정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 초기 상태 설정
        modalView.alpha = 0

        // 애니메이션 시작 (페이드인 효과만 적용)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.modalView.alpha = 1 // 모달 페이드 인
        }, completion: nil)
    }
    
    // 배경 뷰 애니메이션 설정
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundOverlay.alpha = 0 // 초기상태 설정
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self .backgroundOverlay.alpha = 1 // 배경 페이드 인
        })
    }


    
    @objc func exit() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundOverlay.alpha = 0
            self.modalView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc func moveTocameraViewController() {
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true, completion: nil)
    }
    
    @objc func moveToNewExtraModal() {
        let extraVC = NewExtraModalViewController()
        present(extraVC, animated: true, completion: nil)
    }

    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        modalView.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            initialPanLocation = translation
        }
        
        if sender.state == .changed {
            let newY = modalView.frame.origin.y + translation.y - initialPanLocation.y
            if newY >= backgroundOverlay.center.y {
                modalView.frame.origin.y = newY
                sender.setTranslation(.zero, in: view)
            }
        }
        
        if sender.state == .ended {
            let shouldDismiss = modalView.frame.origin.y > backgroundOverlay.center.y + 50
            if shouldDismiss {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundOverlay.alpha = 0
                    self.modalView.alpha = 0
                }, completion: { _ in
                    self.dismiss(animated: false, completion: nil)
                })
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.modalView.frame.origin.y = self.backgroundOverlay.center.y
                }
            }
        }
    }
}
// MARK: - 3. tableView extension 생성
extension AddModalViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // 하나의 섹션
    }
    
    // 각 섹션의 행 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // 제목과 내용이 하나의 셀에 들어가므로 1개 행
    }
    
    // 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        cell.selectionStyle = .none // 기본 선택 효과 제거
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        // 제목 레이블
        let titleLabel = UILabel()
        titleLabel.text = presentationName // 제목 텍스트
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        titleLabel.textColor = UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(titleLabel)
        
        // 세부 내용 레이블
        let detailLabel = UILabel()
        detailLabel.text = "발표세부정보설명 · \(presentationDate)일 전" // 세부 내용 텍스트
        detailLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        detailLabel.textColor = UIColor.gray
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(detailLabel)
        
        // 카운트 배경 뷰 및 레이블 (독립적 추가)
        let countBackgroundView = UIView()
        countBackgroundView.backgroundColor = .clear
        countBackgroundView.layer.borderWidth = 1
        countBackgroundView.layer.borderColor = UIColor(red: 0.54, green: 0.68, blue: 1, alpha: 1).cgColor
        countBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        countBackgroundView.layer.cornerRadius = 11

        let countLabel = UILabel()
        countLabel.textColor = UIColor(red: 0.54, green: 0.68, blue: 1, alpha: 1)
        countLabel.font = UIFont(name: "Pretendard-Medium", size: 12)
        countLabel.textAlignment = .center
        countLabel.text = "\(presentationDetailCount)개"
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countBackgroundView.addSubview(countLabel)
        
        cell.contentView.addSubview(countBackgroundView)
        countBackgroundView.addSubview(countLabel)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 17),
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
            detailLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -17),
            
            cell.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            
            countBackgroundView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            countBackgroundView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            countBackgroundView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),

                // countLabel을 countBackgroundView 내부 중앙에 배치 및 패딩 적용
            countLabel.leadingAnchor.constraint(equalTo: countBackgroundView.leadingAnchor, constant: 7),
            countLabel.trailingAnchor.constraint(equalTo: countBackgroundView.trailingAnchor, constant: -7),
            countLabel.topAnchor.constraint(equalTo: countBackgroundView.topAnchor, constant: 2),
            countLabel.bottomAnchor.constraint(equalTo: countBackgroundView.bottomAnchor, constant: -2)
        ])
        
        // 레이아웃 계산 후 cornerRadius 적용
//        cell.layoutIfNeeded() // 레이아웃 강제 업데이트
//        let calculatedHeight = countLabel.intrinsicContentSize.height // 패딩 추가
//        let calculatedWidth = countLabel.intrinsicContentSize.width + 30
//        countBackgroundView.layer.cornerRadius = (calculatedHeight / 2) * 1.5
        
        return cell
    }
    
    
    
    
    // 셀 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72 // 셀 높이 설정 (상황에 따라 조정)
    }

     // 이전 선택된 셀의 IndexPath 저장

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 기존에 선택된 셀이 있으면 원래 상태로 복원
        if let previousIndex = previouslySelectedIndexPath {
            let previousCell = tableView.cellForRow(at: previousIndex)
            previousCell?.backgroundColor = .white
        }

        // 현재 선택된 셀의 배경색 변경
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 1, alpha: 1) // 연한 파란색 (셀의 색)
        
        addButton.backgroundColor = UIColor(red: 51/255, green: 112/255, blue: 255/255, alpha: 1) // 진한 파란색 (버튼의 색)


        // 현재 선택된 IndexPath 저장
        previouslySelectedIndexPath = indexPath
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 선택 해제된 셀을 원래 상태로 복원
        let deselectedCell = tableView.cellForRow(at: indexPath)
        deselectedCell?.backgroundColor = .white
        
        addButton.backgroundColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1) // 셀이 선택 해제되었을 때 버튼 색깔 반환
    }



    }

