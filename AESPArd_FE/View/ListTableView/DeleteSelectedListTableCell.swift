//
//  DeleteSelectedListTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

extension Notification.Name {
    static let listDeleteCheckNotification = Notification.Name("listDeleteCheckNotification")
}


class DeleteSelectedListTableCell: UITableViewCell {

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "DeleteSelectedListTableCell")
        setUI()
   
    }
    
    let listCountLabel: UILabel = {
        let label = UILabel()
        label.font =  UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    func setUI(){
        
        contentView.addSubview(listCountLabel)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            
            listCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            listCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 47),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
   
        ])
    }
    
    //삭제 버튼 클릭 메서드
    @objc func deleteButtonTapped() {
        if deleteButton.currentImage == UIImage(named: "trash-click") {
            NotificationCenter.default.post(name:.listDeleteCheckNotification, object: nil)
            
            deleteButton.setTitleColor(UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1), for: .normal)
            deleteButton.setImage(UIImage(named: "trash"), for: .normal)
        } else {
            
            NotificationCenter.default.post(name:.listDeleteCheckNotification, object: nil)
            
            deleteButton.setTitleColor(UIColor(red: 1, green: 0, blue: 0, alpha: 1), for: .normal)
            deleteButton.setImage(UIImage(named: "trash-click"), for: .normal)
        }
    }
    
    // 라벨 발표 연습 갯수 텍스트 설정 메서드
    func configure(practiceCount: Int) {
        listCountLabel.text = "\(practiceCount)번의 연습 횟수가 있어요"
    }
}
