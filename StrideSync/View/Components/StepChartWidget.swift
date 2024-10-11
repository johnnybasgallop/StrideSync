import SwiftUI
import HealthKit
import Charts


struct StepChartWidget: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var selectedPeriod: TimePeriod = .month
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandLightGray)
                .frame(height: 400)
            
            VStack(alignment: .leading) {
                // Picker to select time period (week, month, year)
                Picker("Time Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                // Display the average steps for the selected period
                Text("Average")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                Text("\(averageSteps(for: selectedPeriod)) steps")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.bottom, 4)
                
                // Display the Chart with real data
                Chart(dataForSelectedPeriod()) {
                    BarMark(
                        x: .value("Label", $0.label),
                        y: .value("Steps", $0.steps)
                    )
                    .foregroundStyle(getColor(for: selectedPeriod))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .padding()
                .chartXAxis {
                    AxisMarks(values: xAxisLabels()) { value in
                        AxisValueLabel()
                    }
                }
            }
            .cornerRadius(12)
            .padding()
        }.padding(.horizontal)
    }
    
    // Calculate the average step count for the selected period
    private func averageSteps(for period: TimePeriod) -> Int {
        switch period{
        case .week:
            return viewModel.averageStepsWeek
            
        case .month:
            return viewModel.averageStepsMonth
            
        case .year:
            return viewModel.averageStepsYear
        }
        
    }
    
    // Get the appropriate data for the selected period
    private func dataForSelectedPeriod() -> [StepEntry] {
        switch selectedPeriod {
        case .week:
            return viewModel.weekData
        case .month:
            return viewModel.monthData
        case .year:
            return viewModel.yearData
        }
    }
    
    // Determine x-axis labels for the current time period
    private func xAxisLabels() -> [String] {
        switch selectedPeriod {
        case .week:
            return viewModel.weekData.map { $0.label }
        case .month:
            return viewModel.monthData.indices.filter { $0 % 7 == 0 }.map { viewModel.monthData[$0].label }
        case .year:
            return viewModel.yearData.map { $0.label }
        }
    }
    
    // Return the color for the selected period
    private func getColor(for period: TimePeriod) -> Color {
        switch period {
        case .week:
            return .brandPurple1
        case .month:
            return .brandGreen1
        case .year:
            return .brandPink1
        }
    }
}

#Preview {
    StepChartWidget().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
