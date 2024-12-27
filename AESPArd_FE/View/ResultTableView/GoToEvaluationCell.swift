//
//  GoToEvaluationCell.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/26/24.
//

import UIKit

class GoToEvaluationCell: UITableViewCell {
    
    // MARK: - Initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "GoToEvaluationCell")
        setUI()
        
        // 배경 색상 설정
        self.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1, alpha: 1)
    }
    
    // MARK: - Properties
    let seeEvaluationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 타이틀 설정
        button.setTitle("평가기준 보러가기", for: .normal)
        button.setTitleColor(UIColor(red: 0.2, green: 0.439, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        
        // 버튼 이미지 설정
        button.setImage(UIImage(named: "chevron-left (1)"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        // 아이콘 위치 조정
        button.semanticContentAttribute = .forceRightToLeft
        
        // 클릭 이벤트 추가
        button.addTarget(self, action: #selector(gotoEvaluationTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - UI 설정 메서드
    func setUI() {
        contentView.addSubview(seeEvaluationButton)
        
        // 레이아웃 제약 조건 추가
        NSLayoutConstraint.activate([
            seeEvaluationButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            seeEvaluationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            seeEvaluationButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12) // 수정된 부분
        ])
    }
    
    // MARK: - 버튼 동작 메서드
    @objc func gotoEvaluationTapped() {
        guard let parentViewController = findViewController() else { return }
        
        let vc = EvaluationModalView()
        vc.modalPresentationStyle = .overCurrentContext // 현재 뷰 위에 표시
        vc.modalTransitionStyle = .crossDissolve        // 부드러운 전환 효과
        
        // 배경 색상 및 투명도 설정
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // 모달 뷰 크기 및 위치 설정
        let modalView = UIView()
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 20
        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(modalView)
        // 부모 뷰 컨트롤러에서 present 호출
        parentViewController.present(vc, animated: true, completion: nil)
    }


}

// MARK: - UIView 확장
extension UIView {
    // 부모 뷰 컨트롤러 찾기
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            responder = nextResponder
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
