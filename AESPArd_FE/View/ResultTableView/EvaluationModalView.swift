//
//  EvaluationView.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/26/24.
//

import UIKit

class EvaluationModalView: UIViewController {
    
    // MARK: - 닫기 버튼
    let exitButton: ExpandableButton = {
        let button = ExpandableButton()
        button.setImage(UIImage(named: "X-iCon"), for: .normal)
        button.addTarget(self, action: #selector(exit), for: .touchUpInside)
        button.touchAreaInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 모달 뷰
    let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - 헤더
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = UIColor(red: 0, green: 0.125, blue: 0.42, alpha: 1)
        label.textAlignment = .left
        label.text = "pree 평가 항목 및 감점 기준"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.616, green: 0.624, blue: 0.647, alpha: 1)
        label.textAlignment = .left
        label.text = "pree는 발표 연습 결과를 총점 100점 만점으로 평가합니다. \n총 점수는 다음 6가지 항목의 점수를 더하여 산출됩니다."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoView1: InfoView = {
        let view = InfoView(
            title: "발표 시간 분석",
            description: "설정 시간보다 부족하거나 초과된 경우, 3초당 1점 감점",
            score: "20점 ",
            ex: "ex. 설정한 시간과 차이가 6초면 2점 감점"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoView2: InfoView = {
        let view = InfoView(
            title: "말의 속도 분석",
            description: "적정 속도는 130~150 WPM(Words Per Minute) \n이 범위를 벗어나면, 5 WPM당 7점 감점",
            score: "20점 ",
            ex: "ex. 125 WPM은 7점 감점"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoView3: InfoView = {
        let view = InfoView(
            title: "목소리 크기 분석",
            description: "적정 크기는 65~70 dB \n이 범위를 벗어나면, 1 dB당 5점 감점",
            score: "20점 ",
            ex: "ex. 63 dB이면 10점 감점"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let infoView4: InfoView = {
        let view = InfoView(
            title: "발화 지연 표현 분석",
            description: "“음”, “어”와 같은 발화 지연 표현 1회당 5점 감점",
            score: "10점 ",
            ex: "ex. 3회 사용 시 15점 감점"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoView5: InfoView = {
        let view = InfoView(
            title: "불필요한 공백 분석",
            description: "3~4.9초의 공백인 경우, 1회당 2점 감점 \n5초 이상의 공백인 경우, 1회당 5점 감점",
            score: "10점 ",
            ex: "ex. 3.5초 공백 2번, 5초 공백 1번이면 9점 감점"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoView6: InfoView = {
        let view = InfoView(
            title: "시선 처리 비율 분석",
            description: "화면 응시 비율이 80% 미만일 경우, 1%당 5점 감점",
            score: "20점 ",
            ex: "ex. 75% 응시 시 25점 감점"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI()

        
    }
    
    // MARK: - UI 설정
    func setupUI() {
        // 모달 뷰 추가
        view.addSubview(modalView)
        modalView.addSubview(exitButton)
        modalView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(subHeaderLabel)
        contentView.addSubview(infoView1)
        contentView.addSubview(infoView2)
        contentView.addSubview(infoView3)
        contentView.addSubview(infoView4)
        contentView.addSubview(infoView5)
        contentView.addSubview(infoView6)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 모달 뷰 레이아웃
            modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            modalView.widthAnchor.constraint(equalToConstant: 361),
            modalView.heightAnchor.constraint(equalToConstant: 607),
            
            exitButton.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 16),
            exitButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -17),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            
            // ScrollView 레이아웃
            scrollView.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 50),
            scrollView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: modalView.bottomAnchor),
            
            // ContentView 레이아웃
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Content 내부 요소 레이아웃
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            infoView1.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 16),
            infoView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoView1.heightAnchor.constraint(equalToConstant: 97),
            
            infoView2.topAnchor.constraint(equalTo: infoView1.bottomAnchor, constant: 8),
            infoView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoView2.heightAnchor.constraint(equalToConstant: 112),
            
            infoView3.topAnchor.constraint(equalTo: infoView2.bottomAnchor, constant: 8),
            infoView3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoView3.heightAnchor.constraint(equalToConstant: 112),
            
            infoView4.topAnchor.constraint(equalTo: infoView3.bottomAnchor, constant: 8),
            infoView4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoView4.heightAnchor.constraint(equalToConstant: 97),
            
            infoView5.topAnchor.constraint(equalTo: infoView4.bottomAnchor, constant: 8),
            infoView5.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView5.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoView5.heightAnchor.constraint(equalToConstant: 112),
            
            infoView6.topAnchor.constraint(equalTo: infoView5.bottomAnchor, constant: 8),
            infoView6.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoView6.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoView6.heightAnchor.constraint(equalToConstant: 97),
            
            
            
            // ContentView의 마지막 요소까지의 bottomAnchor 설정
            infoView6.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - 닫기 메서드
    @objc func exit() {
        UIView.animate(withDuration: 0.3, animations: {
            self.modalView.alpha = 0
            self.view.backgroundColor = .clear
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
}
