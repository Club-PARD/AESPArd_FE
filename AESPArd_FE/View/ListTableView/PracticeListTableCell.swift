//
//  PracticeListTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/23/24.
//

import UIKit

class PracticeListTableCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "PracticeListTableCell")
        setUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleButtonToggleNotification), name: .listDeleteCheckNotification, object: nil)
        
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
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
    
    let practiceNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 0.18, green: 0.184, blue: 0.196, alpha: 1)
        return label
    }()
    
    let practiceDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        return label
    }()
    
    let selectedDeleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "check_X"), for: .normal)
        button.addTarget(self, action: #selector(deleteCheckButtonTapped), for: .touchUpInside)
//        button.backgroundColor = .green
        // 이미지 중앙 정렬
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.layer.masksToBounds = true
        button.isHidden = true
        
        return button
    }()
    
    let recentCountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        //        button.setTitle(<#T##title: String?##String?#>, for: <#T##UIControl.State#>)
        button.backgroundColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1)
        // 텍스트 색상 설정
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        return button
    }()
    
    let smallCircularProgressBar: SmallCircularProgressBar = {
        let progressBar = SmallCircularProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    func setUI(){
        
        contentView.addSubview(containerView)
        containerView.addSubview(smallContainerView)
        
        containerView.addSubview(recentCountButton)
        containerView.addSubview(selectedDeleteButton)
        
        containerView.addSubview(practiceNameLabel)
        containerView.addSubview(practiceDateLabel)
        containerView.addSubview(smallCircularProgressBar)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            smallContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            smallContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            smallContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            smallContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            recentCountButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            recentCountButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            recentCountButton.widthAnchor.constraint(equalToConstant: 20),
            recentCountButton.heightAnchor.constraint(equalToConstant: 20),
            
            selectedDeleteButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            selectedDeleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            //            selectedDeleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            selectedDeleteButton.widthAnchor.constraint(equalToConstant: 48),
            
            practiceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 21),
            practiceNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 48),
            
            practiceDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            practiceDateLabel.leadingAnchor.constraint(equalTo: practiceNameLabel.trailingAnchor, constant: 4),
            
            smallCircularProgressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            smallCircularProgressBar.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            smallCircularProgressBar.widthAnchor.constraint(equalToConstant: 60),
            smallCircularProgressBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // 발표 연습 갯수 텍스트 설정 메서드
    func configure( practiceDate: String, practiceScore: Double){
        practiceDateLabel.text = "\(practiceDate)"
        smallCircularProgressBar.value = practiceScore
    }
    
    //삭제하기 -> 리스트 체크 버튼
    @objc func deleteCheckButtonTapped(){
        if selectedDeleteButton.currentImage == UIImage(named: "check_X") {
            selectedDeleteButton.setImage(UIImage(named: "check_O"), for: .normal)
        } else {
            selectedDeleteButton.setImage(UIImage(named: "check_X"), for: .normal)
        }
    }
    
    // 버튼 상태를 토글하는 메서드
    @objc func handleButtonToggleNotification() {
        if !recentCountButton.isHidden {
            recentCountButton.isHidden = true
            selectedDeleteButton.isHidden = false
        } else {
            recentCountButton.isHidden = false
            selectedDeleteButton.isHidden = true
        }
    }
}

