//
//  CustomViewsView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

// MARK: - 自定义视图修饰符
struct CardStyle: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

// MARK: - 自定义容器视图
struct FlowLayout: Layout {
    struct ItemInfo: Equatable {
        let size: CGSize
        let index: Int

        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.index == rhs.index
        }
    }

    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(
                at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY),
                proposal: .unspecified)
        }
    }

    struct FlowResult {
        let points: [CGPoint]
        let size: CGSize

        init(
            in maxWidth: CGFloat, subviews: Subviews, alignment: HorizontalAlignment,
            spacing: CGFloat
        ) {
            var currentRow: [ItemInfo] = []
            var rows: [[ItemInfo]] = []
            var currentRowWidth: CGFloat = 0
            var maxRowWidth: CGFloat = 0

            // 第一步：将子视图分组到行中
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                let itemWidth = size.width
                let itemSpacing = currentRow.isEmpty ? 0 : spacing

                if currentRowWidth + itemWidth + itemSpacing > maxWidth && !currentRow.isEmpty {
                    // 当前行已满，开始新行
                    rows.append(currentRow)
                    maxRowWidth = max(maxRowWidth, currentRowWidth)
                    currentRow = []
                    currentRowWidth = 0
                }

                let item = ItemInfo(size: size, index: index)
                currentRow.append(item)
                currentRowWidth += itemWidth + itemSpacing
            }

            // 添加最后一行
            if !currentRow.isEmpty {
                rows.append(currentRow)
                maxRowWidth = max(maxRowWidth, currentRowWidth)
            }

            // 第二步：计算每个项目的位置
            var points = Array(repeating: CGPoint.zero, count: subviews.count)
            var yOffset: CGFloat = 0

            for row in rows {
                let rowHeight = row.map { $0.size.height }.max() ?? 0
                let rowWidth =
                    row.reduce(0) { $0 + $1.size.width } + CGFloat(row.count - 1) * spacing

                // 根据对齐方式计算起始 x 坐标
                var xOffset: CGFloat
                switch alignment {
                case .trailing:
                    xOffset = maxWidth - rowWidth
                case .center:
                    xOffset = (maxWidth - rowWidth) / 2
                default:
                    xOffset = 0
                }

                // 放置行中的每个项目
                for item in row {
                    points[item.index] = CGPoint(x: xOffset, y: yOffset)
                    xOffset += item.size.width + spacing
                }

                yOffset += rowHeight + spacing
            }

            self.points = points
            self.size = CGSize(width: maxWidth, height: max(0, yOffset - spacing))
        }
    }
}

// MARK: - 自定义 ViewBuilder
struct ConditionalContent<TrueContent: View, FalseContent: View>: View {
    let condition: Bool
    let trueContent: () -> TrueContent
    let falseContent: () -> FalseContent

    var body: some View {
        if condition {
            trueContent()
        } else {
            falseContent()
        }
    }
}

// MARK: - View 扩展
extension View {
    func cardStyle(color: Color = .blue) -> some View {
        modifier(CardStyle(color: color))
    }

    func conditional<T: View, F: View>(
        _ condition: Bool,
        @ViewBuilder then: @escaping () -> T,
        @ViewBuilder else: @escaping () -> F
    ) -> some View {
        ConditionalContent(condition: condition, trueContent: then, falseContent: `else`)
    }
}

struct CustomViewsView: View {
    @State private var isExpanded = false
    let tags = ["SwiftUI", "Combine", "Swift", "iOS", "Xcode", "开发", "编程", "苹果", "移动开发", "跨平台", "Xcode", "开发", "编程", "苹果", "移动开发", "跨平台"]

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 自定义修饰符示例
                Section {
                    Text("自定义修饰符")
                        .font(.headline)

                    Text("这是一个卡片样式")
                        .cardStyle(color: .blue)

                    Text("另一个卡片样式")
                        .cardStyle(color: .green)
                }

                // 自定义容器示例
                Section {
                    Text("自定义流式布局")
                        .font(.headline)

                    FlowLayout(alignment: .leading, spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(15)
                        }
                    }
                }

                // 条件视图构建器示例
                Section {
                    Text("条件视图构建器")
                        .font(.headline)

                    Button(isExpanded ? "收起" : "展开") {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }

                    conditional(isExpanded) {
                        VStack {
                            Text("展开的内容")
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else: {
                        Text("点击展开查看更多")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("自定义视图")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CustomViewsView()
    }
}
