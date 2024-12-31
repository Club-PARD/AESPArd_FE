//
//  AddModalViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/23/24.
//

import UIKit

class AddModalViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private let networkManager = NetworkManager.shared
    private let testId : String = URLClass().testID
    private var presentationList : [PresentationForModal]  = []//발표리스트 최신순

    // 서버에서 받아온 데이터 저장할 변수들
    private var presentationName: String?
    private var updatedAtText: String?
    private var totalPractices: Int?
    private var numberOfPresentations: Int?
    
    // 다음 페이지에 전달해야 하는 카메라 세팅값 변수 들
    private var isShowingTimeSelected: Bool?
    private var isShowingMeSelected: Bool?
    private var minTime: Double?
    private var maxTime: Double?
    
    // 다음 페이지에 전달해야 할 변수
    private var userId: String?
    
    // 서버에 전달할 새로운 연습의 인스턴스
    private var newPractice: NewPractice = NewPractice()
    
    private var previouslySelectedIndexPath: IndexPath?
    
    
    // MARK: - 생성자 만들어야 함 userId 포함해서

    
    // 발표 영상 촬영하기 버튼
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("발표 영상 촬영하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        button.backgroundColor = UIColor(red: 0.82, green: 0.83, blue: 0.84, alpha: 1)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(moveTocameraViewController), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 나가기 버튼
    let exitButton: ExpandableButton = {
        let button = ExpandableButton()
        button.setImage(UIImage(named: "X-iCon"), for: .normal)
        button.addTarget(self, action: #selector(exit), for: .touchUpInside)
        button.touchAreaInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 새로 만드는 버튼
    let extraAddButton: UIButton = {
        let button = UIButton()
        button.setTitle(" 새로 추가하기", for: .normal)
        button.setTitleColor(UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.setImage(UIImage(named: "sipja"), for: .normal)
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
        let tableView = UITableView()
        tableView.register(AddModalTableViewCell.self, forCellReuseIdentifier: AddModalTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupPanGesture() // 드래그 제스처 활성화
        getAllPresentation()
        setupTapGestureForOverlay()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
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
    
    // MARK: - 서버 연결 함수
    func getAllPresentation() {
        
        networkManager.getAllPresentationsForModal(userId: testId) { [weak self] result in
            switch result {
            case .success(let presentationLatest):
                self?.presentationList.removeAll()
                self?.presentationList = presentationLatest
                self?.numberOfPresentations = self?.presentationList.count
                self?.tableView.reloadData()
                
            case .failure(let error):
                // 실패 시 에러 처리
                print("Error fetching presentations: \(error)")
            }
        }
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
    
    // MARK: - 다음 페이지로 넘어가는 함수
    @objc func moveTocameraViewController() {
        
        let cameraVC = CameraViewController(newPractice: newPractice, isShowingTimeSelected: isShowingTimeSelected!, isShowingMeSelected: isShowingMeSelected!, minTime: minTime!, maxTime: maxTime!, userId: testId)
        cameraVC.modalPresentationStyle = .custom
        present(cameraVC, animated: true, completion: nil)
    }
    
    @objc func moveToNewExtraModal() {
        let excludedView = backgroundOverlay // 제외할 뷰를 참조
        // MARK: - 유저 아이디 수정 해야함
        let extraVC = NewExtraModalViewController(userId: URLClass().testID)

        // 기존 뷰 제거 처리
        for subview in view.subviews {
            if subview != excludedView { // 제외할 뷰가 아니면
                UIView.animate(withDuration: 0.3, animations: {
                    subview.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height) // 아래로 슬라이드
                    subview.alpha = 0 // 동시에 투명도 줄이기
                }, completion: { _ in
                    subview.removeFromSuperview() // 애니메이션 완료 후 제거
                })
            }
        }

        // 애니메이션 후 새로운 모달 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 새로운 모달 뷰컨트롤러 추가
            self.addChild(extraVC) // `extraVC`를 자식 뷰 컨트롤러로 추가
            self.view.addSubview(extraVC.view) // `extraVC`의 뷰를 현재 뷰에 추가

            // 초기 위치 설정: 화면 아래에서 시작
            extraVC.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            extraVC.view.alpha = 0 // 투명도 0으로 설정

            // 제약 조건 추가
            extraVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                extraVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                extraVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                extraVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                extraVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])

            // 슬라이드 업 애니메이션
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                extraVC.view.transform = .identity // 원래 위치로 복귀
                extraVC.view.alpha = 1 // 투명도 1로 설정
            }, completion: { _ in
                extraVC.didMove(toParent: self) // 자식 뷰 컨트롤러 설정 완료
            })
        }
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
        return numberOfPresentations ?? 0 // 하나의 섹션
    }
    
    // 각 섹션의 행 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // 제목과 내용이 하나의 셀에 들어가므로 1개 행
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddModalTableViewCell.identifier, for: indexPath) as? AddModalTableViewCell else {return UITableViewCell()}
        
        if indexPath != previouslySelectedIndexPath {
               cell.backgroundColor = .white  // 초기화
               cell.selectionStyle = .none   // 선택 해제
               cell.layoutMargins = UIEdgeInsets.zero
               cell.preservesSuperviewLayoutMargins = false
           } else {
               // 선택된 셀은 색상을 변경하여 선택 상태 유지
               cell.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 1, alpha: 1)  // 연한 파란색
               cell.selectionStyle = .none // 선택 스타일을 설정
           }
        let presentation = presentationList[indexPath.section]
        presentationName = presentation.presentationName
        updatedAtText = presentation.updatedAtText
        totalPractices = presentation.totalPractices
        
        cell.configure(presentationName: presentationName!, updatedAtText: updatedAtText!, totalPractices: totalPractices!)
        
        if indexPath == previouslySelectedIndexPath {
               cell.isSelectedCell = true
           } else {
               cell.isSelectedCell = false
           }
        
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
        
        let selectedPresentation = presentationList[indexPath.section]
