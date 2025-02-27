import SwiftUI

/// View for displaying scan history
struct HistoryView: View {
    // MARK: - Properties
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder content
                VStack(spacing: 20) {
                    Image(systemName: "clock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Scan History")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your scan history will appear here")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("History")
        }
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
} 