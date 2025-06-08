//
//  TintedButton.swift
//  Pocket Poster
//
//  Created by lemin on 5/31/25.
//

import SwiftUI

/// 自定义按钮样式：支持颜色、模糊材质、是否全宽
struct TintedButton: ButtonStyle {
    var color: Color                        // 按钮主色
    var material: UIBlurEffect.Style?      // 可选的毛玻璃效果
    var fullwidth: Bool = false            // 是否铺满整个宽度
    
    /// 构造按钮主体视图
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if fullwidth {
                // 铺满宽度的按钮
                configuration.label
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .background(
                        material == nil
                        ? AnyView(color.opacity(0.2))              // 默认背景色
                        : AnyView(MaterialView(material!))         // 毛玻璃材质背景
                    )
                    .cornerRadius(8)
                    .foregroundColor(color)                       // 文字颜色为主色
            } else {
                // 普通宽度的按钮
                configuration.label
                    .padding(15)
                    .background(
                        material == nil
                        ? AnyView(color.opacity(0.2))
                        : AnyView(MaterialView(material!))
                    )
                    .cornerRadius(8)
                    .foregroundColor(color)
            }
        }
    }
    
    /// 初始化（无材质）
    init(color: Color = .blue, fullwidth: Bool = false) {
        self.color = color
        self.fullwidth = fullwidth
    }
    
    /// 初始化（带材质）
    init(color: Color = .blue, material: UIBlurEffect.Style, fullwidth: Bool = false) {
        self.color = color
        self.material = material
        self.fullwidth = fullwidth
    }
}

#if DEBUG
struct FullwidthTintedButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("示例按钮") {
            // 点击事件
        }
        .buttonStyle(TintedButton(color: .red, fullwidth: true)) // 使用红色，全宽按钮
        .padding()
    }
}
#endif
