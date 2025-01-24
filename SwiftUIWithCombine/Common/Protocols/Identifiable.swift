import Foundation

protocol Identifiable {
    var id: String { get }
}

protocol ViewModelProtocol: ObservableObject {
    associatedtype State
    var state: State { get set }
    func dispatch(_ action: Any)
}
