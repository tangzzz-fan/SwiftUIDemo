import Combine
import Foundation

class TextDocumentEditor: ObservableObject {
    @Published var content: String = ""
    private var undoStack: [TextCommand] = []
    private var redoStack: [TextCommand] = []

    func insert(text: String, at position: Int) {
        let index = content.index(content.startIndex, offsetBy: position)
        content.insert(contentsOf: text, at: index)
    }

    func delete(range: Range<Int>) {
        let start = content.index(content.startIndex, offsetBy: range.lowerBound)
        let end = content.index(content.startIndex, offsetBy: range.upperBound)
        content.removeSubrange(start..<end)
    }

    func executeCommand(_ command: TextCommand) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()
    }

    func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
    }

    func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
    }

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    var canRedo: Bool {
        !redoStack.isEmpty
    }
}
