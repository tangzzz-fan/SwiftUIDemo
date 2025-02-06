import Combine
import SwiftUI

// MARK: - Domain Layer

// Entity
struct TodoItem: Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// Repository Protocol
protocol TodoRepository {
    func getTodos() -> AnyPublisher<[TodoItem], Never>
    func addTodo(_ todo: TodoItem)
    func updateTodo(_ todo: TodoItem)
    func deleteTodo(_ todo: TodoItem)
}

// Use Cases Protocol
protocol TodoUseCase {
    func fetchTodos() -> AnyPublisher<[TodoItem], Never>
    func addNewTodo(title: String)
    func toggleTodo(_ todo: TodoItem)
    func removeTodo(_ todo: TodoItem)
    func filterTodos(by filter: TodoFilter) -> [TodoItem]
}

// MARK: - Data Layer

// Repository Implementation
final class TodoRepositoryImpl: TodoRepository {
    @Published private var todos: [TodoItem] = []

    func getTodos() -> AnyPublisher<[TodoItem], Never> {
        $todos.eraseToAnyPublisher()
    }

    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
    }

    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
    }
}

// MARK: - Presentation Layer

enum TodoFilter {
    case all
    case active
    case completed
}

// ViewModel
final class TodoViewModel: ObservableObject {
    @Published private(set) var todos: [TodoItem] = []
    @Published var selectedFilter: TodoFilter = .all
    @Published var newTodoTitle: String = ""

    private let useCase: TodoUseCase
    private var cancellables = Set<AnyCancellable>()

    init(useCase: TodoUseCase) {
        self.useCase = useCase
        setupBindings()
    }

    private func setupBindings() {
        useCase.fetchTodos()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                guard let self = self else { return }
                self.todos = self.useCase.filterTodos(by: self.selectedFilter)
            }
            .store(in: &cancellables)

        $selectedFilter
            .sink { [weak self] filter in
                guard let self = self else { return }
                self.todos = self.useCase.filterTodos(by: filter)
            }
            .store(in: &cancellables)
    }

    func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        useCase.addNewTodo(title: newTodoTitle)
        newTodoTitle = ""
    }

    func toggleTodo(_ todo: TodoItem) {
        useCase.toggleTodo(todo)
    }

    func deleteTodo(_ todo: TodoItem) {
        useCase.removeTodo(todo)
    }
}

// Use Case Implementation
final class TodoUseCaseImpl: TodoUseCase {
    private let repository: TodoRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func fetchTodos() -> AnyPublisher<[TodoItem], Never> {
        repository.getTodos()
    }

    func addNewTodo(title: String) {
        let todo = TodoItem(title: title)
        repository.addTodo(todo)
    }

    func toggleTodo(_ todo: TodoItem) {
        var updatedTodo = todo
        updatedTodo.isCompleted.toggle()
        repository.updateTodo(updatedTodo)
    }

    func removeTodo(_ todo: TodoItem) {
        repository.deleteTodo(todo)
    }

    func filterTodos(by filter: TodoFilter) -> [TodoItem] {
        var filteredTodos: [TodoItem] = []
        repository.getTodos()
            .map { todos in
                switch filter {
                case .all: return todos
                case .active: return todos.filter { !$0.isCompleted }
                case .completed: return todos.filter { $0.isCompleted }
                }
            }
            .sink { todos in
                filteredTodos = todos
            }
            .store(in: &cancellables)
        return filteredTodos
    }
}

// MARK: - Views
struct TodoItemView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            Text(todo.title)
                .strikethrough(todo.isCompleted)
                .foregroundStyle(todo.isCompleted ? .gray : .primary)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

struct TodoListView: View {
    @StateObject private var viewModel: TodoViewModel

    init() {
        let repository = TodoRepositoryImpl()
        let useCase = TodoUseCaseImpl(repository: repository)
        _viewModel = StateObject(wrappedValue: TodoViewModel(useCase: useCase))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("待办事项清单")
                .font(.headline)

            // 新增待办输入框
            HStack {
                TextField("添加新待办...", text: $viewModel.newTodoTitle)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    withAnimation {
                        viewModel.addTodo()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .disabled(viewModel.newTodoTitle.isEmpty)
            }
            .padding(.horizontal)

            // 过滤器
            Picker("过滤", selection: $viewModel.selectedFilter) {
                Text("全部").tag(TodoFilter.all)
                Text("进行中").tag(TodoFilter.active)
                Text("已完成").tag(TodoFilter.completed)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // 待办列表
            List {
                ForEach(viewModel.todos, id: \.id) { todo in
                    TodoItemView(
                        todo: todo,
                        onToggle: { withAnimation { viewModel.toggleTodo(todo) } },
                        onDelete: { withAnimation { viewModel.deleteTodo(todo) } }
                    )
                }
            }
            .listStyle(.plain)

            // Combine 状态管理说明
            VStack(alignment: .leading, spacing: 8) {
                Text("Clean Architecture & SOLID 原则说明:")
                    .font(.headline)
                    .padding(.top)

                Text("• Domain Layer: 定义核心业务实体和接口")
                Text("• Data Layer: 实现数据存储和访问")
                Text("• Presentation Layer: 处理UI和用户交互")
                Text("• 依赖注入确保松耦合")
                Text("• 使用协议实现依赖倒置")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Todo List")
    }
}

#Preview {
    NavigationView {
        TodoListView()
    }
}
