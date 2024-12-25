//
//  AddModalViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/23/24.
//

import UIKit

class FirstTimePickerInputView: UIView {
    
    private var isEditing = false // 상태를 나타내는 변수
    var TimeSettingMinute1: String = ""
    var TimeSettingSecond1: String = ""
    private var timeSettingButtonConstraints: [NSLayoutConstraint] = []
    private var textFieldConstraints: [NSLayoutConstraint] = []

    // 시간 설정 버튼
    let timeSetButton: UIButton = {
        let button = UIButton()
        let blueText = NSAttributedString(
            string: " 05:30",
            attributes: [
                .foregroundColor: UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1), // 파란색
                .font: UIFont(name: "Pretendard-Medium", size: 16)!
            ]
        )
        
        let grayText = NSAttributedString(
            string: " 부터",
            attributes: [
                .foregroundColor: UIColor(red: 0.62, green: 0.62, blue: 0.65, alpha: 1), // 회색
                .font: UIFont(name: "Pretendard-Medium", size: 16)!
            ]
        )
        
        // 문자열 결합
        let attributedText = NSMutableAttributedString()
        attributedText.append(blueText)
        attributedText.append(grayText)
        button.setAttributedTitle(attributedText, for: .normal)
        button.setImage(UIImage(named: "TimeSet"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 15
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 시간 입력 필드 1
    let timeTextField1: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont(name: "Pretendard-Medium", size: 16)
        textField.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        textField.layer.cornerRadius = 4
        textField.keyboardType = .numberPad
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let minuteLabel: UILabel = {
        let label = UILabel()
        label.text = "분"
        label.font = UIFont(name: "Pretendard-Medium", size: 12) // 16pt -> 12pt
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 시간 입력 필드 2
    let timeTextField2: UITextField = {
        let textField = UITextField()
        textField.placeholder = "00"
        textField.textAlignment = .center
        textField.font = UIFont(name: "Pretendard-Medium", size: 16) 
        textField.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        textField.layer.cornerRadius = 4
        textField.keyboardType = .numberPad
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let secLabel: UILabel = {
        let label = UILabel()
        label.text = "초 부터"
        label.font = UIFont(name: "Pretendard-Medium", size: 12) // 16pt -> 12pt
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    // 레이아웃 설정 메서드
    private func setupLayout() {
        addSubview(timeSetButton)
        
        NSLayoutConstraint.activate([
        timeSetButton.topAnchor.constraint(equalTo: self.topAnchor),
        timeSetButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        timeSetButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        timeSetButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        timeSetButton.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleButtonTapped() {
        isEditing.toggle()
        updateView()
    }
    
    private func updateView() {
        if isEditing {
                switchToTextFieldMode()
            } else {
                switchToButtonMode()
            }
    }
    
    private func switchToTextFieldMode() {
        // 기존 버튼 제약 조건 해제
        NSLayoutConstraint.deactivate(timeSettingButtonConstraints)
        
        // 버튼 -> 텍스트필드
        timeSetButton.removeFromSuperview()
        
        // 텍스트 필드 추가 및 제약 조건 활성화
        let stackView = UIStackView(arrangedSubviews: [timeTextField1, minuteLabel, timeTextField2, secLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        textFieldConstraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            timeTextField1.widthAnchor.constraint(equalToConstant: 25), // 50 -> 25
            timeTextField1.heightAnchor.constraint(equalToConstant: 33),// 40 - > 33
            timeTextField2.widthAnchor.constraint(equalToConstant: 25), // 50 -> 25
            timeTextField2.heightAnchor.constraint(equalToConstant: 33),// 40 - > 33
        ]
        
        NSLayoutConstraint.activate(textFieldConstraints)
    }

    private func switchToButtonMode() {
        // 기존 텍스트 필드 제약 조건 해제
        NSLayoutConstraint.deactivate(textFieldConstraints)
        
        // 텍스트필드 -> 버튼
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(timeSetButton)
        
        // 버튼 추가 및 제약 조건 활성화
        addSubview(timeSetButton)
        timeSettingButtonConstraints = [
        timeSetButton.topAnchor.constraint(equalTo: self.topAnchor),
        timeSetButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        timeSetButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        timeSetButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(timeSettingButtonConstraints)
    }

}
