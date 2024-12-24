//
//  AddModalViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/23/24.
//

import UIKit

class NewExtraModalViewController: UIView {
    
    // 클백할 때 이거 변수 다시 설정하기
    var presentationName: String = "발표이름"
    var presentationDate: Int = 1
    var presentationDetailCount: Int = 4
    
    
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
    
    // 흰색 모달창
    let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 발표 이름 입력하는 칸
    let ptName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "발표 이름을 입력해 주세요."
        textField.font = UIFont(name: "Pretendard-Medium", size: 28)
        textField.keyboardType = .default
        textField.textAlignment = .left
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let ptTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "발표 시간"
        label.font = UIFont(name: "Pretendard-Medium", size: 28)
        label.textColor = .lightGray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    // MARK: - 2. 제약조건 생성 및 애니메이션 설정
    func setUI() {
        view.addSubview(modalView)
        modalView.addSubview(addButton)
        modalView.addSubview(exitButton)
        
        

        NSLayoutConstraint.activate([
            
            addButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: modalView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 52),

            exitButton.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 20),
            exitButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            
                ])

    }
    
    @objc func exit() {
        UIView.animate(withDuration: 0.3, animations: {
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

}


