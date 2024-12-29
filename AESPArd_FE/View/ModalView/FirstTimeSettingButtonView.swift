//
//  AddModalViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/23/24.
//

import UIKit

var firstminuteValue: Int = 5
var firstsecondValue: Int = 0

class FirstTimePickerInputView: UIView, UITextFieldDelegate {

    private var isEditing = false // 상태를 나타내는 변수
    private var timeSettingButtonConstraints: [NSLayoutConstraint] = []
    private var textFieldConstraints: [NSLayoutConstraint] = []


    // 시간 설정 버튼
    let timeSetButton: UIButton = {
        let button = UIButton()
        let blueText = NSAttributedString(
            string: " 05:00",
            attributes: [
                .foregroundColor: UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1),
                .font: UIFont(name: "Pretendard-Medium", size: 16)!
            ]
        )
        
        let grayText = NSAttributedString(
            string: " 부터",
            attributes: [
                .foregroundColor: UIColor(red: 0.62, green: 0.62, blue: 0.65, alpha: 1),
                .font: UIFont(name: "Pretendard-Medium", size: 16)!
            ]
        )
        
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

    // 시간 입력 필드 1 (분)
    let timeTextField1: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont(name: "Pretendard-Medium", size: 16)
        textField.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        textField.layer.cornerRadius = 4
        textField.keyboardType = .numberPad
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "05"
        return textField
    }()
    
    let minuteLabel: UILabel = {
        let label = UILabel()
        label.text = "분"
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 시간 입력 필드 2 (초)
    let timeTextField2: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont(name: "Pretendard-Medium", size: 16)
        textField.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        textField.layer.cornerRadius = 4
        textField.keyboardType = .numberPad
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "00"
        return textField
    }()
    
    let secLabel: UILabel = {
        let label = UILabel()
        label.text = "초 부터"
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupTextFieldDelegates()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        setupTextFieldDelegates()
    }
    
    // 텍스트 필드 델리게이트 설정
    private func setupTextFieldDelegates() {
        timeTextField1.delegate = self
        timeTextField2.delegate = self
        configureDoneButton(for: timeTextField1)
        configureDoneButton(for: timeTextField2)
    }

    // .done 버튼 추가를 위한 메서드
    private func configureDoneButton(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(handleDoneTapped)
        )
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
    }

    // .done 버튼 눌렀을 때 동작
    @objc private func handleDoneTapped() {
        endEditing(true) // 키보드 숨기기
        isEditing = false // 편집 종료 상태로 전환
        switchToButtonMode() // 버튼 모드로 전환
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
        NSLayoutConstraint.deactivate(timeSettingButtonConstraints)
        
        timeSetButton.removeFromSuperview()
        
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
            timeTextField1.widthAnchor.constraint(equalToConstant: 25),
            timeTextField1.heightAnchor.constraint(equalToConstant: 33),
            timeTextField2.widthAnchor.constraint(equalToConstant: 25),
            timeTextField2.heightAnchor.constraint(equalToConstant: 33)
        ]
        
        NSLayoutConstraint.activate(textFieldConstraints)
    }

    private func switchToButtonMode() {
        NSLayoutConstraint.deactivate(textFieldConstraints)
        
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(timeSetButton)
        
        timeSettingButtonConstraints = [
            timeSetButton.topAnchor.constraint(equalTo: self.topAnchor),
            timeSetButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timeSetButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timeSetButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(timeSettingButtonConstraints)
    }
    
    // 텍스트 필드 입력 처리 및 버튼 텍스트 업데이트
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 입력 값이 숫자가 아니거나 0~59 범위를 초과하면 입력 막음
        if let intValue = Int(newText), intValue >= 0 && intValue <= 59 {
            if textField == timeTextField1 {
                firstminuteValue = intValue
            } else if textField == timeTextField2 {
                firstsecondValue = intValue
            }
            
            updateTimeSetButtonText()
            return true
        }
        return false
    }
    
    private func updateTimeSetButtonText() {
        let blueText = NSAttributedString(
            string: " \(String(format: "%02d", firstminuteValue)):\(String(format: "%02d", firstsecondValue))",
            attributes: [
                .foregroundColor: UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1),
                .font: UIFont(name: "Pretendard-Medium", size: 16)!
            ]
        )
        
        let grayText = NSAttributedString(
            string: " 부터",
            attributes: [
                .foregroundColor: UIColor(red: 0.62, green: 0.62, blue: 0.65, alpha: 1),
                .font: UIFont(name: "Pretendard-Medium", size: 16)!
            ]
        )
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(blueText)
        attributedText.append(grayText)
        timeSetButton.setAttributedTitle(attributedText, for: .normal)
    }
    
   // 서버에 데이터 보낼때는 초단위로 보내야해서 변환시켜줌
    var selectedTime: Double {
        return Double(firstminuteValue * 60) + Double(firstsecondValue)
    }
}
