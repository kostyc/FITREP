import SwiftUI

struct ContentView: View {
    @StateObject private var profileManager = RSProfileManager()
    @State private var showingTermsOfUse: Bool = false
    
    private let currentTermsVersion = "1.0"
    
    init() {
        let hasAcceptedTerms = UserDefaults.standard.bool(forKey: "TermsAccepted")
        let acceptedVersion = UserDefaults.standard.string(forKey: "AcceptedTermsVersion") ?? "0.0"
        _showingTermsOfUse = State(initialValue: !hasAcceptedTerms || acceptedVersion != currentTermsVersion)
    }
    
    var body: some View {
        ZStack {
            TabView {
                LogbookView(profileManager: profileManager)
                    .tabItem {
                        Label("Logbook", systemImage: "book.fill")
                    }
                
                ProfileView(profileManager: profileManager)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                
                MROView(profileManager: profileManager)
                    .tabItem {
                        Label("MROW", systemImage: "pencil")
                    }
                
            }
            
            if showingTermsOfUse {
                TermsOfUseView(isPresented: $showingTermsOfUse) {}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 16 Pro Max")
        ContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
