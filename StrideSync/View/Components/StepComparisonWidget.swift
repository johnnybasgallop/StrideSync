import SwiftUI
import HealthKit

struct StepComparisonView: View {
    @EnvironmentObject var viewModel : HomeViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandCharcoal.gradient)
                .frame(height: 240)
            
            VStack(alignment: .leading, spacing: 15){
                Text("Current vs Average daily")
                    .foregroundStyle(.white)
                    .font(.callout)
                    .fontWeight(.semibold)
                
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
                }.padding(.leading, 5)
                
                VStack(alignment: .leading, spacing: 10){
                    HStack {
                        Text("\(viewModel.averageStepsMonth.formatted())")
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
                        .frame(width: barWidth(for: viewModel.averageStepsMonth))
                }.padding(.leading, 5)
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.horizontal)
        
        
    }
    
    func barWidth(for steps: Int) -> CGFloat {
        let maxSteps = max(viewModel.steps, viewModel.averageStepsMonth)
        let maxWidth: CGFloat = 300
        return CGFloat(steps) / CGFloat(maxSteps) * maxWidth
    }
}

#Preview {
    StepComparisonView().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
