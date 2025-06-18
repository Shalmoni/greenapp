import SwiftUI

struct PlantInfoCard: View {
  let plant: Plant
  let description: String
  var onClose: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Text(plant.name)
        .font(.headline)
      ScrollView {
        Text(description)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      Button("Close", action: onClose)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 10)
    .frame(width: 300, height: 400)
  }
}
