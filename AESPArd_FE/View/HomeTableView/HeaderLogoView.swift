
import UIKit

class HeaderLogoView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setUI()
    }
    
    func setUI(){
        
        let containerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
            return view
        }()
        
        let headerLogoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "LOGO")
            return imageView
        }()
        
        self.addSubview(containerView)
        self.addSubview(headerLogoImageView)
        
        //제약조건
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            headerLogoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerLogoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            // headerLogoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
        ])
    }
}
