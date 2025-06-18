import SwiftUI

struct Plant: Identifiable, Hashable {
  let id = UUID()
  let name: String
}

private let plantOptions = [
  "Wheat", "Barley", "Grape", "Fig", "Pomegranate", "Olive", "Date",
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
  @State private var isEditing = false
  @State private var showAddSheet = false
  @State private var showAddGardenSheet = false
  @State private var plantToAdd: Plant? = nil

  var body: some View {
    ZStack {
      ScrollView {
        VStack(spacing: 40) {
          ForEach($gardens) { $garden in
            GardenView(
              garden: $garden,
              globalEditing: $isEditing,
              plantToAdd: $plantToAdd,
              showAddSheet: $showAddSheet
            )
          }

          if isEditing {
            Button(action: { showAddGardenSheet = true }) {
              Label("Add Garden", systemImage: "plus")
            }
          }
        }
        .padding()
      }

      if showAddSheet {
        Color.black.opacity(0.001)
          .ignoresSafeArea()
          .onTapGesture { showAddSheet = false }

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
        Color.black.opacity(0.001)
          .ignoresSafeArea()
          .onTapGesture { showAddGardenSheet = false }

        VStack {
          AddGardenView { name, r, c in
            gardens.append(Garden(name: name, rows: r, columns: c))
            showAddGardenSheet = false
          }
          .background(Color.white)
          .cornerRadius(12)
          .shadow(radius: 10)
          .frame(width: 250, height: 300)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(isEditing ? "Done" : "Edit") { isEditing.toggle() }
      }

    }
  }
}

struct GardenView: View {
  @Binding var garden: Garden
  @Binding var globalEditing: Bool
  @Binding var plantToAdd: Plant?
  @Binding var showAddSheet: Bool

  @State private var selectedPlant: Plant? = nil

  private let containerSize: CGFloat = 272
  private var cellSize: CGFloat {
    let w = (containerSize - CGFloat(garden.columns - 1) * 16) / CGFloat(garden.columns)
    let h = (containerSize - CGFloat(garden.rows - 1) * 16) / CGFloat(garden.rows)
    return min(w, h)
  }

  var body: some View {
    ZStack {
      VStack(spacing: 10) {
        HStack {
          if globalEditing {
            TextField("Garden Name", text: $garden.name)
              .textFieldStyle(.roundedBorder)
          } else {
            Text(garden.name)
              .font(.headline)
          }
          Spacer()
        }
        .padding(.horizontal)

        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: garden.columns),
          spacing: 16
        ) {
          ForEach(garden.grid.indices, id: \.self) { index in
            ZStack {
              Rectangle()
                .fill(Color(red: 0.51, green: 0.36, blue: 0.22))
                .frame(height: cellSize)
                .overlay(
                  ZStack {
                    Rectangle()
                      .stroke(Color.black, lineWidth: 2)
                    if globalEditing && garden.grid[index] == nil
                      && (plantToAdd != nil || garden.movingPlantIndex != nil)
                    {
                      Rectangle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                  }
                )

              if let plant = garden.grid[index] {
                Text(plant.name)
                  .foregroundColor(garden.movingPlantIndex == index ? .gray : .white)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
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
              } else if let plant = garden.grid[index] {
                selectedPlant = plant
              }
            }
          }
        }
        .frame(width: containerSize, height: containerSize)
        .padding(10)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(
              globalEditing
                ? Color(red: 0.44, green: 0.78, blue: 0.38)
                : Color(red: 0.13, green: 0.48, blue: 0.03))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.black, lineWidth: 2)
        )
        .animation(.default, value: garden.grid)

        HStack {
          Button("Add Plant") {
            showAddSheet = true
            globalEditing = true
            garden.movingPlantIndex = nil
          }
          Spacer()
          Button(globalEditing ? "Exit Edit Mode" : "Edit Mode") {
            globalEditing.toggle()
            plantToAdd = nil
            garden.movingPlantIndex = nil
            showAddSheet = false
          }
        }
        .padding(.horizontal)

        Group {
          if globalEditing, let index = garden.movingPlantIndex {
            Button("Delete Plant") {
              garden.grid[index] = nil
              garden.movingPlantIndex = nil
            }
            .foregroundColor(.red)
          } else {
            Color.clear.frame(height: 44)
          }
        }
        .padding(.top, 10)
      }

      if let plant = selectedPlant {
        Color.black.opacity(0.001)
          .ignoresSafeArea()
          .onTapGesture { selectedPlant = nil }

        PlantInfoCard(
          plant: plant,
          description: PlantInfoManager.shared.description(for: plant.name),
          onClose: { selectedPlant = nil }

        )
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
