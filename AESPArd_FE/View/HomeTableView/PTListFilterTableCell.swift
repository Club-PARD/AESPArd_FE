import UIKit

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
        button.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.setImage(UIImage(named: "calendar"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        
        // 이미지와 글자 사이 간격 설정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        
        // 버튼 크기와 배경 설정
        button.backgroundColor = .white
//        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        //        button.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        return button
    }()
    
    let importButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("중요도순", for: .normal)
        button.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.setImage(UIImage(named: "bookmark_X"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        
        // 이미지와 글자 사이 간격 설정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        //        button.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
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
        //        button.addTarget(self, action: #selector(button3Tapped), for: .touchUpInside)
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            
            //            importButton.topAnchor.constraint(equalTo: listCountLabel.bottomAnchor, constant: 16),
            //            importButton.leadingAnchor.constraint(equalTo: recentButton.trailingAnchor, constant: 4),
            //            importButton.widthAnchor.constraint(equalToConstant: 73),
            //            importButton.heightAnchor.constraint(equalToConstant: 30),
            //
            //            deleteButton.topAnchor.constraint(equalTo: listCountLabel.bottomAnchor, constant: 23),
            //            //            deleteButton.leadingAnchor.constraint(equalTo: importButton.trailingAnchor, constant: 157),
            //            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            //            deleteButton.widthAnchor.constraint(equalToConstant: 64),
            //            deleteButton.heightAnchor.constraint(equalToConstant: 17),
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
}
