//
//  BasicControlsView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

struct BasicControlsView: View {
    // MARK: - State
    @State private var text = ""
    @State private var isToggleOn = false
    @State private var sliderValue = 50.0
    @State private var selectedDate = Date()
    @State private var selectedColor = Color.blue
    @State private var stepperValue = 1
    @State private var isAlertShowing = false
    @State private var selectedTab = 0

    // MARK: - Constants
    private let colors: [Color] = [.red, .green, .blue, .yellow]
    private let items = ["选项1", "选项2", "选项3"]

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Layout.spacing) {
                // MARK: - 文本与图片
                Group {
                    sectionHeader("文本与图片")

                    Text("基础文本")
                        .font(.headline)

                    Text("支持 **Markdown** 语法")
                        .textSelection(.enabled)

                    Text("自定义样式")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.blue)
                        .italic()
                        .shadow(radius: 1)

                    Label("带图标的文本", systemImage: "star.fill")
                        .foregroundStyle(.orange)

                    Image(systemName: "swift")
                        .font(.largeTitle)
                        .symbolEffect(.bounce)
                }

                Divider()

                // MARK: - 输入控件
                Group {
                    sectionHeader("输入控件")

                    TextField("请输入文本", text: $text)
                        .textFieldStyle(.roundedBorder)

                    Toggle("开关控件", isOn: $isToggleOn)
                        .toggleStyle(.switch)

                    Slider(value: $sliderValue, in: 0...100) {
                        Text("滑块")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("100")
                    }

                    DatePicker("选择日期", selection: $selectedDate)
                        .datePickerStyle(.compact)

                    Stepper("计数器: \(stepperValue)", value: $stepperValue, in: 1...10)
                }

                Divider()

                // MARK: - 选择控件
                Group {
                    sectionHeader("选择控件")

                    Picker("选项", selection: $selectedTab) {
                        ForEach(0..<items.count, id: \.self) { index in
                            Text(items[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)

                    ColorPicker("选择颜色", selection: $selectedColor)
                }

                Divider()

                // MARK: - 按钮与交互
                Group {
                    sectionHeader("按钮与交互")

                    Button("基础按钮") {
                        isAlertShowing = true
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        print("删除操作")
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        print("自定义按钮")
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("自定义按钮")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("基础控件")
        .alert("提示", isPresented: $isAlertShowing) {
            Button("确定") {}
        } message: {
            Text("这是一个基础的 Alert 示例")
        }
    }

    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        BasicControlsView()
    }
}
