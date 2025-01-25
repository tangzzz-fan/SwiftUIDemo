import Combine
import SwiftUI

// MARK: - Models
struct Product: Hashable {

    let id: UUID
    let name: String
    let price: Double
    let image: String

    init(id: UUID = UUID(), name: String, price: Double, image: String) {
        self.id = id
        self.name = name
        self.price = price
        self.image = image
    }
}

// MARK: - ViewModel
final class ShoppingCartViewModel: ObservableObject {
    @Published private(set) var items: [Product: Int] = [:]
    @Published private(set) var totalAmount: Double = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        // 监听购物车变化，自动计算总金额
        $items
            .map { items in
                items.reduce(0) { total, item in
                    total + (item.key.price * Double(item.value))
                }
            }
            .assign(to: \.totalAmount, on: self)
            .store(in: &cancellables)
    }

    func addToCart(_ product: Product) {
        items[product, default: 0] += 1
    }

    func removeFromCart(_ product: Product) {
        guard let count = items[product], count > 0 else { return }
        if count == 1 {
            items.removeValue(forKey: product)
        } else {
            items[product] = count - 1
        }
    }

    func clearCart() {
        items.removeAll()
    }
}

// MARK: - View
struct ShoppingCartView: View {
    @StateObject private var viewModel = ShoppingCartViewModel()

    let sampleProducts: [Product] = [
        Product(name: "苹果", price: 5.0, image: "apple.logo"),
        Product(name: "香蕉", price: 3.0, image: "leaf"),
        Product(name: "橙子", price: 4.0, image: "circle.fill"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("购物车示例")
                .font(.headline)

            // 商品列表
            List(sampleProducts, id: \.id) { product in
                HStack {
                    Image(systemName: product.image)
                        .font(.title2)
                        .foregroundStyle(.blue)

                    Text(product.name)
                        .frame(width: 60, alignment: .leading)

                    Text("¥\(product.price, specifier: "%.2f")")

                    Spacer()

                    // 商品数量控制
                    HStack(spacing: 12) {
                        // 减少按钮
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.removeFromCart(product)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(viewModel.items[product] != nil ? .blue : .gray)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.items[product] == nil)

                        // 数量显示
                        Text("\(viewModel.items[product, default: 0])")
                            .frame(minWidth: 30)
                            .font(.headline)

                        // 增加按钮
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.addToCart(product)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)

            // 总计部分
            VStack(spacing: 16) {
                HStack {
                    Text("总计:")
                        .font(.headline)
                    Spacer()
                    Text("¥\(viewModel.totalAmount, specifier: "%.2f")")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal)

                Button {
                    withAnimation(.easeInOut) {
                        viewModel.clearCart()
                    }
                } label: {
                    Text("清空购物车")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.items.isEmpty)
                .opacity(viewModel.items.isEmpty ? 0.6 : 1)
            }

            // 说明部分
            VStack(alignment: .leading, spacing: 8) {
                Text("StateObject 使用说明:")
                    .font(.headline)
                    .padding(.top)

                Text("• ViewModel 使用 @Published 发布状态变化")
                Text("• 使用 Combine 监听并计算总金额")
                Text("• ViewModel 封装了业务逻辑")
                Text("• View 只负责展示和用户交互")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("购物车")
    }
}

#Preview {
    NavigationView {
        ShoppingCartView()
    }
}
