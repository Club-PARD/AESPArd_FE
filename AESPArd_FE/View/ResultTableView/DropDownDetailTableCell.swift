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
        view.layer.cornerRadius = 50
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
    
    let circularProgressBar: CircularProgressBar = {
        let progressBar = CircularProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    let itemName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(red: 0.18, green: 0.184, blue: 0.196, alpha: 1)
        return label
    }()
    
    let itemExplain: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
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
    
    func setUI(){
        
        contentView.addSubview(containerView)
        containerView.addSubview(smallContainerView)
        containerView.addSubview(circularProgressBar)
        
        containerView.addSubview(itemName)
        containerView.addSubview(itemExplain)
        containerView.addSubview(dropDownButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            smallContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            smallContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            smallContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 33),
            smallContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            circularProgressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circularProgressBar.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            circularProgressBar.widthAnchor.constraint(equalToConstant: 80),
            circularProgressBar.heightAnchor.constraint(equalToConstant: 80),
            
            itemName.topAnchor.constraint(equalTo: smallContainerView.topAnchor, constant: 21.5),
            itemName.leadingAnchor.constraint(equalTo: circularProgressBar.trailingAnchor, constant: 16),
            
            itemExplain.topAnchor.constraint(equalTo: itemName.bottomAnchor, constant: 2),
            itemExplain.leadingAnchor.constraint(equalTo: circularProgressBar.trailingAnchor, constant: 16),
            
            dropDownButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            dropDownButton.trailingAnchor.constraint(equalTo: smallContainerView.trailingAnchor),
            dropDownButton.bottomAnchor.constraint(equalTo: smallContainerView.bottomAnchor),
            dropDownButton.widthAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    // 발표 항목 정보 설정 메서드
    func configure(itemNameList: String, itemTotalScore: Double, itemDetailList: String) {
        circularProgressBar.value = itemTotalScore
        itemName.text = itemNameList
        itemExplain.text = itemDetailList
        AI = itemNameList
    }
    
    //드롭다운 버튼 메서드
    @objc func dropDownButtonTapped() {
        if(AI != "발표 내용 AI 분석 기능" ){
            print("드롭다운ㅋㅋ")
        }
    }
}
