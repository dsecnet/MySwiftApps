import SwiftUI

// MARK: - Welcome View
struct WelcomeView: View {
    @State private var navigateToLogin = false
    @State private var navigateToRegister = false

    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 25

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // MARK: - Background Image
                    Image("welcome_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                            height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                        )
                        .clipped()

                    // MARK: - Gradient Overlay (matches HTML: from-black/10 via-black/40 to-background-dark/95)
                    LinearGradient(
                        stops: [
                            .init(color: Color.black.opacity(0.10), location: 0.0),
                            .init(color: Color.black.opacity(0.40), location: 0.5),
                            .init(color: Color(hex: "101922").opacity(0.95), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // MARK: - Content (justify-end layout)
                    VStack(spacing: 0) {
                        // MARK: - Logo (absolute top center)
                        logoSection
                            .opacity(logoOpacity)
                            .scaleEffect(logoScale)
                            .padding(.top, geo.safeAreaInsets.top + 24)

                        Spacer()

                        // MARK: - Bottom content
                        VStack(spacing: 0) {
                            // Hero Title
                            heroTextSection
                                .padding(.bottom, 16)

                            // Subtitle
                            Text("welcome_hero_subtitle".localized)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: "E2E8F0"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .frame(maxWidth: 300)
                                .padding(.bottom, 40)

                            // Buttons
                            VStack(spacing: 16) {
                                // Get Started (Primary)
                                Button {
                                    navigateToRegister = true
                                } label: {
                                    Text("get_started".localized)
                                        .font(.system(size: 18, weight: .bold))
                                        .tracking(0.3)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(hex: "2b8cee"))
                                        .cornerRadius(12)
                                        .shadow(color: Color(hex: "2b8cee").opacity(0.25), radius: 12, x: 0, y: 4)
                                }

                                // Sign In (Secondary)
                                Button {
                                    navigateToLogin = true
                                } label: {
                                    Text("sign_in".localized)
                                        .font(.system(size: 18, weight: .bold))
                                        .tracking(0.3)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(hex: "1E293B").opacity(0.8))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "334155"), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)

                            // Terms
                            Text("terms_agree".localized)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "94A3B8"))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, geo.safeAreaInsets.bottom + 12)
                        }
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }
                }
                .ignoresSafeArea()
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(viewModel: AuthViewModel())
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView(viewModel: AuthViewModel())
            }
            .onAppear {
                startEntranceAnimation()
            }
        }
    }

    // MARK: - Logo
    private var logoSection: some View {
        HStack(spacing: 8) {
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .saturation(1.8)
                .contrast(1.4)
                .blendMode(.screen)

            Text("app_name".localized)
                .font(.system(size: 18, weight: .bold))
                .tracking(-0.3)
                .foregroundColor(.white)
        }
    }

    // MARK: - Hero Text
    private var heroTextSection: some View {
        VStack(spacing: 0) {
            Text("welcome_hero_title_1".localized)
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)

            Text("welcome_hero_title_2".localized)
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)

            (
                Text("welcome_hero_highlight".localized)
                    .foregroundColor(Color(hex: "2b8cee"))
                + Text(" ")
                + Text("welcome_hero_title_3".localized)
                    .foregroundColor(Color(hex: "2b8cee"))
            )
            .font(.system(size: 36, weight: .black))
            .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
        }
        .multilineTextAlignment(.center)
        .lineSpacing(2)
    }

    // MARK: - Entrance Animation
    private func startEntranceAnimation() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
            logoOpacity = 1.0
            logoScale = 1.0
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            contentOpacity = 1.0
            contentOffset = 0
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
