//
//  VideoPlayerViewCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/24/24.
//

import UIKit

class VideoPlayerViewCell: UITableViewCell {
    
    weak var delegate: ListHeaderTableCellDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "VideoPlayerViewCell")
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
        
        contentView.addSubview(customView)
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: contentView.topAnchor),
            customView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
