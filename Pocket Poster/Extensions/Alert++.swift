//
//  Alert++.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import UIKit

// 来源致谢：sourcelocation & TrollTools
// 当前正在显示的 UIAlertController（用于控制弹窗状态）
var currentUIAlertController: UIAlertController?

// MARK: - 本地化字符串（默认提示文本）
fileprivate let errorString = NSLocalizedString("Error", comment: "")     // “错误”
fileprivate let okString = NSLocalizedString("OK", comment: "")           // “确定”
fileprivate let cancelString = NSLocalizedString("Cancel", comment: "")   // “取消”

extension UIApplication {
    
    /// 关闭当前弹出的 Alert 弹窗
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController?.dismiss(animated: animated)
        }
    }
    
    /// 显示一个错误提示 Alert（默认带一个“确定”按钮）
    func alert(title: String = errorString, body: String, animated: Bool = true, withButton: Bool = true) {
        DispatchQueue.main.async {
            var body = body
            
            if title == errorString {
                // 如果是错误弹窗，追加调试信息
                let device = UIDevice.current
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
                let systemVersion = device.systemVersion
                body += "\n\(device.systemName) \(systemVersion), version \(appVersion) build \(appBuild)"
            }
            
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            if withButton {
                currentUIAlertController?.addAction(.init(title: okString, style: .cancel))
            }
            
            self.present(alert: currentUIAlertController!)
        }
    }
    
    /// 显示一个确认弹窗（带“确认”与“取消”按钮，支持取消按钮隐藏）
    func confirmAlert(title: String = errorString,
                      body: String,
                      confirmTitle: String = okString,
                      onOK: @escaping () -> (),
                      noCancel: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            // 是否显示取消按钮
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: cancelString, style: .cancel))
            }
            
            // 添加确认按钮
            currentUIAlertController?.addAction(.init(title: confirmTitle, style: noCancel ? .cancel : .default, handler: { _ in
                onOK()
            }))
            
            self.present(alert: currentUIAlertController!)
        }
    }
    
    /// 修改当前弹窗的标题和内容
    func change(title: String = errorString, body: String) {
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
            currentUIAlertController?.message = body
        }
    }
    
    /// 显示一个 UIAlertController 弹窗（自动找到顶层 VC 进行展示）
    func present(alert: UIAlertController) {
        if var topController = self.windows[0].rootViewController {
            // 遍历出当前最顶层的视图控制器
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
}
