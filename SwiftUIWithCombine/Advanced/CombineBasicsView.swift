//
//  CombineBasicsView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import Combine
import SwiftUI

// MARK: - 自定义发布者
class NumberPublisher {
    let publisher = PassthroughSubject<Int, Never>()
    private var counter = 0

    func generateNumber() {
        counter += 1
        publisher.send(counter)
    }
}

// MARK: - 视图模型
class CombineViewModel: ObservableObject {
    @Published var numbers: [Int] = []
    @Published var filteredNumbers: [Int] = []
    @Published var searchText = ""

    private var cancellables = Set<AnyCancellable>()
    private let numberPublisher = NumberPublisher()

    init() {
        // 订阅数字发布者
        numberPublisher.publisher
            .sink { [weak self] number in
                self?.numbers.append(number)
            }
            .store(in: &cancellables)

        // 设置搜索过滤器
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { searchText in
                self.numbers.filter { number in
                    searchText.isEmpty || String(number).contains(searchText)
                }
            }
            .assign(to: &$filteredNumbers)
    }

    func generateNewNumber() {
        numberPublisher.generateNumber()
    }
}

struct CombineBasicsView: View {
    @StateObject private var viewModel = CombineViewModel()

    var body: some View {
        List {
            Section("发布者与订阅者") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("生成的数字:")
                        .font(.headline)

                    Text(viewModel.numbers.map(String.init).joined(separator: ", "))
                        .font(.body)

                    Button("生成新数字") {
                        viewModel.generateNewNumber()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical)
            }

            Section("操作符示例") {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("搜索数字", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)

                    Text("过滤结果:")
                        .font(.headline)

                    Text(viewModel.filteredNumbers.map(String.init).joined(separator: ", "))
                        .font(.body)
                }
                .padding(.vertical)
            }

            Section("Combine 特性") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 异步事件处理")
                    Text("• 函数式编程")
                    Text("• 声明式数据处理")
                    Text("• 内存管理")
                    Text("• 错误处理")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Combine 基础")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CombineBasicsView()
    }
}
