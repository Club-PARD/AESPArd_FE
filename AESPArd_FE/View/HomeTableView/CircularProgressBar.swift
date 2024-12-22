import UIKit

class CircularProgressBar: UIView {
    
    var lineWidth: CGFloat = 10  // 프로그래스 바의 두께
    
    var value: Double? {
        didSet {
            guard let _ = value else { return }
            setProgress(self.bounds)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        
        // 전체 원을 그리기 위한 UIBezierPath 생성
        let bezierPath = UIBezierPath()
        
        // 원의 반지름을 40px로 설정 (80px / 2) - lineWidth / 2
        let radius = rect.width / 2 - lineWidth / 2
        
        // 원의 중심 좌표
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        bezierPath.addArc(withCenter: center,
                          radius: radius,
                          startAngle: 0,
                          endAngle: .pi * 2,
                          clockwise: true)
        
        bezierPath.lineWidth = lineWidth
        UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1).set()
        bezierPath.stroke()
    }
    
    func setProgress(_ rect: CGRect) {
        guard let value = self.value else {
            return
        }
        
        // 기존에 그려진 프로그래스 바 제거
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let bezierPath = UIBezierPath()
        
        // 원의 반지름을 40px로 설정 (80px / 2) - lineWidth / 2
        let radius = rect.width / 2 - lineWidth / 2
        
        // 프로그래스 바의 시작 각도는 -π/2로 설정하여, 12시 방향부터 시작하도록 설정
        //40은 원의 반지름
        bezierPath.addArc(withCenter: CGPoint(x: 40, y: 40),
                          radius: 40 - lineWidth / 2,
                          startAngle: -.pi / 2,
                          endAngle: ((.pi * 2) * value) - (.pi / 2),
                          clockwise: true)
        
        // CAShapeLayer로 프로그래스 바 그리기
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineCap = .round  // 프로그래스 바의 끝을 둥글게 설정
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        
        // value에 따라 프로그래스 바 색상 변경
        if value <= 0.6 {
            shapeLayer.strokeColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor // 빨간색
        } else if value <= 0.8 {
            shapeLayer.strokeColor = UIColor(red: 1, green: 0.717, blue: 0, alpha: 1).cgColor // 주황색
        } else {
            shapeLayer.strokeColor = UIColor(red: 0, green: 0.75, blue: 0.2, alpha: 1).cgColor // 초록색
        }
        
        self.layer.addSublayer(shapeLayer)
        
        // 프로그래스 바 중앙에 표시될 레이블
        let label = UILabel()
        label.text = String(Int(value * 100)) + "점"
        
        // value에 따라 레이블 색상 변경
        if value <= 0.6 {
            label.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1) // 빨간색
        } else if value <= 0.8 {
            label.textColor = UIColor(red: 1, green: 0.717, blue: 0, alpha: 1) // 주황색
        } else {
            label.textColor = UIColor(red: 0, green: 0.75, blue: 0.2, alpha: 1) // 초록색
        }
        
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    }
}
