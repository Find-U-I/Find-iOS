//
//  UIView+Extension.swift
//  Find-iOS
//
//  Created by 이원석 on 2021/05/06.
//

import UIKit

extension UIView {
    // UIView 의 모서리가 둥근 정도를 설정
    func makeRounded(cornerRadius : CGFloat?){
        if let cornerRadius_ = cornerRadius {
            self.layer.cornerRadius = cornerRadius_
        }  else {
            // cornerRadius 가 nil 일 경우의 default
            self.layer.cornerRadius = self.layer.frame.height / 2
        }
        
        self.layer.masksToBounds = true
    }
    
    // UIView 부분적으로 둥글게 적용
    // 왼상단:layerMinXMinYCorner, 오른상단: layerMaxXMinYCorner, 왼하단: layerMinXMaxYCorner, 오른하단: layerMaxXMaxYCorner
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
    
    // Set UIView's Shadow
    func dropShadow(color: UIColor, offSet: CGSize, opacity: Float, radius: CGFloat) {
        
        // 그림자 색상 설정
        layer.shadowColor = color.cgColor
        // 그림자 크기 설정
        layer.shadowOffset = offSet
        // 그림자 투명도 설정
        layer.shadowOpacity = opacity
        // 그림자의 blur 설정
        layer.shadowRadius = radius
        // 구글링 해보세요!
        layer.masksToBounds = false
    }
}

