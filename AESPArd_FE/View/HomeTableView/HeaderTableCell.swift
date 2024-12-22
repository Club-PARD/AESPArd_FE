//
//  HeaderTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/21/24.
//

import UIKit

class HeaderTableCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "HeaderTableCell")
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
        
        contentView.addSubview(containerView) 
        contentView.addSubview(headerLogoImageView)
        
        //제약조건
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            headerLogoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerLogoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            // headerLogoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
        ])
    }
}
