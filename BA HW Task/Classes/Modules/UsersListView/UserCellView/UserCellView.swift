import SwiftUI

struct UserCellView: View {
    var userName: String
    var postTitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(postTitle.capitalized)
                    .lineLimit(1)
                    .font(.title3)
                    .foregroundColor(.black.opacity(0.7))
                HStack {
                    Text("author:")
                        .foregroundColor(.black.opacity(0.5))
                    Text(userName.capitalized)
                        .foregroundColor(.red.opacity(0.7))
                }
                .font(.headline)
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .overlay(
            RoundedRectangle(
                cornerRadius: 12
            )
            .stroke(.gray, lineWidth: 1)
        )
    }
}

struct UserCellView_Previews: PreviewProvider {
    static var previews: some View {
        UserCellView(
            userName: "St Peter Peterson",
            postTitle: "nesciunt quas odio"
        )
    }
}

