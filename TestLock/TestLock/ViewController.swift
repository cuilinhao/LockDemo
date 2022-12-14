//
//  ViewController.swift
//  TestLock
//
//  Created by Linhao CUI 崔林豪 on 2022/11/28.

//https://m.yisu.com/zixun/200005.html
//https://www.hackingwithswift.com/example-code/core-graphics/how-to-draw-lines-in-core-graphics-moveto-and-addlineto

import UIKit
import os


class ViewController: UIViewController {

    public  let ScreenHeight = UIScreen.main.bounds.size.height
    public  let ScreenWidth = UIScreen.main.bounds.size.width
    
    ///全部手势按键的数组
    private var buttonArr = [UIButton]()
    ///选中手势按键的数组
    private var selectorArr = [Any]()
    
    private var startPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var endPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    private var tagNumber = 0
    
    ///画图所需
    lazy var imageView: UIImageView = {
        let img = UIImageView()
        self.view.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            img.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            img.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            img.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        return img
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = imageView
        initUI()
        
    }
    
    private func initUI() {
        ["11","22"].enumerated().forEach { index, item in
            print("___>>>_\(index)___\(item)")
        }
        let arr:[[String]] = [["1","2","3"],["1","2","3"],["1","2","3"]]
        
        arr.enumerated().forEach { i, item in
            item.enumerated().forEach { j, item2 in
                let btn = UIButton()
                btn.tag = tagNumber
                print("___>>>_\(btn.tag)")
                self.view.addSubview(btn)
                btn.frame = CGRect(x: ScreenWidth/12 + ScreenWidth/3 * CGFloat(j), y: ScreenHeight/3 + ScreenWidth / 3 * CGFloat(i), width: ScreenWidth/6, height: ScreenWidth/6)
                btn.setBackgroundImage(UIImage(named: "aaa"), for: .highlighted)
                btn.setBackgroundImage(UIImage(named: ""), for: .normal)
                btn.layer.borderColor = UIColor.systemGreen.cgColor
                btn.layer.borderWidth = 1.0
                self.buttonArr.append(btn)
                self.imageView.addSubview(btn)
                tagNumber += 1
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = touches.map { touch in
            _ = self.buttonArr.map({ btn in
                //记录按键坐标
                let point = touch.location(in: btn as! UIView)
                if btn.point(inside: point, with: nil) {
                    self.selectorArr.append(btn)
                    btn.isHighlighted = true
                    self.startPoint = btn.center
                    print("___>>>__开始的btn__\(btn.tag)")
                }
            })
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = touches.map({ touch in
            self.endPoint = touch.location(in: self.imageView)
            _ = self.buttonArr.map({ btn in
                let po = touch.location(in: btn)
                if btn.point(inside: po, with: nil) {
                    //记录是否重复按键
                    var isAdd = true
                    for seBtn in self.selectorArr {
                        if seBtn as! UIButton == btn {
                            isAdd = false
                            break
                        }
                    }
                    
                    if isAdd {
                        print("___>>>__移动的btn__\(btn.tag)")
                        self.selectorArr.append(btn)
                        btn.isHighlighted = true
                    }
                }
            })
        })
        self.imageView.image = self.drawLine()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.imageView.image = nil
        self.selectorArr = []
        
        _ = self.buttonArr.map({ btn in
            btn.isHighlighted = false
        })
    }

}

extension ViewController {
    /*
     let renderer1 = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
     let img1 = renderer1.image { ctx in
         ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
         ctx.cgContext.setLineWidth(3)

         ctx.cgContext.move(to: CGPoint(x: 50, y: 450))
         ctx.cgContext.addLine(to: CGPoint(x: 250, y: 50))
         ctx.cgContext.addLine(to: CGPoint(x: 450, y: 450))
         ctx.cgContext.addLine(to: CGPoint(x: 50, y: 450))

         let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
         ctx.cgContext.addRect(rectangle)
         ctx.cgContext.drawPath(using: .fillStroke)
     }
     */
    private func drawLine() -> UIImage {
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(5)
        context?.setStrokeColor(UIColor.green.cgColor)
        //设置画线的起点
        context?.move(to: self.startPoint)
        //从起点划线到选中的按键中心，并切换划线的起点
        
        for btn in self.selectorArr {
            let btnPo = (btn as! UIButton).center
            context?.addLine(to: btnPo)
            context?.move(to: btnPo)
        }
        
        //画移动中的最后一条线
        context?.addLine(to: self.endPoint)
        
        context?.strokePath()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

