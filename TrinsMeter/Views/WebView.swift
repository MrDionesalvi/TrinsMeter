import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.addObserver(context.coordinator, 
                           forKeyPath: #keyPath(WKWebView.estimatedProgress), 
                           options: .new, 
                           context: nil)
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Non serve aggiornare la vista
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        override func observeValue(forKeyPath keyPath: String?,
                                 of object: Any?,
                                 change: [NSKeyValueChangeKey : Any]?,
                                 context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress" {
                if let progress = (object as? WKWebView)?.estimatedProgress {
                    parent.loadingProgress = progress
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.error = nil
        }
        
        func webView(_ webView: WKWebView, 
                    didFailProvisionalNavigation navigation: WKNavigation!, 
                    withError error: Error) {
            parent.isLoading = false
            parent.error = error
        }
    }
} 