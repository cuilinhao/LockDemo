//
//  LockBoxView.swift
//  TestLockPassword
//
//  Created by Linhao CUI 崔林豪 on 2022/12/5.
//

import UIKit

public protocol LockEventDelegate: AnyObject {
    
    /// Use to notice the gesture point, and consist of password
    ///
    /// - Parameter tag: String. identifer for point
    func sendTouchPoint(with tag: String)
    
    /// Use to notice gesture end
    func touchesEnded()
}

open class LockBoxView: UIView {
    
    private var points = [LockPoint]()
    private var currentPoint: CGPoint?
    private var lineLayer = CAShapeLayer()
    public weak var delegate: LockEventDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        //initUI()
        setupSubViews()
    }
    
    public required  init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LockBoxView {
    private func initUI() {
        (0...8).forEach { offset in
            let space = Lock.space
            let width = (frame.width - 2 * space) / 3
            let row = CGFloat(offset % 3)
            let column = CGFloat(offset / 3)
            let x = space * (row) + row * width
            let y = space * (column) + column * width
            let rect = CGRect(x: x, y: y, width: width, height: width)
            let point = LockPoint(frame: rect)
            point.tag = offset
            layer.addSublayer(point)
        }
        layer.masksToBounds = true
    }
    
    private func setupSubViews() {
        (0..<9).forEach { (offset) in
            let space: CGFloat = 30.0
            let pointWH = (frame.width - CGFloat(3 - 1) * space) / CGFloat(3)
            // layout vertically
            let row = CGFloat(offset % 3)
            let column = CGFloat(offset / 3)
            let x = space * (row) + row * pointWH
            let y = space * (column) + column * pointWH
            let rect = CGRect(x: x, y: y, width: pointWH, height: pointWH)
            let point = LockPoint(frame: rect)
            point.tag = offset
            layer.addSublayer(point)
        }
        layer.masksToBounds = true
    }
    
    
    private func drawLines2() {
        if points.isEmpty {
            return
        }
        let linePath = UIBezierPath()
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        lineLayer.strokeColor = UIColor.lightGray.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = 4.0
        
        points.enumerated().forEach { (offset, element) in
            let pointCenter = element.position
            if offset == 0 {
                linePath.move(to: pointCenter)
            }else {
                linePath.addLine(to: pointCenter)
            }
        }
        
        if let current = currentPoint {
            linePath.addLine(to: current)
        }
        
        lineLayer.path = linePath.cgPath
        layer.insertSublayer(lineLayer, at: 0)
    }
    
    private func drawLines() {
        if points.isEmpty { return }
        let linePath = UIBezierPath()
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = 4.0

        points.enumerated().forEach { (offset, element) in
            let pointCenter = element.position
            if offset == 0 {
                linePath.move(to: pointCenter)
            } else {
                linePath.addLine(to: pointCenter)
            }
        }
        
        if let current = currentPoint {
            linePath.addLine(to: current)
        }
        lineLayer.path = linePath.cgPath
//        if globalOptions.connectLineStart == .center {
//            layer.addSublayer(lineLayer)
//        } else {
//            layer.insertSublayer(lineLayer, at: 0)
//        }
        layer.insertSublayer(lineLayer, at: 0)
    }
    
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handlesTouches(touches)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handlesTouches(touches)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        noMoreTouches()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        noMoreTouches()
    }
     
    //MARK: - 处理手势
    
    private func handlesTouches(_ touches: Set<UITouch>) {
        guard !touches.isEmpty else {
            return
        }
        currentPoint = touches.first!.location(in: self)
        let location = touches.first!.location(in: self)
        if let point = point(by: location), !points.contains(point) {
            points.append(point)
            calAngle()
            point.selected = true
            guard let delegate = self.delegate else { return }
            delegate.sendTouchPoint(with: "\(point.tag)")
            drawLines()
        }
        
    }
    
    private func point2(by location: CGPoint) -> LockPoint? {
        guard let sublayers = layer.sublayers else {
            return nil
        }
        for point in sublayers where point is LockPoint {
            if point.frame.contains(location) {
                return point as? LockPoint
            }
        }
        return nil
    }
    
    private func point(by location: CGPoint) -> LockPoint? {
        guard let sublayers = layer.sublayers else { return nil }
        for point in sublayers where point is LockPoint {
            if point.frame.contains(location) {
                return point as? LockPoint
            }
        }
        return nil
    }
    
    private func noMoreTouches() {
        //最后一个点
        currentPoint = points.last?.position
        points.forEach { point in
            point.selected = false
            point.angle = 9999
        }
        points.removeAll()
        lineLayer.removeFromSuperlayer()
        guard let delegate = self.delegate else { return }
        delegate.touchesEnded()
    }
    
    private func calAngle() {
        let count = points.count
        if count > 1 {
            let after = points[count - 1]
            let before = points[count - 2]

            let after_x = after.frame.minX
            let after_y = after.frame.minY
            let before_x = before.frame.minX
            let before_y = before.frame.minY
            
            let absX = fabsf(Float(before_x - after_x))
            let absY = fabsf(Float(before_y - after_y))
            let abxZ = sqrtf(pow(absX, 2) + pow(absY, 2))
            
            if before_x == after_x, before_y > after_y {
                before.angle = 0
            } else if before_x < after_x, before_y > after_y {
                before.angle = -CGFloat(asin(absX/abxZ))
            } else if before_x < after_x, before_y == after_y {
                before.angle = -CGFloat(Double.pi) / 2
            } else if before_x < after_x, before_y < after_y {
                before.angle = -(CGFloat(Double.pi) / 2) - CGFloat(asin(absY/abxZ))
            } else if before_x == after_x, before_y < after_y {
                before.angle = -CGFloat(Double.pi)
            } else if before_x > after_x, before_y < after_y {
                before.angle = -CGFloat(Double.pi) - CGFloat(asin(absX/abxZ))
            } else if before_x > after_x, before_y == after_y {
                before.angle = -CGFloat(Double.pi * 1.5)
            } else if before_x > after_x, before_y > after_y {
                before.angle = -CGFloat(Double.pi * 1.5) - CGFloat(asin(absY/abxZ))
            }
        }
    }
}
