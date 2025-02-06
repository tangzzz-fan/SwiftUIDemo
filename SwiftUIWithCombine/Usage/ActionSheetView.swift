//
//  ActionSheetView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

// MARK: - 自定义 Action Sheet 样式
struct CustomActionSheet<Content: View>: View {
    let content: Content
    @Binding var isPresented: Bool
    var backgroundColor: Color = .white

    init(
        isPresented: Binding<Bool>, backgroundColor: Color = .white,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }

                VStack(spacing: 0) {
                    content
                        .padding()

                    Divider()

                    Button("取消") {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .transition(.move(edge: .bottom))
            }
        }
    }
}

// MARK: - 分享选项
struct ShareOption {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
}

// MARK: - 分享菜单
struct ShareSheet: View {
    let options: [ShareOption]
    let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("分享到")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(options, id: \.id) { option in
                    Button {
                        option.action()
                    } label: {
                        VStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: option.icon)
                                        .foregroundStyle(.white)
                                }

                            Text(option.title)
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 操作菜单
struct ActionMenu: View {
    let title: String
    let message: String?
    let actions: [(title: String, role: ButtonRole?, action: () -> Void)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(actions.indices, id: \.self) { index in
                let action = actions[index]
                Button(role: action.role) {
                    action.action()
                } label: {
                    Text(action.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(action.role == .destructive ? .red : nil)

                if index < actions.count - 1 {
                    Divider()
                }
            }
        }
    }
}

struct ActionSheetView: View {
    @State private var showShareSheet = false
    @State private var showActionMenu = false

    let shareOptions: [ShareOption] = [
        ShareOption(title: "微信", icon: "message.fill", color: .green) {},
        ShareOption(title: "朋友圈", icon: "person.2.fill", color: .blue) {},
        ShareOption(title: "QQ", icon: "bubble.left.fill", color: .orange) {},
        ShareOption(title: "微博", icon: "network", color: .red) {},
        ShareOption(title: "链接", icon: "link", color: .purple) {},
        ShareOption(title: "邮件", icon: "envelope.fill", color: .gray) {},
        ShareOption(title: "信息", icon: "message", color: .blue) {},
        ShareOption(title: "更多", icon: "ellipsis", color: .secondary) {},
    ]

    var body: some View {
        List {
            Section {
                Button("显示分享菜单") {
                    withAnimation {
                        showShareSheet = true
                    }
                }

                Button("显示操作菜单") {
                    withAnimation {
                        showActionMenu = true
                    }
                }
            }
        }
        .navigationTitle("自定义 Action Sheet")
        .overlay {
            CustomActionSheet(isPresented: $showShareSheet) {
                ShareSheet(options: shareOptions)
            }

            CustomActionSheet(isPresented: $showActionMenu) {
                ActionMenu(
                    title: "确认操作",
                    message: "这个操作无法撤销",
                    actions: [
                        ("取消", nil, {}),
                        ("删除", .destructive, {}),
                    ]
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        ActionSheetView()
    }
}
