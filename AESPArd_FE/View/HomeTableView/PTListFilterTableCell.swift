import UIKit

extension Notification.Name {
    static let deleteCheckNotification = Notification.Name("deleteCheckNotification")
}

class PTListFilterTableCell: UITableViewCell {
    
    let listCountLabel: UILabel = {
        let label = UILabel()
        label.font =  UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "searchIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let recentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("최신순", for: .normal)
        button.setTitleColor(UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.setImage(UIImage(named: "calendar-click"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        
        // 이미지와 글자 사이 간격 설정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        
        // 버튼 크기와 배경 설정
        button.backgroundColor = .white
        button.layer.cornerRadius = 15.0
        
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 15
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.addTarget(self, action: #selector(recentButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let importButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("중요도순", for: .normal)
        button.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.setImage(UIImage(named: "importanceStar"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        
        // 이미지와 글자 사이 간격 설정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        
        // 버튼 크기와 배경 설정
        button.backgroundColor = .white
        button.layer.cornerRadius = 15.0
        
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 15
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        button.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("삭제하기", for: .normal)
        button.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.setImage(UIImage(named: "trash"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "PTListFilterTableCell")
        setUI()
    }
    
    func setUI() {
        contentView.addSubview(listCountLabel)
        contentView.addSubview(searchButton)
        
        contentView.addSubview(recentButton)
        contentView.addSubview(importButton)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            listCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            listCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            searchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            searchButton.widthAnchor.constraint(equalToConstant: 20),
            searchButton.heightAnchor.constraint(equalToConstant: 20),
            
            recentButton.topAnchor.constraint(equalTo: listCountLabel.bottomAnchor, constant: 16),
            recentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            recentButton.widthAnchor.constraint(equalToConstant: 63),
            recentButton.heightAnchor.constraint(equalToConstant: 30),
            
            importButton.topAnchor.constraint(equalTo: listCountLabel.bottomAnchor, constant: 16),
            importButton.leadingAnchor.constraint(equalTo: recentButton.trailingAnchor, constant: 4),
            importButton.widthAnchor.constraint(equalToConstant: 73),
            importButton.heightAnchor.constraint(equalToConstant: 30),
            
            deleteButton.topAnchor.constraint(equalTo: listCountLabel.bottomAnchor, constant: 23),
            //            deleteButton.leadingAnchor.constraint(equalTo: importButton.trailingAnchor, constant: 157),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            deleteButton.widthAnchor.constraint(equalToConstant: 65),
            deleteButton.heightAnchor.constraint(equalToConstant: 17),
            //
            
        ])
    }
    
    // 라벨 발표 갯수 텍스트 설정 메서드
    func configure(with presentationCount: Int) {
        listCountLabel.text = "\(presentationCount)개의 발표 연습 목록이 있어요"
    }
    
    //검색 아이콘 클릭 메서드
    @objc func searchButtonTapped() {
        print("Search button tapped!")
    }
    
    //최신순 버튼 클릭 메서드
    @objc func recentButtonTapped() {
        // 글자 색을 파란색으로 변경
        recentButton.setTitleColor(UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1), for: .normal)
        
        // 이미지를 변경
        recentButton.setImage(UIImage(named: "calendar-click"), for: .normal)
        
        // 다른 버튼들이 클릭되었을 때 원래 상태로 돌아감
        resetOtherButtons(except: recentButton)
    }
    
    //중요도순 버튼 클릭 메서드
    @objc func importButtonTapped() {
        importButton.setTitleColor(UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1), for: .normal)
        importButton.setImage(UIImage(named: "importanceStar-click"), for: .normal)
        resetOtherButtons(except: importButton)
    }
    
    //삭제 버튼 클릭 메서드
    @objc func deleteButtonTapped() {
        if deleteButton.currentImage == UIImage(named: "trash-click") {
            NotificationCenter.default.post(name:.deleteCheckNotification, object: nil)
            
            deleteButton.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
            deleteButton.setImage(UIImage(named: "trash"), for: .normal)
        } else {
            
            NotificationCenter.default.post(name:.deleteCheckNotification, object: nil)
//            
            deleteButton.setTitleColor(UIColor(red: 1, green: 0, blue: 0, alpha: 1), for: .normal)
            deleteButton.setImage(UIImage(named: "trash-click"), for: .normal)
        }
    }

    
    // 다른 버튼들을 초기 상태로 복원하는 메서드
    func resetOtherButtons(except button: UIButton) {
        if button != recentButton {
            recentButton.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
            recentButton.setImage(UIImage(named: "calendar"), for: .normal)
        }
        if button != importButton {
            importButton.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
            importButton.setImage(UIImage(named: "importanceStar"), for: .normal)
        }
    }}
