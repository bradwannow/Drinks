import SwiftUI
import UIKit

struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .labelStyle()

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .modifier(OptionalTextContentType(contentType: contentType))
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm + 4)
                .background(fieldBackground)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
            .fill(AppColors.surface)
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                    .strokeBorder(AppColors.surfaceHighlight.opacity(0.6), lineWidth: 0.5)
            }
    }
}

struct AuthPasswordField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var showsCharacterCount: Bool = false
    var minimumLength: Int = 8

    @State private var isVisible = false

    private var meetsMinimumLength: Bool {
        text.count >= minimumLength
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .labelStyle()

            HStack(spacing: AppSpacing.sm) {
                Group {
                    if isVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isVisible ? "Hide password" : "Show password")
            }
            .padding(.leading, AppSpacing.md)
            .padding(.trailing, AppSpacing.sm)
            .padding(.vertical, AppSpacing.sm + 4)
            .background(fieldBackground)

            if showsCharacterCount {
                HStack {
                    Text("\(text.count) characters")
                        .captionStyle()

                    Spacer()

                    if !text.isEmpty {
                        Text(meetsMinimumLength ? "Meets minimum" : "Need \(minimumLength - text.count) more")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(meetsMinimumLength ? AppColors.accent : AppColors.textTertiary)
                    }
                }
            }
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
            .fill(AppColors.surface)
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                    .strokeBorder(AppColors.surfaceHighlight.opacity(0.6), lineWidth: 0.5)
            }
    }
}

private struct OptionalTextContentType: ViewModifier {
    let contentType: UITextContentType?

    func body(content: Content) -> some View {
        if let contentType {
            content.textContentType(contentType)
        } else {
            content
        }
    }
}

struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(AppColors.background)
                        .scaleEffect(0.9)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .foregroundStyle(AppColors.background)
            .background {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                    .fill(AppColors.accent)
                    .shadow(color: AppColors.accent.opacity(0.35), radius: 12, y: 6)
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.85 : 1)
    }
}

struct AuthTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.accent)
        }
        .buttonStyle(.plain)
    }
}

struct AuthMessageBanner: View {
    enum Style {
        case error
        case success
    }

    let message: String
    var style: Style = .error

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: style == .error ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(style == .error ? AppColors.accentSecondary : AppColors.accent)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                        .strokeBorder(
                            (style == .error ? AppColors.accentSecondary : AppColors.accent).opacity(0.35),
                            lineWidth: 0.5
                        )
                }
        }
    }
}

struct AuthHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Pour")
                .labelStyle()

            Text(title)
                .displayMediumStyle()

            Text(subtitle)
                .bodyStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        AuthTextField(title: "Email", placeholder: "you@example.com", text: .constant(""), contentType: .emailAddress, keyboardType: .emailAddress)
        AuthPrimaryButton(title: "Sign In", action: {})
        AuthMessageBanner(message: "Invalid email or password.")
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
