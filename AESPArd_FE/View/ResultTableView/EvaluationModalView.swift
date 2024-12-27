//
//  EvaluationView.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/26/24.
//

import UIKit

class EvaluationModalView: UIViewController {
    
    // 닫기 버튼
    let exitButton: ExpandableButton = {
        let button = ExpandableButton()
        button.setImage(UIImage(named: "X-iCon"), for: .normal)
        button.addTarget(self, action: #selector(exit), for: .touchUpInside)
        button.touchAreaInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 모달 뷰
    let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경 설정
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI()
        
        // 배경 터치 시 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exit))
        view.addGestureRecognizer(tapGesture)
    }
    
    // UI 설정
    func setupUI() {
        // 중앙 모달 추가
        view.addSubview(modalView)
        modalView.addSubview(exitButton)
        
        // 모달 위치 및 크기 설정
        NSLayoutConstraint.activate([
            modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modalView.widthAnchor.constraint(equalToConstant: 361),
            modalView.heightAnchor.constraint(equalToConstant: 607)
        ])
        
        // 닫기 버튼 위치 설정
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 16),
            exitButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -17),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // 닫기 메서드
    @objc func exit() {
        UIView.animate(withDuration: 0.3, animations: {
            self.modalView.alpha = 0
            self.view.backgroundColor = .clear
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
}
