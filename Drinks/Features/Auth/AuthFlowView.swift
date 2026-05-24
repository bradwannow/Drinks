import SwiftUI

enum AuthScreen: Hashable {
    case login
    case signUp
    case forgotPassword
}

struct AuthFlowView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var screen: AuthScreen = .login

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    switch screen {
                    case .login:
                        LoginView(
                            onSignUp: { navigate(to: .signUp) },
                            onForgotPassword: { navigate(to: .forgotPassword) }
                        )
                        .transition(authTransition)

                    case .signUp:
                        SignUpView(onSignIn: { navigate(to: .login) })
                            .transition(authTransition)

                    case .forgotPassword:
                        ForgotPasswordView(onBack: { navigate(to: .login) })
                            .transition(authTransition)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.35), value: screen)
            .screenBackground()
        }
    }

    private var authTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 16)),
            removal: .opacity.combined(with: .offset(y: -12))
        )
    }

    private func navigate(to destination: AuthScreen) {
        authViewModel.clearMessages()
        withAnimation(.easeInOut(duration: 0.35)) {
            screen = destination
        }
    }
}

#Preview {
    AuthFlowView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
