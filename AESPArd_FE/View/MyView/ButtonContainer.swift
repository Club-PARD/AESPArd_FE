//
//  ButtonContainer.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/26/24.
//

import UIKit

class ExpandableButton: UIButton {
    var touchAreaInsets = UIEdgeInsets.zero

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.inset(by: touchAreaInsets)
        return expandedBounds.contains(point)
    }
}
