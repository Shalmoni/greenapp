import Foundation

struct PlantInfo: Identifiable {
    let id: String
    let name: String
    let description: String
}

class PlantInfoManager {
    static let shared = PlantInfoManager()
    private(set) var infos: [String: PlantInfo] = [:]

    private init() {
        loadCSV()
    }

    private func loadCSV() {
        guard let url = Bundle.main.url(forResource: "PlantInfo", withExtension: "csv") else {
            print("PlantInfo.csv not found")
            return
        }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("Failed to read PlantInfo.csv")
            return
        }

        let rows = content.components(separatedBy: "\n")
        for row in rows.dropFirst() { // skip header
            let cols = row.components(separatedBy: ",")
            if cols.count >= 3 {
                let info = PlantInfo(id: cols[0], name: cols[1], description: cols[2])
                infos[info.id] = info
            }
        }
    }

    func info(for id: String) -> PlantInfo? {
        infos[id]
    }
}
