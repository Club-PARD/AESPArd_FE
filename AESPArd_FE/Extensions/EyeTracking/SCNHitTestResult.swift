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
        // 원래는 각 기기마다 실제 스크린 크기를 일일이 구해야 함
        let physicalIpadSize = CGSize(width: 0.062 / 2 , height: 0.135 / 2)
        let screenResolution = UIScreen.main.bounds.size // 픽셀 해상도
        
        // localCoordinates:3D position of a point on the viewPlane in the x-direction, in meters.
        // localCoordinates: 0.0은 중심, 양수는 오른쪽, 음수는 왼쪽
        
        // x, y 포인트를 찾기 위해서는 노멀라이즈(정규화)가 필요함 -> 범위를 0과 1로 조정
        // 예시)
        // 기기의 스크린 width 사이즈가 10이라고 가정. 중간 지점은 2로 나눈 5
        // 그러면 3D 포인트 값을 기기의 사이즈의 절반으로 나두게 되면 -1이 기기의 왼쪽 끝, 0.0이 중심, 1 오른쪽 끝이 됨
        // localCoordinates의 포인트가 3일때는 3/5 = 0.6 이 기기 스크린 크기에 맞는 2D 포인트가 되는 것.
        // 여기까지가 CGFloat(localCoordinates.x) / physicalIpadSize.width
        // 하지만 기기의 화면은 픽셀단위 -> 픽셀 단위로 치환한 위치를 얻어야 함 -> 그래서 기기의 픽셀을 곱해줌
        
        let screenX = CGFloat(localCoordinates.x) / physicalIpadSize.width * screenResolution.width
        let screenY = CGFloat(localCoordinates.y) / physicalIpadSize.height * screenResolution.height
        
        return CGPoint(x: screenX, y: screenY)
    }
}



