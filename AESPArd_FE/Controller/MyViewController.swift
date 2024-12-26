//
//  MyViewController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/21/24.
//

import UIKit

class MyViewController : UIViewController {
    
    var userName: String? = "김규희"
    var userAdress: String? = "gyuheekim@gmail.com"
    var message: String? = "프로젝트 매니저 이지환 / sonforhj03@gmail.com"


    
    // 페이지 상단 위 로고
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LOGO")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 페이지 마이페이지 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        label.font = UIFont(name: "Pretendard-Bold", size: 28)
        label.textAlignment = .center
        label.text = "마이페이지"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 세부정보 설명되어있는 버튼 근데 안눌림 기능안넣음
    let nameButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 15
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.titleLabel?.textAlignment = .left
        button.layer.cornerRadius = 20
        button.titleLabel?.numberOfLines = 2 // 여러 줄로 표시
        button.contentEdgeInsets = UIEdgeInsets(top: 17, left: 16, bottom: 18, right: 190)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let centerButton: ExpandableButton = {
        let button = ExpandableButton()
        button.setTitle(" 고객센터", for: .normal)
        button.setImage(UIImage(named: "phone"), for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1), for: .normal)
        button.touchAreaInsets = UIEdgeInsets(top: 30, left: 100, bottom: 30, right: 100) // 터치 영역 확장
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let logoutButton: ExpandableButton = {
        let button = ExpandableButton()
        button.setTitle(" 로그아웃", for: .normal)
        button.setImage(UIImage(named: "logout"), for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.touchAreaInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 터치 영역 확장
        button.backgroundColor = .clear
        button
//        button.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let appResetButton: ExpandableButton = {
        let button = ExpandableButton()
        button.setTitle(" 앱 초기화", for: .normal)
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.touchAreaInsets = UIEdgeInsets(top: 30, left: 100, bottom: 30, right: 100) // 터치 영역 확장
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        setUI()
        setupNameButtonTitle()

        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        appResetButton.addTarget(self, action: #selector(appResetButtonTapped), for: .touchUpInside)
    }
    
    func setUI() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(nameButton)
        view.addSubview(centerButton)
        view.addSubview(logoutButton)
        view.addSubview(appResetButton)
        
        NSLayoutConstraint.activate([
            
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 19),
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor, constant: -8),
            titleLabel.widthAnchor.constraint(equalToConstant: 150),
            titleLabel.heightAnchor.constraint(equalToConstant: 39),
            
            nameButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            nameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameButton.widthAnchor.constraint(equalToConstant: 361),
            nameButton.heightAnchor.constraint(equalToConstant: 80),
            
            centerButton.topAnchor.constraint(equalTo: nameButton.bottomAnchor, constant: 44),
            centerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            centerButton.widthAnchor.constraint(equalToConstant: 86),
            centerButton.heightAnchor.constraint(equalToConstant: 20),
            
            logoutButton.topAnchor.constraint(equalTo: centerButton.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.widthAnchor.constraint(equalToConstant: 86),
            logoutButton.heightAnchor.constraint(equalToConstant: 20),
            
            appResetButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 40),
            appResetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            appResetButton.widthAnchor.constraint(equalToConstant: 86),
            appResetButton.heightAnchor.constraint(equalToConstant: 20)
            

        ])
    }
    
    func setupNameButtonTitle() {
        // 큰 글자와 작은 글자를 NSAttributedString으로 설정
        let bigText = "\(userName ?? "사용자")님 \n" // 이름이 닐값 (nil) 값이면 "사용자님" 이케 뜸 스트링 값 있으면 그걸로 뜨고
        let smallText = "\(userAdress ?? "이메일 없음")" // 이것도 이름처럼 nil값이면 "이메일 없음" 이케 뜸 스트링 값 있으면 그걸로 뜨고

        let attributedString = NSMutableAttributedString(
            string: bigText,
            attributes: [
                .font: UIFont(name: "Pretendard-SemiBold", size: 20),
                .foregroundColor: UIColor.black
            ]
        )
        attributedString.append(NSAttributedString(
            string: smallText,
            attributes: [
                .font: UIFont(name: "Pretendard-Medium", size: 14),
                .foregroundColor: UIColor.gray
            ]
        ))
        
        // 버튼의 타이틀을 Attributed String으로 설정
        nameButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    // 고객센터 버튼 누르면 나타나는 토스트메세지 기능 구현하기
    func showToast(_ message : String, withDuration: Double, delay: Double) {
        let toastWidth: CGFloat = 350
        let toastLabel = UILabel(frame: CGRect(
            x: self.view.frame.size.width/2 - 175,
            y: self.view.frame.size.height-100, width: toastWidth, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = "\(message)"
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 4
        toastLabel.clipsToBounds  =  true
            
        self.view.addSubview(toastLabel)
            
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func logoutFunction() {
        
    }
    
    @objc func centerButtonTapped() {
        showToast("프로젝트 매니저 이지환 / sonforhj03@gmail.com", withDuration: 2, delay: 1.5)
    }
    
//    @objc func logoutButtonTapped() {
//        
//    }
    // 서비스 초기화 버튼 눌렀을 때 나타나는 알림화면
    @objc func appResetButtonTapped() {
        let alert = UIAlertController(
            title: "서비스 초기화",
            message: "서비스를 초기화 하시겠어요? \n이 작업은 되돌릴 수 없어요.",
            preferredStyle: .alert
        )
        
        // 삭제하기 버튼
        let resetAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
            print("서비스 초기화 작업 수행") // 여기에서 초기화 로직 추가
            // 예를 들어, 데이터를 삭제하거나 초기 상태로 되돌리는 작업
        }
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        // UIAlertController를 화면에 표시
        self.present(alert, animated: true, completion: nil)
    }
    
}
