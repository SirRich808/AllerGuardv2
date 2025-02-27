import SwiftUI

/// View for app settings
struct SettingsView: View {
    // MARK: - Properties
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder content
                VStack(spacing: 20) {
                    Image(systemName: "gear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Customize your app settings")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 