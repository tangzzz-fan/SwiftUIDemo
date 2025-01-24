import Foundation

// 命令协议
protocol TextCommand {
    func execute()
    func undo()
}

// 插入文本命令
struct InsertTextCommand: TextCommand {
    private let text: String
    private let position: Int
    private weak var editor: TextDocumentEditor?

    init(text: String, position: Int, editor: TextDocumentEditor) {
        self.text = text
        self.position = position
        self.editor = editor
    }

    func execute() {
        editor?.insert(text: text, at: position)
    }

    func undo() {
        editor?.delete(range: position..<(position + text.count))
    }
}

// 删除文本命令
struct DeleteTextCommand: TextCommand {
    private let range: Range<Int>
    private let deletedText: String
    private weak var editor: TextDocumentEditor?

    init(range: Range<Int>, deletedText: String, editor: TextDocumentEditor) {
        self.range = range
        self.deletedText = deletedText
        self.editor = editor
    }

    func execute() {
        editor?.delete(range: range)
    }

    func undo() {
        editor?.insert(text: deletedText, at: range.lowerBound)
    }
}
