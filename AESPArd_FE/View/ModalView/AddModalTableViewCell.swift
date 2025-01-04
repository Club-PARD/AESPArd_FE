//
//  AddModalTableViewCell.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/24/24.
//

import UIKit

class AddModalTableViewCell: UITableViewCell {
    // MARK: - 선언

    private let countBackgroundView = UIView()
    private let countLabel = UILabel()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()    
    var presentationName: String?
    var updatedAtText: String?
    var totalPractices: Int?
    var isSelectedCell: Bool = false

    static let identifier = "AddModalTableViewCell"
    
    // MARK: - 식별자

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI 셋업

    private func setupUI() {
        //configure(title: "발표이름", detail: "발표세부정보설명 · \(updatedAtText)일 전", count: 4)
        backgroundColor = .white
        selectionStyle = .none

        // 제목 레이블
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        titleLabel.textColor = UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // 세부 내용 레이블
        detailLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        detailLabel.textColor = UIColor.gray
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailLabel)

        // 카운트 배경 뷰
        countBackgroundView.backgroundColor = .clear
        countBackgroundView.layer.borderWidth = 1
        countBackgroundView.layer.borderColor = UIColor(red: 0.54, green: 0.68, blue: 1, alpha: 1).cgColor
        countBackgroundView.layer.cornerRadius = 11
        countBackgroundView.isHidden = true
        countBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countBackgroundView)

        // 카운트 레이블
        countLabel.textColor = UIColor(red: 0.54, green: 0.68, blue: 1, alpha: 1)
        countLabel.font = UIFont(name: "Pretendard-Medium", size: 12)
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countBackgroundView.addSubview(countLabel)

        // 제약 조건
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17),

            countBackgroundView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            countBackgroundView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            countBackgroundView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            countLabel.leadingAnchor.constraint(equalTo: countBackgroundView.leadingAnchor, constant: 7),
            countLabel.trailingAnchor.constraint(equalTo: countBackgroundView.trailingAnchor, constant: -7),
            countLabel.topAnchor.constraint(equalTo: countBackgroundView.topAnchor, constant: 2),
            countLabel.bottomAnchor.constraint(equalTo: countBackgroundView.bottomAnchor, constant: -2)
        ])
    }

    // MARK: - 변수 정의

    func configure(presentationName: String, updatedAtText: String, totalPractices: Int) {
          titleLabel.text = presentationName
          detailLabel.text = updatedAtText
//          countLabel.text = "\(totalPractices+1)개"
        countLabel.text = ""
      }
}
