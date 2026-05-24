import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    let onBack: () -> Void

    @State private var email = ""
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                AuthHeader(
                    title: "Reset password",
                    subtitle: "Enter your email and we'll send a reset link. Full in-app reset is coming soon."
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
                    .focused($isEmailFocused)
                    .submitLabel(.go)
                    .onSubmit { submit() }
                }
                .fadeInOnAppear(delay: 0.05)

                VStack(spacing: AppSpacing.md) {
                    AuthPrimaryButton(
                        title: "Send Reset Link",
                        isLoading: authViewModel.isSubmitting,
                        action: submit
                    )

                    AuthTextButton(title: "Back to sign in", action: onBack)
                }
                .fadeInOnAppear(delay: 0.1)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func submit() {
        isEmailFocused = false
        Task {
            await authViewModel.resetPassword(email: email)
        }
    }
}

#Preview {
    ForgotPasswordView(onBack: {})
        .environmentObject(AuthViewModel())
        .screenBackground()
        .preferredColorScheme(.dark)
}
