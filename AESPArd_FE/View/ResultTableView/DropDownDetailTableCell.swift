//
//  CloseDetailTableCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit


extension Notification.Name {
    static let helpButtonNotification = Notification.Name("helpButtonNotification")
}

class DropDownDetailTableCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "DropDownDetailTableCell")
        setUI()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        helpView.isHidden = true
        helpLabel.isHidden = true
    }
    
    private var rowIndex: Int = 0 // 행 번호를 저장할 변수 추가
    
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
    
    //MARK: - 드롭다운 열렸을 경우
    let evaluationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor =  UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.isHidden = true
        return label
    }()
    
    let myEvaluationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor =  UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.isHidden = true
        return label
    }()
    
    let evaluationValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.isHidden = true
        return label
    }()
    
    let myValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.isHidden = true
        return label
    }()
    
    let helpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "help-circle"), for: .normal)
        button.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        //        button.backgroundColor = .green
        button.isHidden = true
        
        return button
    }()
    
    let helpView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 1, alpha: 1)
        view.layer.cornerRadius = 20
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.isHidden = true
        
        return view
    }()
    
    let helpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    //MARK: - 제약조건
    func setUI(){
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(itemName)
        containerView.addSubview(itemExplain)
        containerView.addSubview(dropDownButton)
        
        containerView.addSubview(progressView)
        progressView.addSubview(itemScore)
        
        //드롭다운 열렸을 경우
        containerView.addSubview(evaluationLabel)
        containerView.addSubview(myEvaluationLabel)
        containerView.addSubview(evaluationValueLabel)
        containerView.addSubview(myValueLabel)
        containerView.addSubview(helpButton)
        
        //help
        containerView.addSubview(helpView)
        helpView.addSubview(helpLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            itemName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            itemName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            itemExplain.topAnchor.constraint(equalTo: itemName.bottomAnchor, constant: 2),
            itemExplain.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            dropDownButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36),
            dropDownButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            //            dropDownButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dropDownButton.widthAnchor.constraint(equalToConstant: 56),
            
            progressView.topAnchor.constraint(equalTo: itemExplain.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -65),
            progressView.heightAnchor.constraint(equalToConstant: 24),
            
            itemScore.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            itemScore.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: 7),
            
            //드롭다운 열렸을 경우
            evaluationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            evaluationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            myEvaluationLabel.topAnchor.constraint(equalTo: evaluationLabel.bottomAnchor, constant: 8),
            myEvaluationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            evaluationValueLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            evaluationValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            myValueLabel.topAnchor.constraint(equalTo: evaluationValueLabel.bottomAnchor, constant: 8),
            myValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            helpButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 18),
            helpButton.leadingAnchor.constraint(equalTo: evaluationLabel.trailingAnchor, constant: 4),
            
            helpView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 103),
            helpView.leadingAnchor.constraint(equalTo: helpButton.trailingAnchor),
            helpView.widthAnchor.constraint(greaterThanOrEqualToConstant: 130),  // 최소 너비
            helpView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),  // 최소 높이

            // helpLabel의 제약조건
            helpLabel.topAnchor.constraint(equalTo: helpView.topAnchor, constant: 8),
            helpLabel.leadingAnchor.constraint(equalTo: helpView.leadingAnchor, constant: 12),
            helpLabel.trailingAnchor.constraint(equalTo: helpView.trailingAnchor, constant: -12),
            helpLabel.bottomAnchor.constraint(equalTo: helpView.bottomAnchor, constant: -8)
            
        ])
    }
    
    //MARK: - 메서드
    
    // 발표 항목 정보 설정 메서드
    func configure(itemNameList: String, itemTotalScore: Double, itemDetailList: String, rowIndex: Int) {
        self.rowIndex = rowIndex
        itemName.text = itemNameList
        itemExplain.text = itemDetailList
        
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
        let currentImage = dropDownButton.image(for: .normal)
        let chevronDownImage = UIImage(named: "chevron-down")
        let chevronUpImage = UIImage(named: "chevron-up")
        
        if currentImage == chevronDownImage {
            //드롭다운이 열림
            dropDownButton.setImage(chevronUpImage, for: .normal)
            
            evaluationLabel.isHidden = false
            myEvaluationLabel.isHidden = false
            evaluationValueLabel.isHidden = false
            myValueLabel.isHidden = false
            helpButton.isHidden = false

            
        } else {
            //드롭다운이 닫힘
            dropDownButton.setImage(chevronDownImage, for: .normal)
            
            evaluationLabel.isHidden = true
            myEvaluationLabel.isHidden = true
            evaluationValueLabel.isHidden = true
            myValueLabel.isHidden = true
            helpButton.isHidden = true
            
            helpView.isHidden = true
            helpLabel.isHidden = true
        }
    }
    
    //헬프 버튼 메서드
    @objc func helpButtonTapped() {
        let isCurrentlyHidden = helpView.isHidden
    
        helpView.isHidden = !isCurrentlyHidden
        helpLabel.isHidden = !isCurrentlyHidden
    }
    
}
