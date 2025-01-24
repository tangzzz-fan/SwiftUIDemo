//
//  CommandPatternView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

struct CommandPatternView: View {
    @StateObject private var editor = TextDocumentEditor()
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("命令模式示例")
                .font(.headline)

            TextEditor(
                text: Binding(
                    get: { editor.content },
                    set: { editor.content = $0 }
                )
            )
            .frame(height: 200)
            .border(Color.gray, width: 1)

            HStack {
                TextField("输入要插入的文本", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("插入") {
                    let command = InsertTextCommand(
                        text: inputText,
                        position: editor.content.count,
                        editor: editor
                    )
                    editor.executeCommand(command)
                    inputText = ""
                }
                .disabled(inputText.isEmpty)
            }

            HStack(spacing: 20) {
                Button("撤销") {
                    editor.undo()
                }
                .disabled(!editor.canUndo)

                Button("重做") {
                    editor.redo()
                }
                .disabled(!editor.canRedo)

                Button("删除最后一个字符") {
                    guard !editor.content.isEmpty else { return }
                    let range = (editor.content.count - 1)..<editor.content.count
                    let deletedText = String(editor.content.suffix(1))
                    let command = DeleteTextCommand(
                        range: range,
                        deletedText: deletedText,
                        editor: editor
                    )
                    editor.executeCommand(command)
                }
                .disabled(editor.content.isEmpty)
            }

            Text("说明：")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            Text(
                """
                这是一个使用命令模式实现的简单文本编辑器。
                • 可以在输入框中输入文本并插入
                • 支持撤销/重做操作
                • 可以删除最后一个字符

                命令模式的优点：
                1. 将操作封装为对象
                2. 支持撤销/重做
                3. 易于扩展新命令
                """
            )
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    CommandPatternView()
}
