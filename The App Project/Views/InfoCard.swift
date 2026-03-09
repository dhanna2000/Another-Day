import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .bold()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct InfoCard_Previews: PreviewProvider {
    static var previews: some View {
        InfoCard(title: "Tasks", value: "3/5")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

