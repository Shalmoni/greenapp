import SwiftUI

struct Plant: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let infoID: String
}

private let plantOptions = [
    "Wheat", "Barley", "Grape", "Fig", "Pomegranate", "Olive", "Date"
]

struct Garden: Identifiable {
    let id = UUID()
    var name: String = "New Garden"
    var rows: Int
    var columns: Int
    var grid: [Plant?]
    var movingPlantIndex: Int? = nil

    init(name: String = "New Garden", rows: Int = 3, columns: Int = 3) {
        self.name = name.isEmpty ? "New Garden" : name
        self.rows = rows
        self.columns = columns
        self.grid = Array(repeating: nil, count: rows * columns)
    }
}

struct ContentView: View {
    @State private var gardens: [Garden] = [Garden()]
    @State private var selectedGarden = 0
    @State private var isEditing = false
    @State private var showAddSheet = false
    @State private var showAddGardenSheet = false
    @State private var plantToAdd: Plant? = nil
    @State private var plantInfoToShow: Plant? = nil
    @State private var lockedDetent = PresentationDetent.fraction(0.5) //
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedGarden) {
                    ForEach(Array($gardens.enumerated()), id: \.1.id) { index, $garden in
                        GardenView(
                            garden: $garden,
                            globalEditing: $isEditing,
                            plantToAdd: $plantToAdd,
                            showAddSheet: $showAddSheet,
                            showAddGardenSheet: $showAddGardenSheet,
                            plantInfoToShow: $plantInfoToShow
                        )
                        .tag(index)
                        .padding(.horizontal, 1)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
            
            if showAddSheet {
                Color.black.opacity(0.001).ignoresSafeArea().onTapGesture {
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
            
            if showAddGardenSheet {
                Color.black.opacity(0.001).ignoresSafeArea().onTapGesture {
                    showAddGardenSheet = false
                }
                
                VStack {
                    AddGardenView { name, r, c in
                        gardens.append(Garden(name: name, rows: r, columns: c))
                        selectedGarden = gardens.count - 1
                        showAddGardenSheet = false
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(width: 250, height: 300)
                }
            }
        }
        // ✅ Attach it here — to the entire ZStack
        .sheet(item: $plantInfoToShow) { plant in
            PlantInfoCard(plant: plant)
                .presentationDetents([.fraction(0.5)], selection: $lockedDetent)
                .presentationDragIndicator(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
    }
    struct GardenView: View {
        @Binding var garden: Garden
        @Binding var globalEditing: Bool
        @Binding var plantToAdd: Plant?
        @Binding var showAddSheet: Bool
        @Binding var showAddGardenSheet: Bool
        @Binding var plantInfoToShow: Plant?
        
        private let minCellSize: CGFloat = 40
        
        var body: some View {
            GeometryReader { geometry in
                let maxGridWidth = geometry.size.width - 32
                let maxGridHeight = geometry.size.height * 0.55
                let cellWidth = maxGridWidth / CGFloat(garden.columns)
                let cellHeight = maxGridHeight / CGFloat(garden.rows)
                let cellSize = max(min(cellWidth, cellHeight), minCellSize)
                let gridWidth = CGFloat(garden.columns) * cellSize
                let gridHeight = CGFloat(garden.rows) * cellSize
                
                VStack(spacing: 10) {
                    Spacer(minLength: 40)
                    
                    // Title and Add Garden
                    HStack(spacing: 10) {
                        Spacer()
                        if globalEditing {
                            TextField("Garden Name", text: $garden.name)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(garden.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        if globalEditing {
                            Button(action: {
                                showAddGardenSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.headline)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Grid
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(globalEditing
                                  ? Color(red: 0.44, green: 0.78, blue: 0.38)
                                  : Color(red: 0.13, green: 0.48, blue: 0.03))
                            .frame(width: gridWidth + 18, height: gridHeight + 18)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: garden.columns), spacing: 0) {
                            ForEach(garden.grid.indices, id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .fill(Color(red: 0.51, green: 0.36, blue: 0.22))
                                        .frame(width: cellSize, height: cellSize)
                                        .overlay(
                                            ZStack {
                                                Rectangle().stroke(Color.black, lineWidth: 2)
                                                if globalEditing &&
                                                    garden.grid[index] == nil &&
                                                    (plantToAdd != nil || garden.movingPlantIndex != nil) {
                                                    Rectangle().stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                                }
                                            }
                                        )
                                    
                                    if let plant = garden.grid[index] {
                                        Text(plant.name)
                                            .foregroundColor(garden.movingPlantIndex == index ? .gray : .white)
                                    } else if globalEditing && (plantToAdd != nil || garden.movingPlantIndex != nil) {
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                    }
                                }
                                .onTapGesture {
                                    if globalEditing {
                                        if garden.movingPlantIndex == index {
                                            garden.movingPlantIndex = nil
                                            return
                                        }
                                        
                                        if let selected = garden.movingPlantIndex, garden.grid[index] == nil {
                                            garden.grid[index] = garden.grid[selected]
                                            garden.grid[selected] = nil
                                            garden.movingPlantIndex = nil
                                            return
                                        }
                                        
                                        if let newPlant = plantToAdd, garden.grid[index] == nil {
                                            garden.grid[index] = newPlant
                                            plantToAdd = nil
                                            return
                                        }
                                        
                                        if garden.grid[index] != nil {
                                            garden.movingPlantIndex = index
                                            plantToAdd = nil
                                        }
                                    } else {
                                        if let plant = garden.grid[index] {
                                            plantInfoToShow = plant
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: gridWidth, height: gridHeight)
                    }
                    
                    // Buttons below garden
                    HStack(spacing: 40) {
                        Button("Add Plant") {
                            showAddSheet = true
                            globalEditing = true
                            garden.movingPlantIndex = nil
                        }
                        Button(globalEditing ? "Exit Edit Mode" : "Edit Mode") {
                            globalEditing.toggle()
                            plantToAdd = nil
                            garden.movingPlantIndex = nil
                            showAddSheet = false
                        }
                    }
                    .font(.headline)
                    .padding(.top, 8)
                    
                    if globalEditing,
                       let index = garden.movingPlantIndex {
                        Button("Delete Plant") {
                            garden.grid[index] = nil
                            garden.movingPlantIndex = nil
                        }
                        .foregroundColor(.red)
                        .padding(.top, 4)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    struct AddGardenView: View {
        var onAdd: (String, Int, Int) -> Void
        @State private var name: String = ""
        @State private var rows: Int = 3
        @State private var columns: Int = 3
        
        var body: some View {
            VStack(spacing: 20) {
                TextField("Garden Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                Stepper(value: $rows, in: 1...9) {
                    HStack {
                        Image(systemName: "arrow.up.and.down")
                        Text("\(rows)")
                    }
                }
                Stepper(value: $columns, in: 1...9) {
                    HStack {
                        Image(systemName: "arrow.left.and.right")
                        Text("\(columns)")
                    }
                }
                Button("Add") {
                    onAdd(name.isEmpty ? "New Garden" : name, rows, columns)
                }
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
                    .padding(.top)
                    .padding(.horizontal)
                
                List(filtered, id: \.self) { name in
                    Button(name) {
                        let id = name.replacingOccurrences(of: " ", with: "").lowercased()
                        onSelect(Plant(name: name, infoID: id))
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    struct PlantInfoCard: View {
        let plant: Plant

        var body: some View {
            let info = PlantInfoManager.shared.info(for: plant.infoID)

            VStack(alignment: .leading, spacing: 8) {
                Text(info?.name ?? plant.name)
                    .font(.title2)
                    .bold()
                if let info = info {
                    Group {
                        Text("Scientific name: \(info.sciname)")
                        Text("Origin area: \(info.originarea)")
                        Text("Family: \(info.family)")
                        Text("Light: \(info.lightrec)")
                        Text("Temperature: \(info.temprec)")
                        Text("Water: \(info.waterrec)")
                        Text("Annual/Perennial/Biennial: \(info.apb)")
                    }
                    .font(.body)

                    Divider()

                    Group {
                        Text("Seed → Seedling: \(info.seed2sling) days")
                        Text("Seedling → Growth: \(info.sling2growth) days")
                        Text("Growth → Flower: \(info.growth2flower) days")
                        
                        Text("Flower → \(info.apb.lowercased() == "perennial" ? "Dormant" : "Death"): \(info.flower2dedo) days")
                        
                        if info.apb.lowercased() == "perennial" {
                            Text("Dormant → Growth: \(info.dedo2growth) days")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }

                Text("ID: \(info?.id ?? plant.infoID)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
