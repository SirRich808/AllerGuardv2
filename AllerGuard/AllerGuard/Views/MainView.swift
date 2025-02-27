import SwiftUI

/// Main view for the app
struct MainView: View {
    // MARK: - Properties
    
    /// The selected tab
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Scan tab
            NavigationView {
                // Use a mock CameraView for now
                Text("Camera View")
                    .navigationTitle("Scan")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            }
            .tabItem {
                Label("Scan", systemImage: "camera.fill")
            }
            .tag(0)
            
            // History tab
            NavigationView {
                Text("History View")
                    .navigationTitle("History")
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            .tag(1)
            
            // Profile tab
            NavigationView {
                Text("Profile View")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(2)
            
            // Settings tab
            NavigationView {
                Text("Settings View")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .accentColor(.green)
        .onAppear {
            // Set up the app when it appears
            setupApp()
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up the app
    private func setupApp() {
        // In a real implementation, we would register services here
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
} 