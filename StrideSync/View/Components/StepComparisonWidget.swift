import SwiftUI
import HealthKit

struct StepComparisonView: View {
    @EnvironmentObject var viewModel : HomeViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandCharcoal)
                .frame(height: 240)
            
            VStack(alignment: .leading, spacing: 15){
                Text("Current vs Average daily")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                // Current Steps
                VStack(alignment: .leading, spacing: 10){
                    HStack {
                        Text("\(viewModel.steps.formatted())")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("steps")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                    Rectangle()
                        .fill(Color.orange)
                        .frame(height: 10)
                        .cornerRadius(5)
                        .frame(width: barWidth(for: viewModel.steps))
                }
                
                VStack(alignment: .leading, spacing: 10){
                    HStack {
                        Text("\(viewModel.averageSteps.formatted())")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("steps")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                    Rectangle()
                        .fill(.brandBlue)
                        .frame(height: 10)
                        .cornerRadius(5)
                        .frame(width: barWidth(for: viewModel.averageSteps))
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.horizontal)
       
        
    }
    
    // Calculate the width of the bar based on the number of steps.
    func barWidth(for steps: Int) -> CGFloat {
        // Assuming a maximum width of 300 for the largest value.
        let maxSteps = max(viewModel.steps, viewModel.averageSteps)
        let maxWidth: CGFloat = 300
        return CGFloat(steps) / CGFloat(maxSteps) * maxWidth
    }
}

#Preview {
    StepComparisonView().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
