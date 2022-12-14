//
//  ViewController.swift
//  TestLockPassword
//
//  Created by Linhao CUI 崔林豪 on 2022/12/5.
//

import UIKit

class ViewController: UIViewController {
    
    private let GWidth = UIScreen.main.bounds.size.width
    var password: String = ""
    var firstPassword: String = ""
    var secondPassword: String = ""
    
    lazy var pointView: LockBoxView = {
        let vv = LockBoxView(frame: CGRect(x: 50, y: 200, width: GWidth - 2 * 50, height: 400))
        vv.delegate = self
        view.addSubview(vv)
        return vv
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = pointView
    }

}

extension ViewController: LockEventDelegate {
    func sendTouchPoint(with tag: String) {
        print("___>>>_\(tag)")
        password += tag
    }
    
    func touchesEnded() {
        print("___>>>__gesture end")
        
    }
}

