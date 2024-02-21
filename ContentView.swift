import SwiftUI

struct ContentView: View {
    @AppStorage("showBoarding") private var showBoarding: Bool = true
    
    var body: some View {
        NavigationStack {
            if showBoarding {
                BoardingView()
            } else {
                MainView()
            }
        }
        .accentColor(.Primary)
    }
}
