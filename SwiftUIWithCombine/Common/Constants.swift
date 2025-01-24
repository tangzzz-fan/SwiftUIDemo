import Foundation
import SwiftUI

enum Constants {
    enum Layout {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 44
    }

    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springDamping: Double = 0.7
    }

    enum Network {
        static let timeout: TimeInterval = 30
        static let baseURL = "https://api.example.com"
    }
}
