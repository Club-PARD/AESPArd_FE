//
//  VideoPlayerViewCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit

class VideoPlayerView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    
    private let customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    func setUI(){
        
        self.addSubview(customView)
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: self.topAnchor),
            customView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            customView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            customView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
