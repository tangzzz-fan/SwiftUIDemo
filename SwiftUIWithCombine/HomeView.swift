//
//  HomeView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                // 基础模块
                Section("基础模块") {
                    NavigationLink(destination: BasicControlsView()) {
                        Label("基础控件", systemImage: "square.stack.3d.up")
                    }
                    NavigationLink(destination: StateManagementView()) {
                        Label("状态管理", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
                
                // 进阶模块
                Section("进阶模块") {
                    NavigationLink(destination: CombineBasicsView()) {
                        Label("Combine 响应式编程", systemImage: "function")
                    }
                    NavigationLink(destination: NetworkView()) {
                        Label("网络请求", systemImage: "network")
                    }
                    NavigationLink(destination: AnimationGestureView()) {
                        Label("动画与手势", systemImage: "hand.tap")
                    }
                    NavigationLink(destination: CustomViewsView()) {
                        Label("自定义视图", systemImage: "square.on.square")
                    }
                }
                
                // 使用模块
                Section("使用模块") {
                    NavigationLink(destination: BluetoothView()) {
                        Label("蓝牙连接", systemImage: "wave.3.right")
                    }
                    NavigationLink(destination: RouterView()) {
                        Label("路由处理", systemImage: "arrow.triangle.branch")
                    }
                    NavigationLink(destination: ActionSheetView()) {
                        Label("自定义 Action Sheet", systemImage: "square.stack.3d.down.right")
                    }
                }
                
                // 设计模式
                Section("设计模式") {
                    NavigationLink(destination: SingletonPatternView()) {
                        Label("单例模式", systemImage: "1.circle")
                    }
                    NavigationLink(destination: ObserverPatternView()) {
                        Label("观察者模式", systemImage: "eye")
                    }
                    NavigationLink(destination: FactoryPatternView()) {
                        Label("工厂模式", systemImage: "building.2")
                    }
                    NavigationLink(destination: CommandPatternView()) {
                        Label("命令模式", systemImage: "terminal")
                    }
                }
                
                // 高级模块
                Section("高级模块") {
                    NavigationLink(destination: ArchitectureView()) {
                        Label("架构模式", systemImage: "square.3.layers.3d")
                    }
                    NavigationLink(destination: PerformanceView()) {
                        Label("性能优化", systemImage: "gauge.with.dots.needle.50percent")
                    }
                    NavigationLink(destination: SystemIntegrationView()) {
                        Label("系统集成", systemImage: "gearshape.2")
                    }
                    NavigationLink(destination: TestingView()) {
                        Label("测试与调试", systemImage: "checklist")
                    }
                }
            }
            .navigationTitle("SwiftUI & Combine")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    HomeView()
}
