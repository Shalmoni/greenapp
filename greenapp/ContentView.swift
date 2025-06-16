import SwiftUI

struct Plant: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

private let plantOptions = [
    "Wheat",
    "Barley",
    "Grape",
    "Fig",
    "Pomegranate",
    "Olive",
    "Date"
]

struct ContentView: View {
    @State private var grid: [Plant?] = Array(repeating: nil, count: 9)
    @State private var isEditing = false
    @State private var showAddSheet = false
    @State private var plantToAdd: Plant? = nil

    var body: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(grid.indices, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: isEditing && grid[index] == nil && plantToAdd != nil ? [5] : []))
                            .frame(height: 80)
                        if let plant = grid[index] {
                            Text(plant.name)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if isEditing && plantToAdd != nil {
                            Image(systemName: "plus")
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        guard isEditing else { return }
                        if let newPlant = plantToAdd {
                            grid[index] = newPlant
                            plantToAdd = nil
                        } else {
                            grid[index] = nil
                        }
                    }
                }
            }
            .animation(.default, value: grid)

            HStack {
                Button(isEditing ? "Exit Edit Mode" : "Edit Mode") {
                    isEditing.toggle()
                    plantToAdd = nil
                    showAddSheet = false
                }
                Spacer()
                Button("Add Plant") {
                    showAddSheet = true
                    isEditing = true
                }
                .popover(isPresented: $showAddSheet) {
                    PlantPicker { plant in
                        plantToAdd = plant
                        showAddSheet = false
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct PlantPicker: View {
    var onSelect: (Plant) -> Void
    @State private var searchText = ""

    private var filtered: [String] {
        guard !searchText.isEmpty else { return plantOptions }
        return plantOptions.filter { $0.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
            List(filtered, id: \.self) { name in
                Button(name) {
                    onSelect(Plant(name: name))
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 250, height: 300)
    }
}

#Preview {
    ContentView()
}
