//
//  ViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/16/24.
//

import UIKit

class ViewController: UITabBarController {
    
    // 중앙 버튼
    private let centralButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 내비게이션 바 숨기기
        self.navigationController?.isNavigationBarHidden = true
        
        setTabBar() // 탭 바 설정
        addShadowedCircleBehindButton() // 중앙 버튼 뒤에 그림자 추가
        setupCentralButton() // 중앙 버튼 설정
        customizeTabBarAppearance() // 탭 바 모양 커스터마이징
        addShadowToTabBar() // 탭 바 그림자 추가
        
    }
    
    // MARK: - 탭 바 설정
    func setTabBar() {
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: CameraViewController()) // 중앙 버튼
        let vc3 = UINavigationController(rootViewController: MyViewController())
        
        // 탭 바에 뷰 컨트롤러 추가
        self.viewControllers = [vc1, vc2, vc3]
        self.tabBar.tintColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1) // 선택된 탭 아이템 색상
        self.tabBar.unselectedItemTintColor = UIColor(red: 0.69, green: 0.78, blue: 1, alpha: 1) // 선택안된 탭 아이템 색상
        self.tabBar.backgroundColor =  UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1) // 탭 바 배경색
        self.tabBar.isTranslucent = false // 불투명
        
        // 탭 바 아이템 커스터마이징
        guard let tabBarItems = self.tabBar.items else { return }
        
        tabBarItems[0].image = UIImage(named: "home-05")
        tabBarItems[0].imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: -12, right: 0) // 아래로 16px 이동
        
        
        tabBarItems[1].image = nil // 중앙 버튼으로 대체
        
        tabBarItems[2].image = UIImage(named: "user-02")
        tabBarItems[2].imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: -12, right: 0) // 아래로 16px 이동
    }
    
    // MARK: - 중앙 버튼 설정
    private func setupCentralButton() {
        
        centralButton.setImage(UIImage(named: "Ellipse 1"), for: .normal)
        centralButton.layer.cornerRadius = 50 // 둥근 모서리 (크기와 동일)
        centralButton.adjustsImageWhenHighlighted = false // 클릭 시 어두워지지 않도록 설정
        
        // 버튼 크기와 위치
        let buttonSize: CGFloat = 90
        centralButton.frame = CGRect(
            x: (view.bounds.width / 2) - (buttonSize / 2), // 화면 중앙에 배치
            y: view.bounds.height - buttonSize - 15 - view.safeAreaInsets.bottom, // 탭 바 위로 튀어나오게 배치
            width: buttonSize,
            height: buttonSize
        )
        
        // 중앙 이미지 추가
        let centralIcon = UIImageView(image: UIImage(named: "plus")) // + 아이콘
        centralIcon.contentMode = .scaleAspectFit // 이미지 크기 조정
        centralIcon.frame = CGRect(
            x: (buttonSize / 2) - 15, // 버튼 내부 중앙에 위치
            y: (buttonSize / 2) - 15,
            width: 40,
            height: 40
        )
        centralButton.addSubview(centralIcon)
        
        // 버튼 클릭 시 액션 설정
        centralButton.addTarget(self, action: #selector(centralButtonTapped), for: .touchUpInside)
        
        // 버튼을 메인 뷰에 추가
        view.addSubview(centralButton)
    }
    
    // MARK: - 중앙 버튼 뒤 그림자 추가
    private func addShadowedCircleBehindButton() {
        // 원 크기 설정
        let circleSize: CGFloat = 99
        let circleRadius: CGFloat = circleSize / 2
        
        // 원을 감싸는 뷰 생성
        let circleWrapperView = UIView()
        circleWrapperView.frame = CGRect(
            x: (view.bounds.width / 2) - circleRadius, // 중앙에 배치
            y: view.bounds.height - circleSize - 20 - view.safeAreaInsets.bottom,
            width: circleSize,
            height: circleSize
        )
        
        // 직사각형 뷰 생성 (원 앞에 추가 - 그림자 가리기 위해서 만듦)
        let rectangleView = UIView()
        rectangleView.frame = CGRect(
            x: -20,
            y: 36,
            width: circleSize + 40, // 원과 동일한 너비
            height: circleSize // 원과 동일한 높이
        )
        rectangleView.backgroundColor = UIColor.white // 직사각형 배경색 설정
        
        // 직사각형을 원 앞에 추가
        circleWrapperView.addSubview(rectangleView)
        
        // 원을 그릴 UIView 생성
        let circleView = UIView()
        circleView.frame = CGRect(
            x: 0,
            y: 0,
            width: circleSize,
            height: circleSize
        )
        
        // 원 모양으로 설정
        circleView.layer.cornerRadius = circleRadius
        circleView.backgroundColor = UIColor.green // 원의 배경색
        
        // 원을 감싸는 뷰에 원 추가
        circleWrapperView.addSubview(circleView)
        
        // 원을 감싸는 뷰에 그림자 추가
        let shadowPath0 = UIBezierPath(roundedRect: circleWrapperView.bounds, cornerRadius: circleRadius)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 15
        layer0.shadowOffset = CGSize(width: 0, height: 0)
        
        // 그림자 레이어를 원을 감싸는 뷰에 추가 (가장 뒤에 추가)
        circleWrapperView.layer.insertSublayer(layer0, at: 0)
        
        // 원을 감싸는 뷰를 메인 뷰에 추가
        view.addSubview(circleWrapperView)
    }
    
    
    
    // MARK: - 중앙 버튼 동작
    @objc private func centralButtonTapped() {
        // 중앙 버튼 탭 시 두 번째 탭으로 이동
        //        self.selectedIndex = 1
        let modalVC = CameraViewController()
        modalVC.modalPresentationStyle = .fullScreen // 전체 화면 모달로 설정
        present(modalVC, animated: true, completion: nil)
    }
    
    // MARK: - 탭 바 레이아웃 조정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 탭 바의 위치 및 크기 조정
        let tabBarHeight: CGFloat = 88
        tabBar.frame = CGRect(
            x: 0,
            y: view.bounds.height - tabBarHeight,
            width: view.bounds.width,
            height: tabBarHeight
        )
        
        // 중앙 버튼 위치 재조정
        let buttonSize: CGFloat = 100
        centralButton.frame = CGRect(
            x: (view.bounds.width / 2) - (buttonSize / 2),
            y: view.bounds.height - buttonSize - view.safeAreaInsets.bottom + 15,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    // MARK: - 탭 바 모양 커스터마이징
    private func customizeTabBarAppearance() {
        
//        tabBar.barTintColor = .clear
        
        // 탭 바의 둥근 모양을 설정
        let shapeLayer = CAShapeLayer()
        let cornerRadius: CGFloat = 20
        let tabBarHeight: CGFloat = 88 // 높이
        
        // 탭 바 경로 설정 (왼쪽, 오른쪽 상단만 둥글게)
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: 0,
                y: 0, // 탭 바의 y 위치를 0으로 설정하여 탭 바 상단에 맞춤
                width: view.bounds.width,
                height: tabBarHeight
            ),
            byRoundingCorners: [.topLeft, .topRight], // 둥글게 할 모서리
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor // 탭 바 배경색
        
        // 기존 탭 바 위에 커스텀 레이어 추가
        tabBar.layer.insertSublayer(shapeLayer, at: 0)
        
        // 탭 바 높이 설정
        tabBar.frame.size.height = tabBarHeight
        tabBar.frame.origin.y = view.frame.height - tabBarHeight
        
        // 탭 바 아이템 간 간격 및 정렬 설정
        tabBar.itemPositioning = .centered // 아이템 중앙 정렬
        tabBar.itemSpacing = 50 // 아이템 간 간격
        
    }
    
    // MARK: - 탭 바 그림자 추가
    private func addShadowToTabBar() {
        // 그림자를 추가할 경로 설정 (탭 바의 bounds에 맞게 설정)
        let shadowPath = UIBezierPath(roundedRect: tabBar.bounds, cornerRadius: 20) // 둥근 모서리 적용
        
        // CALayer를 사용하여 그림자 설정
        let shadowLayer = CALayer()
        shadowLayer.shadowPath = shadowPath.cgPath
        shadowLayer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 15
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        // 그림자 레이어를 탭 바의 레이어에 추가
        tabBar.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    
}
