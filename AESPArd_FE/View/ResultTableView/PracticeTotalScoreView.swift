//
//  PracticeTotalScoreCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit

class PracticeTotalScoreView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "총 점수"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        return label
    }()
    
    private let totalScoreView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0.2, alpha: 1)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        return view
    }()
    
    let totalScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Bold", size: 24)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    func setUI(){
        
        self.addSubview(scoreLabel)
        self.addSubview(totalScoreView)
        totalScoreView.addSubview(totalScoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 45),
            scoreLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24),
            scoreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            totalScoreView.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            totalScoreView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            totalScoreView.heightAnchor.constraint(equalToConstant: 40),
            
            //            totalScoreLabel.centerXAnchor.constraint(equalTo: totalScoreView.centerXAnchor),
            //            totalScoreLabel.centerYAnchor.constraint(equalTo: totalScoreView.centerYAnchor),
            totalScoreLabel.leadingAnchor.constraint(equalTo: totalScoreView.leadingAnchor, constant: 8),
            totalScoreLabel.trailingAnchor.constraint(equalTo: totalScoreView.trailingAnchor, constant: -8),
            totalScoreLabel.topAnchor.constraint(equalTo: totalScoreView.topAnchor, constant: 5.5),
            totalScoreLabel.bottomAnchor.constraint(equalTo: totalScoreView.bottomAnchor, constant: -5.5)
        ])
    }
}

