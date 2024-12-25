//
//  CloseDetailTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit

class DropDownDetailTableCell: UITableViewCell {
    
    weak var delegate: ListHeaderTableCellDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "DropDownDetailTableCell")
        setUI()
        
    }
    
    private var AI : String = ""
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        
        
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        return view
    }()
    
    let itemName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font =  UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.62, green: 0.62, blue: 0.65, alpha: 1)
        return label
    }()
    
    let itemExplain: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        return label
    }()
    
    let dropDownButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "chevron-down"), for: .normal)
        button.addTarget(self, action: #selector(dropDownButtonTapped), for: .touchUpInside)
        //        button.backgroundColor = .green
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.5 // 초기 진행률 설정
//        progressView.tintColor = UIColor.blue // 진행 부분 색상
        progressView.trackTintColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1) // 트랙 부분 색상
        progressView.layer.cornerRadius = 8 // 외부 모서리 둥글게 설정
        progressView.clipsToBounds = true
        
        progressView.subviews[1].clipsToBounds = true //내부 모서리 둥글게 설정
        progressView.layer.sublayers![1].cornerRadius = 8
        return progressView
    }()
    
    let itemScore: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font =  UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return label
    }()
    
    func setUI(){
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(itemName)
        containerView.addSubview(itemExplain)
        containerView.addSubview(dropDownButton)
        
        containerView.addSubview(progressView)
        progressView.addSubview(itemScore)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            itemName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            itemName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            itemExplain.topAnchor.constraint(equalTo: itemName.bottomAnchor, constant: 2),
            itemExplain.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            dropDownButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            dropDownButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dropDownButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dropDownButton.widthAnchor.constraint(equalToConstant: 56),
            
            progressView.topAnchor.constraint(equalTo: itemExplain.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -65),
            progressView.heightAnchor.constraint(equalToConstant: 24),
            
            itemScore.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            itemScore.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: 7),
        ])
    }
    
    // 발표 항목 정보 설정 메서드
    func configure(itemNameList: String, itemTotalScore: Double, itemDetailList: String) {
        itemName.text = itemNameList
        itemExplain.text = itemDetailList
        AI = itemNameList
        
        progressView.setProgress(Float(itemTotalScore), animated: false)
        
        if itemTotalScore <= 0.6 {
            progressView.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1) // 빨간색
        } else if itemTotalScore <= 0.8 {
            progressView.tintColor = UIColor(red: 1, green: 0.717, blue: 0, alpha: 1) // 주황색
        } else {
            progressView.tintColor = UIColor(red: 0, green: 0.75, blue: 0.2, alpha: 1) // 초록색
        }
        
        itemScore.text = "\(Int(itemTotalScore*100))점"
        
    }
    
    //드롭다운 버튼 메서드
    @objc func dropDownButtonTapped() {
        
    }
}