//        debugPrint("index: \(selectedPresentation)")
        newPractice.presentationId = selectedPresentation.presentationId
        self.isShowingMeSelected = selectedPresentation.showMeOnScreen
        self.isShowingTimeSelected = selectedPresentation.showTimeOnScreen
        self.minTime = selectedPresentation.idealMinTime
        self.maxTime = selectedPresentation.idealMaxTime
       
//        debugPrint("                                                ")
//        debugPrint("selectedPresentation.showMeOnScreen: \(selectedPresentation.showMeOnScreen)")
//        debugPrint("selectedPresentation.showTimeOnScreen: \(selectedPresentation.showTimeOnScreen)")
//        debugPrint("                                                ")
//        debugPrint("isShowingMeSelected: \(isShowingMeSelected)")
//        debugPrint("isShowingTimeSelected: \(isShowingTimeSelected)")
//        debugPrint("minTime: \(minTime)")
//        debugPrint("maxTime: \(maxTime)")
//        debugPrint("                                                ")
        // 버튼 활성화
        addButton.isEnabled = true
    }

    // 셀 선택 해제 시 버튼 비활성화 로직 수정
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 선택 해제된 셀을 원래 상태로 복원
        let deselectedCell = tableView.cellForRow(at: indexPath)
        deselectedCell?.backgroundColor = .white
        
        addButton.backgroundColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1) // 셀이 선택 해제되었을 때 버튼 색깔 반환
        
        // 선택된 셀이 없으면 버튼 비활성화
        if tableView.indexPathsForSelectedRows?.count == 0 {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor(red: 0.82, green: 0.83, blue: 0.84, alpha: 1) // 비활성화 색상
        }
    }
    func setupTapGestureForOverlay() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exit))
        backgroundOverlay.addGestureRecognizer(tapGesture)
    }
}
