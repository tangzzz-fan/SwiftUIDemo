//
//  NetworkView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import Combine
import SwiftUI

// MARK: - 数据模型
struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

// MARK: - 网络服务
class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://jsonplaceholder.typicode.com"

    func fetchPosts() -> AnyPublisher<[Post], Error> {
        guard let url = URL(string: "\(baseURL)/posts") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - 视图模型
class NetworkViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchPosts() {
        isLoading = true
        error = nil

        NetworkService.shared.fetchPosts()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] posts in
                self?.posts = posts
            }
            .store(in: &cancellables)
    }
}

struct NetworkView: View {
    @StateObject private var viewModel = NetworkViewModel()

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            if let error = viewModel.error {
                Text(error)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            ForEach(viewModel.posts, id: \.id) { post in
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("网络请求")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.fetchPosts) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}

#Preview {
    NavigationView {
        NetworkView()
    }
}
