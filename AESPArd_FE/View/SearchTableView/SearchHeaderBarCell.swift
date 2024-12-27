
import UIKit

class SearchHeaderBarCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "SearchHeaderBarCell")
        setUI()
        
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
        // 보더를 제거하려면 아래 코드 추가
            view.layer.borderWidth = 0
            view.layer.borderColor = UIColor.clear.cgColor
        
        return view
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "연습 목록을 검색하세요"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // 서치바 배경색 설정
        let searchBarColor = UIColor.white
        searchBar.barTintColor = searchBarColor
        searchBar.layer.cornerRadius = 20 // 둥근 모서리 설정
        searchBar.clipsToBounds = true
        
        // 서치바의 테두리 제거 (선 안 보이게)
        searchBar.layer.borderWidth = 0
        searchBar.layer.borderColor = UIColor.clear.cgColor
        
        //        searchBar.layer.masksToBounds = false
        searchBar.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        searchBar.layer.shadowOpacity = 1
        searchBar.layer.shadowRadius = 15
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // 서치바의 텍스트 필드 커스터마이징
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear // 텍스트 필드 배경색을 서치바와 동일하게 설정
            textField.textColor = .black
            textField.font = UIFont(name: "Pretendard-Medium", size: 16)
            
            textField.layer.borderWidth = 0 // 텍스트 필드 테두리 제거
            textField.layer.borderColor = UIColor.clear.cgColor
            
            // 플레이스홀더 속성 설정
            let placeholderColor = UIColor(red: 0.824, green: 0.827, blue: 0.835, alpha: 1)
            textField.attributedPlaceholder = NSAttributedString(
                string: "연습 목록을 검색하세요",
                attributes: [
                    .foregroundColor: placeholderColor,
                ]
            )
            
            // 검색 아이콘 숨기기
            if let searchIcon = textField.leftView as? UIImageView {
                searchIcon.isHidden = true // 검색 아이콘 숨기기
            }
            
            // X 버튼 추가
            let clearButton = UIButton(type: .custom)
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton.tintColor = UIColor.gray // X 버튼 색상 설정
            //            clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
            
            // X 버튼을 rightView에 추가하고 항상 보이도록 설정
            textField.rightView = clearButton
            textField.rightViewMode = .always // X 버튼을 항상 보이게 설정
        }
        return searchBar
    }()
    
    func setUI(){
        
        contentView.addSubview(containerView)
        containerView.addSubview(searchBar)
        
        //제약조건
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
        ])
    }
}
