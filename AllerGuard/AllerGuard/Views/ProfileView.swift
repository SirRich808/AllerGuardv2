import SwiftUI

/// View for managing user profile and allergen preferences
struct ProfileView: View {
    // MARK: - Properties
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder content
                VStack(spacing: 20) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("User Profile")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Set up your allergen profile and preferences")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 