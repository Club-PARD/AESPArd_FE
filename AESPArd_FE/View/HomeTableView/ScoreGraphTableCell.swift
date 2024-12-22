import UIKit

class ScoreGraphTableCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "ScoreGraphTableCell")
        setUI()
    }
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Bold", size: 28)
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        label.numberOfLines = 0 // 여러 줄로 텍스트 표시
        label.lineBreakMode = .byWordWrapping
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.17
        paragraphStyle.alignment = .left
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white // 배경색 설정
        view.layer.cornerRadius = 20
        view.clipsToBounds = false
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        return view
    }()
    
    func setUI() {
        
        contentView.addSubview(containerView)
        contentView.addSubview(greetingLabel)
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            greetingLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -16),
            
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 224),
        ])
    }
    
    // 라벨 유저 이름 텍스트 설정 메서드
    func configure(with userName: String) {
        greetingLabel.text = "\(userName)님, 오늘도\n프리와 함께 발표준비해요!"
    }
}
