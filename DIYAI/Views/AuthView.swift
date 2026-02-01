import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var email: String = ""
    @State private var didSendLink: Bool = false

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            Spacer()
            VStack(spacing: AppSpacing.s) {
                Text("Welcome to DIY AI")
                    .font(.appTitle)
                Text("Sign in with email for a secure session.")
                    .font(.appBody)
                    .foregroundColor(AppColors.textSecondary)
            }

            Card {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    SectionHeader(title: "Email", subtitle: "Sign in with a secure magic link")
                    TextField("you@example.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(AppSpacing.s)
                        .background(AppColors.surfaceElevated)
                        .cornerRadius(AppCornerRadius.s)

                    PrimaryButton(title: "Send magic link", systemImage: "envelope") {
                        Task {
                            await session.signInWithEmail(email)
                            didSendLink = true
                        }
                    }
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1)

                    if didSendLink {
                        Text("Check your email for a secure sign-in link.")
                            .font(.appCaption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if let error = session.authErrorMessage {
                        Text(error)
                            .font(.appCaption)
                            .foregroundColor(.red)
                    }
                }
            }

            SecondaryButton(title: "Skip for now", systemImage: "person.crop.circle") {
                Task {
                    await session.signInAnonymously()
                }
            }
            .padding(.horizontal, AppSpacing.l)

            Spacer()
            Text("By continuing, you agree to our Terms & Privacy Policy.")
                .font(.appCaption)
                .foregroundColor(AppColors.textSecondary)
                .padding(.bottom, AppSpacing.l)
        }
        .padding(.horizontal, AppSpacing.l)
    }
}
