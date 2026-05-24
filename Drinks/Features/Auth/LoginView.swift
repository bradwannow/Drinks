import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    let onSignUp: () -> Void
    let onForgotPassword: () -> Void

    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                AuthHeader(
                    title: "Welcome back",
                    subtitle: "Sign in to pick up where you left off."
                )
                .fadeInOnAppear()

                VStack(spacing: AppSpacing.md) {
                    if let errorMessage = authViewModel.errorMessage {
                        AuthMessageBanner(message: errorMessage)
                    }

                    if let successMessage = authViewModel.successMessage {
                        AuthMessageBanner(message: successMessage, style: .success)
                    }

                    AuthTextField(
                        title: "Email",
                        placeholder: "you@example.com",
                        text: $email,
                        contentType: .emailAddress,
                        keyboardType: .emailAddress
                    )
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                    AuthPasswordField(
                        title: "Password",
                        placeholder: "Your password",
                        text: $password
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { submit() }

                    HStack {
                        Spacer()
                        AuthTextButton(title: "Forgot password?", action: onForgotPassword)
                    }
                }
                .fadeInOnAppear(delay: 0.05)

                VStack(spacing: AppSpacing.md) {
                    AuthPrimaryButton(
                        title: "Sign In",
                        isLoading: authViewModel.isSubmitting,
                        action: submit
                    )

                    HStack(spacing: AppSpacing.xs) {
                        Text("New to Pour?")
                            .captionStyle()

                        AuthTextButton(title: "Create account", action: onSignUp)
                    }
                }
                .fadeInOnAppear(delay: 0.1)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func submit() {
        focusedField = nil
        Task {
            await authViewModel.signIn(email: email, password: password)
        }
    }
}

#Preview {
    LoginView(onSignUp: {}, onForgotPassword: {})
        .environmentObject(AuthViewModel())
        .screenBackground()
        .preferredColorScheme(.dark)
}
