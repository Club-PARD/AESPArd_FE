//
//  HeaderTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/21/24.
//

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
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    func setUI(){
        
        let containerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white // 예시로 배경색을 설정
            return view
        }()

        contentView.addSubview(greetingLabel)
        contentView.addSubview(containerView)
        
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
        greetingLabel.text = "\(userName)님, 오늘도 프리와 함께 발표준비해요!"
    }
}
