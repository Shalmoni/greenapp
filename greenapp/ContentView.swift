import SwiftUI

struct Plant: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

private let plantOptions = [
    "Wheat", "Barley", "Grape", "Fig", "Pomegranate", "Olive", "Date"
]

struct ContentView: View {
    @State private var grid: [Plant?] = Array(repeating: nil, count: 9)
    @State private var isEditing = false
    @State private var showAddSheet = false
    @State private var plantToAdd: Plant? = nil
    @State private var movingPlantIndex: Int? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Garden Grid with background and border
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(grid.indices, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.51, green: 0.36, blue: 0.22)) // #825C37
                                .frame(height: 80)
                                .overlay(
                                    ZStack {
                                        Rectangle()
                                            .stroke(Color.black, lineWidth: 2) // ✅ Black border
                                        if isEditing && grid[index] == nil && (plantToAdd != nil || movingPlantIndex != nil) {
                                            Rectangle()
                                                .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        }
                                    }
                                )

                            if let plant = grid[index] {
                                Text(plant.name)
                                    .foregroundColor(movingPlantIndex == index ? .gray : .white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if isEditing && (plantToAdd != nil || movingPlantIndex != nil) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                            }
                        }
                        .onTapGesture {
                            guard isEditing else { return }

                            if movingPlantIndex == index {
                                movingPlantIndex = nil
                                return
                            }

                            if let selected = movingPlantIndex, grid[index] == nil {
                                grid[index] = grid[selected]
                                grid[selected] = nil
                                movingPlantIndex = nil
                                return
                            }

                            if let newPlant = plantToAdd, grid[index] == nil {
                                grid[index] = newPlant
                                plantToAdd = nil
                                return
                            }

                            if grid[index] != nil {
                                movingPlantIndex = index
                                plantToAdd = nil
                            }
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isEditing
                              ? Color(red: 0.44, green: 0.78, blue: 0.38)  // #6FC662
                              : Color(red: 0.13, green: 0.48, blue: 0.03)) // #227B08
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                )
                .animation(.default, value: grid)

                // Controls
                HStack {
                    Button("Add Plant") {
                        showAddSheet = true
                        isEditing = true
                        movingPlantIndex = nil
                    }
                    Spacer()
                    Button(isEditing ? "Exit Edit Mode" : "Edit Mode") {
                        isEditing.toggle()
                        plantToAdd = nil
                        movingPlantIndex = nil
                        showAddSheet = false
                    }
                }
                .padding(.horizontal)

                // Delete or spacer
                Group {
                    if isEditing, let index = movingPlantIndex {
                        Button("Delete Plant") {
                            grid[index] = nil
                            movingPlantIndex = nil
                        }
                        .foregroundColor(.red)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
                .padding(.top, 10)
            }
            .padding()

            // Floating modal
            if showAddSheet {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAddSheet = false
                    }

                VStack {
                    PlantPicker { plant in
                        plantToAdd = plant
                        showAddSheet = false
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(width: 250, height: 300)
                }
            }
        }
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
                .padding(.top)
                .padding(.horizontal)

            List(filtered, id: \.self) { name in
                Button(name) {
                    onSelect(Plant(name: name))
                }
            }
            .listStyle(.plain)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

