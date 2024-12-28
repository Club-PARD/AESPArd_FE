//
//  EvaluationViewCell.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/27/24.
//

import UIKit

class InfoView: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let scoreLabel = UILabel()
    private let exLabel = UILabel()

    init(title: String, description: String, score: String, ex: String) {
        super.init(frame: .zero)
        setupUI()
        configure(title: title, description: description, score: score, ex: ex)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = UIColor(red: 0.961, green: 0.98, blue: 1, alpha: 1)
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1).cgColor

        titleLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1)

        descriptionLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        descriptionLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        descriptionLabel.numberOfLines = 0
        
        scoreLabel.font = UIFont(name: "Pretendard-Medium", size: 12)
        scoreLabel.textColor = UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1)
        scoreLabel.backgroundColor = .white
        scoreLabel.layer.cornerRadius = 9
        scoreLabel.layer.masksToBounds = true
        scoreLabel.textAlignment = .center
        
        let scoreContainer = UIView()
        scoreContainer.backgroundColor = .clear
        scoreContainer.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        scoreContainer.layer.shadowRadius = 15
        scoreContainer.layer.shadowOpacity = 1
        scoreContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        scoreContainer.clipsToBounds = false // 그림자 안 자르게 설정

        
        exLabel.font = UIFont(name: "Pretendard-Medium", size: 12)
        exLabel.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        exLabel.numberOfLines = 0
        
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(scoreContainer) // 컨테이너 추가
        scoreContainer.addSubview(scoreLabel) // 컨테이너에 라벨 추가
        addSubview(exLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreContainer.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        exLabel.translatesAutoresizingMaskIntoConstraints = false

    
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            // Score Container 레이아웃
            scoreContainer.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            scoreContainer.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            scoreContainer.widthAnchor.constraint(equalToConstant: 37),
            scoreContainer.heightAnchor.constraint(equalToConstant: 18),

            // Score Label 레이아웃
            scoreLabel.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: scoreContainer.widthAnchor),
            scoreLabel.heightAnchor.constraint(equalTo: scoreContainer.heightAnchor),

            
            exLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            exLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
        ])
    }

    func configure(title: String, description: String, score: String, ex: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        scoreLabel.text = score
        exLabel.text = ex
    }
}
