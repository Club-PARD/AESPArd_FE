//
//  GoToEvaluationCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/26/24.
//

import UIKit

class GoToEvaluationCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "GoToEvaluationCell")
        setUI()
        
        self.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
        
    }
    
    let seeEvaluationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("평가기준 보러가기", for: .normal)
        button.setTitleColor( UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
                
        button.setImage(UIImage(named: "chevron-left (1)"), for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(gotoEvaluationTapped), for: .touchUpInside)
        return button
    }()
 
    func setUI(){
        
        contentView.addSubview(seeEvaluationButton)
        
        NSLayoutConstraint.activate([
            seeEvaluationButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            seeEvaluationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            seeEvaluationButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
        ])
    }
    
    //평가기준 보러가기  버튼 메서드
    @objc func gotoEvaluationTapped() {
        print("평가기준 보러가기")
    }
}
