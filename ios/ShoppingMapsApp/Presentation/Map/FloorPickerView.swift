import SwiftUI

public struct FloorPickerView: View {
    @Bindable var viewModel: MallMapViewModel

    public var body: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.sortedFloors) { floor in
                floorButton(for: floor)
            }
        }
        .padding(6)
        .background(
            Color(uiColor: .systemBackground).opacity(0.85)
        )
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    @ViewBuilder
    private func floorButton(for floor: FloorLevel) -> some View {
        let isSelected = (viewModel.selectedFloor?.id == floor.id)
        let isUserFloor = (viewModel.userFloorCode == floor.shortCode)

        Button {
            viewModel.selectFloor(floor)
        } label: {
            ZStack(alignment: .topTrailing) {
                Text(floor.shortCode)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .frame(width: 44, height: 44)
                    .background(buttonBackground(isSelected: isSelected))
                    .clipShape(.rect(cornerRadius: 14))
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.35) : Color.black.opacity(0.06),
                        radius: isSelected ? 6 : 2,
                        y: isSelected ? 3 : 1
                    )

                if isUserFloor {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .offset(x: -3, y: 3)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: viewModel.selectedFloor?.id)
    }

    private func buttonBackground(isSelected: Bool) -> Color {
        isSelected ? Color.blue : Color(uiColor: .secondarySystemBackground)
    }
}


