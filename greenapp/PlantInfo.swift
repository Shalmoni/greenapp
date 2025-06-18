import Foundation

struct PlantDetails: Identifiable {
  let id = UUID()
  let name: String
  let description: String
}

class PlantInfoManager {
  static let shared = PlantInfoManager()
  private(set) var infos: [String: PlantDetails] = [:]

  private init() {
    loadCSV()
  }

  private func loadCSV() {
    guard let url = Bundle.main.url(forResource: "PlantInfo", withExtension: "csv") else {
      return
    }
    guard let content = try? String(contentsOf: url) else {
      return
    }
    let lines = content.split(separator: "\n")
    for line in lines.dropFirst() {  // skip header
      let parts = line.split(separator: ",", maxSplits: 1).map { String($0) }
      if parts.count == 2 {
        let name = parts[0]
        let desc = parts[1]
        infos[name] = PlantDetails(name: name, description: desc)
      }
    }
  }

  func description(for name: String) -> String {
    infos[name]?.description ?? "No information available."
  }
}
