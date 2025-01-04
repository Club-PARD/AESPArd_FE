import UIKit

extension Notification.Name {
    static let selectedDeleteNotification = Notification.Name("selectedDeleteNotification")
}

extension Notification.Name {
    static let updateFavoriteNotification = Notification.Name("updateFavoriteNotification")
}

class PresentationListTableCell: UITableViewCell {
    
    // 클백 연결을 위한 NesworkManager 연결
    private let networkManager = NetworkManager.shared
    
    var ptId : String = ""
    var ptToggle : Bool = false
    var mode : String = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "PresentationListTableCell")
        setUI()
        
    }
    
    let ptName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 0.18, green: 0.184, blue: 0.196, alpha: 1)
        return label
    }()
    
    // ptCount를 감싸는 컨테이너 뷰 추가
    let ptCountContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.isHidden = true
        view.layer.borderColor = UIColor(red: 0.541, green: 0.678, blue: 1, alpha: 1).cgColor
        return view
    }()
    
    let ptCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = UIColor(red: 0.541, green: 0.678, blue: 1, alpha: 1)
        return label
    }()
    
    let ptDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        return label
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "bookmark_X"), for: .normal)
        button.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        //        button.backgroundColor = .green
        
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        
        return button
    }()
    
    let deleteCheckButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "check_X"), for: .normal)
        button.addTarget(self, action: #selector(deleteCheckButtonTapped), for: .touchUpInside)
        button.isHidden = true
        //        button.backgroundColor = .green
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        //        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = false
        
        
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        return view
    }()
    
    let smallContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    let circularProgressBar: CircularProgressBar = {
        let progressBar = CircularProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    func setUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(smallContainerView)
        
        containerView.addSubview(deleteCheckButton)
        containerView.addSubview(bookmarkButton)
        containerView.addSubview(ptName)
        
        containerView.addSubview(ptCountContainer)
        ptCountContainer.addSubview(ptCount)
        
        containerView.addSubview(ptDate)
        
        containerView.addSubview(circularProgressBar)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            smallContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            smallContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            smallContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            smallContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            bookmarkButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bookmarkButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 48),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 80),
            
            deleteCheckButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            deleteCheckButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteCheckButton.widthAnchor.constraint(equalToConstant: 48),
            deleteCheckButton.heightAnchor.constraint(equalToConstant: 80),
            
            ptName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 21.5),
            ptName.leadingAnchor.constraint(equalTo: bookmarkButton.trailingAnchor),
            
            ptCountContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            ptCountContainer.leadingAnchor.constraint(equalTo: ptName.trailingAnchor, constant: 4),
            
            ptCount.topAnchor.constraint(equalTo: ptCountContainer.topAnchor, constant: 2),
            ptCount.bottomAnchor.constraint(equalTo: ptCountContainer.bottomAnchor, constant: -2),
            ptCount.leadingAnchor.constraint(equalTo: ptCountContainer.leadingAnchor, constant: 6),
            ptCount.trailingAnchor.constraint(equalTo: ptCountContainer.trailingAnchor, constant: -6),
            
            ptDate.topAnchor.constraint(equalTo: ptName.bottomAnchor, constant: 2),
            ptDate.leadingAnchor.constraint(equalTo: bookmarkButton.trailingAnchor),
            
            circularProgressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            circularProgressBar.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            circularProgressBar.widthAnchor.constraint(equalToConstant: 80),
            circularProgressBar.heightAnchor.constraint(equalToConstant: 80)
            
        ])
    }
    
    // 북마크 버튼 클릭 시 호출되는 메서드
    @objc func bookmarkButtonTapped() {
        if bookmarkButton.currentImage == UIImage(named: "bookmark_X") {
            bookmarkButton.setImage(UIImage(named: "bookmark_O"), for: .normal)
        } else {
            bookmarkButton.setImage(UIImage(named: "bookmark_X"), for: .normal)
        }
        
        NotificationCenter.default.post(name: .updateFavoriteNotification, object: nil, userInfo: ["ptId": ptId])
        
    }
    
    //삭제하기 -> 리스트 체크 버튼
    @objc func deleteCheckButtonTapped(){
        if deleteCheckButton.currentImage == UIImage(named: "check_X") {
            deleteCheckButton.setImage(UIImage(named: "check_O"), for: .normal)
        } else {
            deleteCheckButton.setImage(UIImage(named: "check_X"), for: .normal)
        }
        
        if let presentationName = ptName.text {
            NotificationCenter.default.post(name: .selectedDeleteNotification, object: nil, userInfo: ["cellName": ptId])
        }
    }
    
    // 발표 정보 설정 메서드
    func configure(presentationName: String, ptDetailCount: Int, presentationDate: String, ptDetailTotalScore: Int, barVaue: Double, toggleFavorite:Bool, presentationId: String, filterMode: String) {
        
        ptName.text = presentationName
//        ptCount.text = "\(ptDetailCount+1)개"
        ptCount.text = ""
        ptDate.text = "\(presentationDate)"
        circularProgressBar.value = barVaue
        ptId = presentationId
        ptToggle = toggleFavorite
        mode = filterMode
        
        if(ptToggle){
            bookmarkButton.setImage(UIImage(named: "bookmark_O"), for: .normal)
        }
        else{
            bookmarkButton.setImage(UIImage(named: "bookmark_X"), for: .normal)
        }
    }
}
