import Foundation

struct PlantInfo: Identifiable {
    let id: String
    let name: String
    let sciname: String
    let originarea: String
    let family: String
    let lightrec: String
    let temprec: String
    let waterrec: String
    let apb: String
    let seed2sling: String
    let sling2growth: String
    let growth2flower: String
    let flower2dedo: String
    let dedo2growth: String
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
        for row in rows.dropFirst() {
            let cols = row.components(separatedBy: ",")
            if cols.count >= 14 {
                let info = PlantInfo(
                    id: cols[0],
                    name: cols[1],
                    sciname: cols[2],
                    originarea: cols[3],
                    family: cols[4],
                    lightrec: cols[5],
                    temprec: cols[6],
                    waterrec: cols[7],
                    apb: cols[8],
                    seed2sling: cols[9],
                    sling2growth: cols[10],
                    growth2flower: cols[11],
                    flower2dedo: cols[12],
                    dedo2growth: cols[13]
                )
                infos[info.id] = info
            }
        }
    }

    func info(for id: String) -> PlantInfo? {
        infos[id]
    }
}
