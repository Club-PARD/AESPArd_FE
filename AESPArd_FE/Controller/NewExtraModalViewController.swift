//
//  AddModalViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/23/24.
//

import UIKit

var TimeSetting1: String = ""
var TimeSetting2: String = ""

class NewExtraModalViewController: UIViewController, UITextFieldDelegate {
    
    // Post에 사용하기 위한 함수
    var presentationName: String?
    var idealMinTime: Double?
    var idealMaxTime: Double?
    var newPresentation : NewPresentation
    
    // 화면 녹화 뷰컨트롤러에 전달할 설정 값들
    var isShowingTimeSelected : Bool = true
    var isShowingMeSelected: Bool = true
    
    
    // 생성자
    init(userId: String){
        self.newPresentation = NewPresentation(userId: userId, presentationName: "", idealMinTime: 0.0, idealMaxTime: 0.0, eyeTrackingPercentage: 0,  videoKey: "", showTimeOnScreen: true, showMeOnScreen: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    var isKeyboardVisible = false
    var modalViewBottomConstraint: NSLayoutConstraint!
    private var timeSettingButtonConstraints: [NSLayoutConstraint] = []
    private var textFieldConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: - 1. 각종 변수 선언 및 정의
    
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.touchAreaInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        return button
    }()
    
    let timeSettingButtonView1 = FirstTimePickerInputView()
    let timeSettingButtonView2 = SecondTimePickerInputView()
    
    // 텍스트 필드
    let ptName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "발표이름을 입력해주세요"
        
        // Placeholder 스타일 적용
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Pretendard-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28),
            .foregroundColor: UIColor.lightGray
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: "발표이름을 입력해주세요",
            attributes: placeholderAttributes
        )
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .clear
        textField.textAlignment = .left
        textField.font = UIFont(name: "Pretendard-Bold", size: 28)
        textField.textColor = .black
        textField.returnKeyType = .done
        textField.adjustsFontSizeToFitWidth = true
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    // 발표시간 라벨
    let ptTime: UILabel = {
        let label = UILabel()
        label.text = "발표 시간"
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 0.18, green: 0.184, blue: 0.196, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 시간 설정 - 최소시간 라벨
    let minimumPTTime: UILabel = {
        let label = UILabel()
        label.text = "최소시간"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 시간 설정 - 최대시간 라벨
    let maximumPTTime: UILabel = {
        let label = UILabel()
        label.text = "최대시간"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ifseeCameratime: UILabel = {
        let label = UILabel()
        label.text = "촬영 시간 보이게 하기"
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 0.18, green: 0.184, blue: 0.196, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ifseeCameraScene: UILabel = {
        let label = UILabel()
        label.text = "촬영 화면 보이게 하기"
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 0.18, green: 0.184, blue: 0.196, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // 촬영 시간 보이게 하는 토글 스위치
    let seePTtimeSwitch: UISwitch = {
        let seePTtimeSwitch = UISwitch()
        seePTtimeSwitch.isOn = true
        seePTtimeSwitch.onTintColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1)
        seePTtimeSwitch.thumbTintColor = UIColor.white // 스위치 버튼 색상
        
        seePTtimeSwitch.addTarget(self, action: #selector(toggleHideTime), for: .valueChanged)
        seePTtimeSwitch.translatesAutoresizingMaskIntoConstraints = false
        return seePTtimeSwitch
    }()
    // 촬영 화면 보이게 하는 토글 스위치
    let seePtSceneSwitch: UISwitch = {
        let seePtSceneSwitch = UISwitch()
        seePtSceneSwitch.isOn = true
        seePtSceneSwitch.onTintColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1)
        seePtSceneSwitch.thumbTintColor = UIColor.white
        seePtSceneSwitch.addTarget(self, action: #selector(toggleHideScreen), for: .valueChanged)
        seePtSceneSwitch.translatesAutoresizingMaskIntoConstraints = false
        return seePtSceneSwitch
    }()
    
    // 에러 메세지
    let timeErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    
    
    
    // 흰색 모달창
    let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var initialPanLocation: CGPoint = .zero // 배경이 움직이는 기준이 되는 포인트
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        //setupPanGesture() // 드래그 제스처 활성화
        setupTapGestureForOverlay()

        // 키보드 표시 및 숨김 이벤트 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    // MARK: - 2. 제약조건 생성 및 애니메이션 설정
    func setUI() {
        view.addSubview(modalView)
        modalView.addSubview(addButton)
        modalView.addSubview(exitButton)
        modalView.addSubview(ptName)
        modalView.addSubview(ptTime)
        modalView.addSubview(minimumPTTime)
        modalView.addSubview(maximumPTTime)
        modalView.addSubview(timeSettingButtonView1)
        modalView.addSubview(timeSettingButtonView2)
        modalView.addSubview(ifseeCameratime)
        modalView.addSubview(ifseeCameraScene)
        modalView.addSubview(seePTtimeSwitch)
        modalView.addSubview(seePtSceneSwitch)
        modalView.addSubview(timeErrorLabel)
        
        
        // Delegate 연결
        ptName.delegate = self
        
        // 키보드 올렸다 내렸다 하는거 고정 푸는것
        modalViewBottomConstraint = modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        modalViewBottomConstraint.isActive = true
        
        let heightConstraint = modalView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        heightConstraint.priority = .defaultLow // 기본보다 낮은 우선순위 설정
        
        
        NSLayoutConstraint.activate([
            
            
            modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 100),
            modalView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
            heightConstraint,
            
            
            
            //  발표 촬영시작 버튼 제약조건
            addButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: modalView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 52),
            
            // X 버튼 제약조건
            exitButton.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 20),
            exitButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            
            // 발표 이름 적는 란 제약조건
            ptName.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 16),
            ptName.leadingAnchor.constraint(equalTo: exitButton.leadingAnchor, constant: -10),
            ptName.widthAnchor.constraint(equalToConstant: 350),
            ptName.heightAnchor.constraint(equalToConstant: 39),
            
            // 발표 시간 제약조건
            ptTime.topAnchor.constraint(equalTo: ptName.bottomAnchor, constant: 15),
            ptTime.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 16),
            ptTime.widthAnchor.constraint(equalToConstant: 100),
            ptTime.heightAnchor.constraint(equalToConstant: 19),
            
            minimumPTTime.topAnchor.constraint(equalTo: ptTime.bottomAnchor, constant: 12),
            minimumPTTime.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 16),
            
            timeSettingButtonView1.topAnchor.constraint(equalTo: minimumPTTime.bottomAnchor, constant: 8),
            timeSettingButtonView1.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 16),
            timeSettingButtonView1.widthAnchor.constraint(equalToConstant: 108),
            timeSettingButtonView1.heightAnchor.constraint(equalToConstant: 35),
            
            maximumPTTime.topAnchor.constraint(equalTo: minimumPTTime.topAnchor),
            maximumPTTime.leadingAnchor.constraint(equalTo: minimumPTTime.trailingAnchor, constant: 124),
            
            timeSettingButtonView2.topAnchor.constraint(equalTo: maximumPTTime.bottomAnchor, constant: 8),
            timeSettingButtonView2.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -98),
            timeSettingButtonView2.widthAnchor.constraint(equalToConstant: 108),
            timeSettingButtonView2.heightAnchor.constraint(equalToConstant: 35),
            
            timeErrorLabel.topAnchor.constraint(equalTo: timeSettingButtonView1.bottomAnchor, constant: 9.5),
            timeErrorLabel.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 16),
            timeErrorLabel.widthAnchor.constraint(equalToConstant: 350),
            timeErrorLabel.heightAnchor.constraint(equalToConstant: 14),
            
            ifseeCameratime.topAnchor.constraint(equalTo: timeErrorLabel.bottomAnchor, constant: 9),
            ifseeCameratime.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 16),
            ifseeCameratime.widthAnchor.constraint(equalToConstant: 180),
            ifseeCameratime.heightAnchor.constraint(equalToConstant: 19),
            
            seePTtimeSwitch.topAnchor.constraint(equalTo: ifseeCameratime.topAnchor, constant: -5), // 이거 마이너스 할수록 내려가는거이
            seePTtimeSwitch.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -32),
            seePTtimeSwitch.widthAnchor.constraint(equalToConstant: 36),
            seePTtimeSwitch.heightAnchor.constraint(equalToConstant: 20),
            
            ifseeCameraScene.topAnchor.constraint(equalTo: ifseeCameratime.bottomAnchor, constant: 33),
            ifseeCameraScene.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 16),
            ifseeCameraScene.widthAnchor.constraint(equalToConstant: 180),
            ifseeCameraScene.heightAnchor.constraint(equalToConstant: 19),
            
            seePtSceneSwitch.topAnchor.constraint(equalTo: ifseeCameraScene.topAnchor, constant: -5), // 이것도 마이너스 할수록 내려감
            seePtSceneSwitch.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -32),
            seePtSceneSwitch.widthAnchor.constraint(equalToConstant: 36),
            seePtSceneSwitch.heightAnchor.constraint(equalToConstant: 20)
            
            
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
    
    @objc func exit() {
        UIView.animate(withDuration: 0.3, animations: {
            self.modalView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc func moveTocameraViewController() {
        if firstTotalTime > secondTotalTime {
            timeErrorLabel.text = "최소시간은 최대시간을 넘을 수 없어요"
            timeErrorLabel.isHidden = false // 오류 메시지 보이게 함
            return
        }
        else if secondTotalTime >= 1200 || firstTotalTime >= 1200 {
            timeErrorLabel.text = "최대 설정시간은 20분이에요"
            timeErrorLabel.isHidden = false
            return
        }

        else {
            // 발표제목 추가
            newPresentation.presentationName = ptName.text!
            // 최소시간 & 최대시간 값 가져옴
            let selectedIdealMinTime = timeSettingButtonView1.selectedTime // From FirstTimePickerInputView
            let selectedIdealMaxTime = timeSettingButtonView2.selectedTime // From SecondTimePickerInputView
            
            newPresentation.idealMinTime = selectedIdealMinTime
            newPresentation.idealMaxTime = selectedIdealMaxTime
            
            let cameraVC = CameraViewController(newPresentation: newPresentation, isShowingTimeSelected: isShowingTimeSelected, isShowingMeSelected: isShowingMeSelected)
            cameraVC.modalPresentationStyle = .custom
            present(cameraVC, animated: true, completion: nil)
            guard let enteredText = ptName.text, !enteredText.isEmpty else {
                    print("텍스트 필드가 비어 있습니다.")
                    return
            }
        }

        
    }
    
    // 키보드 완료 누르면 키보드 닫는거
    @objc func keyboardWillShow(_ notification: Notification) {
        if isKeyboardVisible { return }
        
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.modalViewBottomConstraint.constant = -keyboardHeight // 키보드 높이에 따라 이동
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        isKeyboardVisible = true
    }
    
    // 텍스트필드에 입력 안되면 버튼 비활
    @objc func textFieldDidChange(_ textField: UITextField) {
        let isTextEntered = !(textField.text?.isEmpty ?? true)
        addButton.isEnabled = isTextEntered
        addButton.backgroundColor = isTextEntered ? UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1) : UIColor(red: 0.82, green: 0.83, blue: 0.84, alpha: 1)
       }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if !isKeyboardVisible { return }
        
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.modalViewBottomConstraint.constant = 0 // 원래 위치 복귀
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        isKeyboardVisible = false
    }
    
    // 촬영 시간 보이게 하는 토글에 따라 불린 값 변경
    @objc func toggleHideTime(){
        isShowingTimeSelected = !isShowingTimeSelected
    }
    
    @objc func toggleHideScreen(){
        isShowingMeSelected = !isShowingMeSelected
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 내리기
        return true
    }
    
    private func switchToTextFieldMode() {
        
        // 기존 버튼 제약 조건 해제
        NSLayoutConstraint.deactivate(timeSettingButtonConstraints)
    }
    
    private func switchToButtonMode() {
        
        // 기존 텍스트 필드 제약 조건 해제
        NSLayoutConstraint.deactivate(textFieldConstraints)
    }
    
    func setupTapGestureForOverlay() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exit))
        view.addGestureRecognizer(tapGesture)
    }

}

