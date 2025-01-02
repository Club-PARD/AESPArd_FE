
import UIKit

//이름 수정
extension Notification.Name {
    static let editPracticeNameNotification = Notification.Name("editPracticeNameNotification")
}

//연습 파일 삭제
extension Notification.Name {
    static let deletePracticeNotification = Notification.Name("deletePracticeNotification")
}

class EditPracticeView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        setUI()
    }
    
    let nameEditButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("이름 수정하기", for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        button.layer.cornerRadius = 13
        button.addTarget(self, action: #selector(editPracticeNameButtonTapped), for: .touchUpInside)
        
        // 버튼 아래 보더 추가
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        button.addSubview(border)
        
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: 1), // 보더 높이
            border.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: button.bottomAnchor) // 버튼 하단에 붙임
        ])
        
        return button
    }()
    
    let practiceDeleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("연습 파일 삭제하기", for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        button.layer.cornerRadius = 13
        button.addTarget(self, action: #selector(editDeletePracticeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    func setUI(){
        
        self.addSubview(nameEditButton)
        self.addSubview(practiceDeleteButton)
        
        NSLayoutConstraint.activate([
            nameEditButton.topAnchor.constraint(equalTo: self.topAnchor),
            nameEditButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            nameEditButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            nameEditButton.heightAnchor.constraint(equalToConstant: 48),
            
            practiceDeleteButton.topAnchor.constraint(equalTo: nameEditButton.bottomAnchor),
            practiceDeleteButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            practiceDeleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            practiceDeleteButton.heightAnchor.constraint(equalToConstant: 48),
            
        ])
    }
    
    //이름 수정하기 버튼
    @objc func editPracticeNameButtonTapped() {
        print("이름 수정 됨 ㅋ")
        self.isHidden = true
        NotificationCenter.default.post(name:.editPracticeNameNotification, object: nil)
    }
    
    //발표 연습 파일 삭제하기 버튼
    @objc func editDeletePracticeButtonTapped() {
        print("연습 파일 삭제")
        self.isHidden = true
        NotificationCenter.default.post(name:.deletePracticeNotification, object: nil)
    }
    
    
}
