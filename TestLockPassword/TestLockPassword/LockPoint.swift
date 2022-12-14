//
//  LockPoint.swift
//  TestLockPassword
//
//  Created by Linhao CUI 崔林豪 on 2022/12/5.
//

import UIKit

class LockPoint: CAShapeLayer {
    
    fileprivate struct Shape {
        let fillColor: UIColor
        let rect: CGRect
        let stroke: Bool
        let strokeColor: UIColor
    }
    
    var selected: Bool = false {
        didSet {
            drawAll()
        }
    }
    
    var angle: CGFloat = 999 {
        didSet {
            drawAll()
        }
    }
    
    var tag: Int = 0
    //没选中状态
    fileprivate lazy var innerNormal: Shape = {
        let width = bounds.width * Lock.scale
        let x = bounds.width * (1 - Lock.scale) * 0.5
        let shape = Shape(fillColor: .lightGray, rect: CGRect(x: x, y: x, width: width, height: width), stroke: false, strokeColor: .purple)
        return shape
    }()
    
    fileprivate lazy var innerSelected: Shape = {
        let width = bounds.width * Lock.scale
        let x = bounds.width * (1 - Lock.scale) * 0.5
        let shape = Shape(fillColor: .green, rect: CGRect(x: x, y: x, width: width, height: width), stroke: false, strokeColor: .green)
        return shape
    }()
    
    fileprivate lazy var innerTriangle: Shape = {
        let width = bounds.width * Lock.scale
        let x = bounds.width * (1 - Lock.scale) * 0.5
        
        return Shape(fillColor: .yellow, rect: CGRect(x: x, y: x, width: width, height: width), stroke: false, strokeColor: .purple)
    }()
    
    //外圆描边
    fileprivate lazy var outerStore: Shape = {
        let width = bounds.width  - 2 * Lock.lineWidth
        //---
        let x = Lock.lineWidth
        
        return Shape(fillColor: .yellow, rect: CGRect(x: x, y: x, width: width, height: width), stroke: false, strokeColor: .purple)
    }()
    
    ///包含所选外圆的绘制信息
    fileprivate lazy var outerSelected: Shape = {
        let sizeWH = bounds.width - 2 * Lock.lineWidth
        let originXY = Lock.lineWidth
        let rect = CGRect(x: originXY, y: originXY, width: sizeWH, height: sizeWH)
        let outer = Shape(fillColor: .purple,
                          rect: rect,
                          stroke: false,
                          strokeColor: .blue)
        return outer
    }()
    
    init(frame: CGRect) {
        super.init()
        self.frame = frame
        drawAll()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.frame = frame
        drawAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func  drawAll() {
        sublayers?.removeAll()
        if selected {
            drawShape(outerSelected)
            drawShape(innerSelected)
            //if globalOptions.isDrawTriangle {
              //  drawTriangle(innerTriangle)
            //}
        }else {
            //实心圆
            //drawShape(innerNormal)
            //空心圆
            drawShape(outerStore)
        }
    }
    
}

extension LockPoint {
    private func drawShape(_ shape: Shape) {
        let path = UIBezierPath(ovalIn: shape.rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = shape.fillColor.cgColor
        if shape.stroke {
            shapeLayer.strokeColor = shape.strokeColor.cgColor
        }
        shapeLayer.path = path.cgPath
        addSublayer(shapeLayer)
    }
    
    private func drawTriangle(_ shape: Shape) {
        if angle == 9999 {
            return
        }
        
        let triangleLayer = CAShapeLayer()
        let path = UIBezierPath()
        triangleLayer.fillColor = UIColor.green.cgColor
        
        let width: CGFloat = 10.0
        let height: CGFloat = 7.0
        
        let topX = shape.rect.minX + shape.rect.width * 0.5
        let topY = shape.rect.minY + (shape.rect.width * 0.5 - height - Lock.offsetInnerCircleAndTriangle - shape.rect.height * 0.5)

        path.move(to: CGPoint(x: topX, y: topY))
        
        let leftPointX = topX - width * 0.5
        let leftPointY = topY + height
        path.addLine(to: CGPoint(x: leftPointX, y: leftPointY))
        
        let rightPointX = topX + width * 0.5
        path.addLine(to: CGPoint(x: rightPointX, y: leftPointY))
        triangleLayer.path = path.cgPath
        
        //rotate
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, frame.width/2, frame.height/2, 0)
        transform = CATransform3DRotate(transform, angle, 0.0, 0.0, -1.0);
        transform = CATransform3DTranslate(transform, -frame.width/2, -frame.height/2, 0)
        triangleLayer.transform = transform
        addSublayer(triangleLayer)
    }
    
}

