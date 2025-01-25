//
//  StateManagementView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import Combine
import SwiftUI
import UserNotifications

// MARK: - 子视图
struct CounterView: View {
    @Binding var count: Int

    var body: some View {
        VStack {
            Text("当前计数: \(count)")
            Button("增加") {
                count += 1
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - 观察对象
final class UserSettings: ObservableObject {
    @Published var username: String = ""
    @Published var isNotificationsEnabled: Bool = false {
        didSet {
            if isNotificationsEnabled {
                requestNotificationPermission()
            } else {
                // 如果用户关闭通知，记录状态
                UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            }
        }
    }

    init() {
        // 从 UserDefaults 读取通知状态
        self.isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            DispatchQueue.main.async {
                if granted {
                    // 用户允许通知，保存状态
                    self.isNotificationsEnabled = true
                    UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                } else {
                    // 用户拒绝通知，更新UI
                    self.isNotificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                }
            }

            if let error = error {
                print("通知权限请求错误: \(error.localizedDescription)")
            }
        }
    }

    func updateUsername(_ newName: String) {
        username = newName
    }
}

// MARK: - 环境对象
final class AppTheme: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            // 更新系统外观
            if isDarkMode {
                colorScheme = .dark
            } else {
                colorScheme = .light
            }
        }
    }
    @Published var accentColor: Color = .blue
    @Published private(set) var colorScheme: ColorScheme = .light

    init() {
        // 初始化时根据系统设置
        self.isDarkMode = false
        self.colorScheme = .light
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }
}

struct StateManagementView: View {
    // MARK: - State Properties
    @State private var counter = 0
    @State private var text = ""
    @State private var isSheetPresented = false

    // MARK: - StateObject
    @StateObject private var settings = UserSettings()

    // MARK: - EnvironmentObject
    @EnvironmentObject private var theme: AppTheme

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - @State 示例
                Group {
                    sectionHeader("@State 示例")
                    Text("@State 用于管理视图内部的简单状态")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("输入文本", text: $text)
                        .textFieldStyle(.roundedBorder)

                    Text("输入的文本: \(text)")
                        .foregroundStyle(.secondary)
                }

                Divider()

                // MARK: - @Binding 示例
                Group {
                    sectionHeader("@Binding 示例")
                    Text("@Binding 用于在视图之间传递状态")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    CounterView(count: $counter)
                }

                Divider()

                // MARK: - @StateObject 示例
                Group {
                    sectionHeader("@StateObject 示例")
                    Text("@StateObject 用于管理复杂的状态对象")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("用户名", text: $settings.username)
                        .textFieldStyle(.roundedBorder)

                    Toggle("启用通知", isOn: $settings.isNotificationsEnabled)

                    Text("当前用户: \(settings.username)")
                        .foregroundStyle(.secondary)

                    Divider()

                    NavigationLink("购物车示例") {
                        ShoppingCartView()
                    }
                    .font(.subheadline)

                    NavigationLink("表单验证示例") {
                        FormValidationView()
                    }
                    .font(.subheadline)
                }

                Divider()

                // MARK: - @EnvironmentObject 示例
                Group {
                    sectionHeader("@EnvironmentObject 示例")
                    Text("@EnvironmentObject 用于全局状态管理")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Toggle("深色模式", isOn: $theme.isDarkMode)
                        .onChange(of: theme.isDarkMode) { newValue in
                            withAnimation {
                                theme.toggleTheme()
                            }
                        }

                    ColorPicker("主题色", selection: $theme.accentColor)
                }

                Divider()

                // MARK: - 状态管理最佳实践
                Group {
                    sectionHeader("状态管理最佳实践")

                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("使用 @State 管理简单的视图状态")
                        bulletPoint("使用 @Binding 在视图间共享状态")
                        bulletPoint("使用 @StateObject 管理复杂数据")
                        bulletPoint("使用 @EnvironmentObject 管理全局状态")
                        bulletPoint("遵循单一数据源原则")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("状态管理")
        .preferredColorScheme(theme.colorScheme)  // 应用颜色方案
        .tint(theme.accentColor)  // 应用主题色
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                Text("这是一个模态视图")
                Button("关闭") {
                    isSheetPresented = false
                }
            }
            .padding()
        }
    }

    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Preview
struct StateManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateManagementView()
                .environmentObject(AppTheme())
        }
    }
}
