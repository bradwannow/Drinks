import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    let onSignIn: () -> Void

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case username
        case email
        case password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                AuthHeader(
                    title: "Join Pour",
                    subtitle: "Create your profile and start discovering tonight's best pours."
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
                        title: "Username",
                        placeholder: "nightowl",
                        text: $username,
                        contentType: .username
                    )
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }

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
                        placeholder: "At least 8 characters",
                        text: $password,
                        showsCharacterCount: true
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { submit() }
                }
                .fadeInOnAppear(delay: 0.05)

                VStack(spacing: AppSpacing.md) {
                    AuthPrimaryButton(
                        title: "Create Account",
                        isLoading: authViewModel.isSubmitting,
                        action: submit
                    )

                    HStack(spacing: AppSpacing.xs) {
                        Text("Already have an account?")
                            .captionStyle()

                        AuthTextButton(title: "Sign in", action: onSignIn)
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
            await authViewModel.signUp(email: email, password: password, username: username)
        }
    }
}

#Preview {
    SignUpView(onSignIn: {})
        .environmentObject(AuthViewModel())
        .screenBackground()
        .preferredColorScheme(.dark)
}
