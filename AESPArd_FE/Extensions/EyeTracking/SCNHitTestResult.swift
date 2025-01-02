//
//  SCNHitTestResult.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/23/24.
//

import UIKit
import SceneKit

// SCNHitTestResult: Information about the result of a scene-space or view-space search for scene elements.

extension SCNHitTestResult {
    var screenPosition: CGPoint {
        // 기기의 실제 스크린 크기를 미터 단위로 구한 뒤 절반( 중심점 )을 구함
        // 원래는 각 기기마다 실제 스크린 크기를 일일이 구한 뒤
        let physicalIpadSize = CGSize(width: 0.062 / 2 , height: 0.135 / 2)
        let screenResolution = UIScreen.main.bounds.size // 픽셀 해상도
        
        let screenX = CGFloat(localCoordinates.x) / physicalIpadSize.width * screenResolution.width
        let screenY = CGFloat(localCoordinates.y) / physicalIpadSize.height * screenResolution.height
        
        return CGPoint(x: screenX, y: screenY)
    }
}



