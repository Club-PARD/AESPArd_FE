//
//  ListHeaderTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

protocol ListHeaderTableCellDelegate: AnyObject {
    func dismissViewController()
}

class ListHeaderTableCell: UITableViewCell {
    
    weak var delegate: ListHeaderTableCellDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "ListHeaderTableCell")
        setUI()
        
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        return view
    }()
    
    let headerLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = .black
        return label
    }()
    
    let backButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        button.backgroundColor = .green
        return button
    }()
    
    let moreButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "more"), for: .normal)
        button.addTarget(self, action: #selector(moreEditButtonTapped), for: .touchUpInside)
//        button.backgroundColor = .green
        return button
    }()
    
    func setUI(){
        
        contentView.addSubview(containerView)
        containerView.addSubview(backButton)
        containerView.addSubview(headerLabel)
        containerView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            backButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            moreButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            moreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
        ])
    }
    
    //뒤로가기 버튼 탭
    @objc func backButtonTapped() {
        // delegate로 ListViewController의 dismissViewController 호출
            delegate?.dismissViewController()
    }
    
    // 발표 정보 설정 메서드
    func configure(presentationFolderName: String) {
        headerLabel.text = "\(presentationFolderName)"
    }
    
    //수정 버튼 탭
    @objc func moreEditButtonTapped() {
        print("수정버튼 클릭")
    }
    
    
}

