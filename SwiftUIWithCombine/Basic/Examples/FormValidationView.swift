import Combine
import SwiftUI

// MARK: - ViewModel
final class FormValidationViewModel: ObservableObject {
    // 输入字段
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // 验证状态
    @Published var usernameError = ""
    @Published var emailError = ""
    @Published var passwordError = ""
    @Published var confirmPasswordError = ""
    @Published var isValid = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        // 用户名验证
        $username
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { username in
                if username.isEmpty {
                    return "用户名不能为空"
                }
                if username.count < 4 {
                    return "用户名至少4个字符"
                }
                return ""
            }
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellables)

        // 邮箱验证
        $email
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                if email.isEmpty {
                    return "邮箱不能为空"
                }
                if !emailPredicate.evaluate(with: email) {
                    return "请输入有效的邮箱地址"
                }
                return ""
            }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellables)

        // 密码验证
        $password
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { password in
                if password.isEmpty {
                    return "密码不能为空"
                }
                if password.count < 6 {
                    return "密码至少6个字符"
                }
                return ""
            }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellables)

        // 确认密码验证
        Publishers.CombineLatest($password, $confirmPassword)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { password, confirmPassword in
                if confirmPassword.isEmpty {
                    return "请确认密码"
                }
                if password != confirmPassword {
                    return "两次输入的密码不一致"
                }
                return ""
            }
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancellables)

        // 表单整体验证
        Publishers.CombineLatest4(
            $usernameError, $emailError, $passwordError, $confirmPasswordError
        )
        .map { usernameError, emailError, passwordError, confirmPasswordError in
            return usernameError.isEmpty && emailError.isEmpty && passwordError.isEmpty
                && confirmPasswordError.isEmpty
        }
        .assign(to: \.isValid, on: self)
        .store(in: &cancellables)
    }

    func submitForm() {
        print("表单提交成功")
        // 这里可以添加实际的提交逻辑
    }
}

// MARK: - View
struct FormValidationView: View {
    @StateObject private var viewModel = FormValidationViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("表单验证示例")
                    .font(.headline)

                VStack(alignment: .leading) {
                    TextField("用户名", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)

                    if !viewModel.usernameError.isEmpty {
                        Text(viewModel.usernameError)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                VStack(alignment: .leading) {
                    TextField("邮箱", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if !viewModel.emailError.isEmpty {
                        Text(viewModel.emailError)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                VStack(alignment: .leading) {
                    SecureField("密码", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)

                    if !viewModel.passwordError.isEmpty {
                        Text(viewModel.passwordError)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                VStack(alignment: .leading) {
                    SecureField("确认密码", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)

                    if !viewModel.confirmPasswordError.isEmpty {
                        Text(viewModel.confirmPasswordError)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Button("提交") {
                    viewModel.submitForm()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isValid)

                // 说明
                VStack(alignment: .leading, spacing: 8) {
                    Text("StateObject 使用说明:")
                        .font(.headline)
                        .padding(.top)

                    Text("• 使用 Combine 处理表单验证")
                    Text("• 实时验证用户输入")
                    Text("• 使用防抖避免频繁验证")
                    Text("• 统一管理表单状态")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .padding()
        }
    }
}
