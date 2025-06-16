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
                // Garden Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(grid.indices, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .stroke(
                                    Color.gray,
                                    style: StrokeStyle(
                                        lineWidth: 2,
                                        dash: isEditing && grid[index] == nil && (plantToAdd != nil || movingPlantIndex != nil) ? [5] : []
                                    )
                                )
                                .frame(height: 80)
                            
                            if let plant = grid[index] {
                                Text(plant.name)
                                    .foregroundColor(movingPlantIndex == index ? .gray : .primary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if isEditing && (plantToAdd != nil || movingPlantIndex != nil) {
                                Image(systemName: "plus")
                                    .foregroundColor(.gray)
                            }
                        }
                        .onTapGesture {
                            guard isEditing else { return }
                            
                            // Deselect
                            if movingPlantIndex == index {
                                movingPlantIndex = nil
                                return
                            }
                            
                            // Move
                            if let selected = movingPlantIndex {
                                if grid[index] == nil {
                                    grid[index] = grid[selected]
                                    grid[selected] = nil
                                    movingPlantIndex = nil
                                }
                                return
                            }
                            
                            // Add
                            if let newPlant = plantToAdd, grid[index] == nil {
                                grid[index] = newPlant
                                plantToAdd = nil
                                return
                            }
                            
                            // Select for move
                            if grid[index] != nil {
                                movingPlantIndex = index
                                plantToAdd = nil
                            }
                        }
                    }
                }
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
                
                // Delete button or placeholder
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
            
            // Full-screen floating modal with dismiss
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
}
