import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.1)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<OnboardingItem.items.count, id: \.self) { index in
                    OnboardingPageView(item: OnboardingItem.items[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack {
                Spacer()
                
                HStack {
                    // Indicatori di pagina
                    HStack(spacing: 8) {
                        ForEach(0..<OnboardingItem.items.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.green : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Pulsante Avanti/Inizia
                    Button(action: {
                        if currentPage < OnboardingItem.items.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            hasSeenOnboarding = true
                        }
                    }) {
                        Text(currentPage < OnboardingItem.items.count - 1 ? "Avanti" : "Inizia")
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 120, height: 44)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Reset hasSeenOnboarding quando la vista appare
            hasSeenOnboarding = false
        }
    }
}

struct OnboardingPageView: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: item.image)
                .font(.system(size: 100))
                .foregroundStyle(Color.green)
                .padding()
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.bottom, 20)
            
            Text(item.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding(.top, 60)
    }
}

#Preview {
    OnboardingView()
} 
