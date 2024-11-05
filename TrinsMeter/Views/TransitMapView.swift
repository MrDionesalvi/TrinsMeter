import SwiftUI

struct TransitMapView: View {
    private let trinsURL = URL(string: "https://trins.it")!
    @State private var isLoading = true
    @State private var loadingProgress = 0.0
    @State private var error: Error?
    @State private var showingErrorAlert = false
    
    var body: some View {
        ZStack {
            WebView(url: trinsURL, 
                   isLoading: $isLoading,
                   loadingProgress: $loadingProgress,
                   error: $error)
            .ignoresSafeArea(edges: .top)
            
            VStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    ProgressView(value: loadingProgress) {
                        Text("Caricamento...")
                            .font(.caption)
                    }
                    .tint(.green)
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Errore di Connessione", isPresented: $showingErrorAlert) {
            Button("Riprova") {
                reloadWebView()
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "Si è verificato un errore durante il caricamento della pagina.")
        }
    }
    
    private func reloadWebView() {
        isLoading = true
        loadingProgress = 0.0
        error = nil
    }
} 
