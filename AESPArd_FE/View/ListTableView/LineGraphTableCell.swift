//
//  LineGraphTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

class LineGraphTableCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "LineGraphTableCell")
        setUI()
        
    }
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        //        label.numberOfLines = 0 // 여러 줄로 텍스트 표시
        //        label.lineBreakMode = .byWordWrapping
        label.text = "나의 발표력 성장 곡선"
        return label
    }()
    
    private let talkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1)
        label.text = "최근 다섯개 데이터의 결과에요!"
        return label
    }()
    
    private let talkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "talk")
        return imageView
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
    
    func setUI(){
        
        contentView.addSubview(containerView)
        contentView.addSubview(guideLabel)
        contentView.addSubview(talkImageView)
        talkImageView.addSubview(talkLabel)
        
        NSLayoutConstraint.activate([
            
            guideLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            guideLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            guideLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -16),
            
            talkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            talkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            talkLabel.topAnchor.constraint(equalTo: talkImageView.topAnchor, constant: 23),
            talkLabel.centerXAnchor.constraint(equalTo: talkImageView.centerXAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 224),
            
        ])
    }
}

