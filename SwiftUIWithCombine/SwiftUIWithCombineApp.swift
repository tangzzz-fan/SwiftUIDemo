//
//  SwiftUIWithCombineApp.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

@main
struct SwiftUIWithCombineApp: App {
    // 创建一个共享的 AppTheme 实例
    @StateObject private var theme = AppTheme()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .environmentObject(theme)  // 注入 AppTheme
            .preferredColorScheme(theme.colorScheme)  // 应用颜色方案
            .tint(theme.accentColor)  // 应用主题色
        }
    }
}
