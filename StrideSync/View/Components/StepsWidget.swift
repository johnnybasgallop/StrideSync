import SwiftUI
import HealthKit

struct StepsWidget: View {
    @EnvironmentObject var viewModel : HomeViewModel
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandPurple.gradient)
                .frame(height: 125)
            
            VStack(alignment: .leading,spacing: 10){
                Text("Step count")
                    .foregroundStyle(.brandCharcoal)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                HStack{
                    Text("\(viewModel.steps)")
                        .foregroundStyle(.brandCharcoal)
                        .font(.system(size: 60, weight: .semibold))
                    Spacer()
                    Image(systemName: "shoeprints.fill")
                        .font(.system(size: 35))
                        .foregroundStyle(.brandCharcoal)
                }
            }
            .frame(height: 125)
            .padding(.horizontal)
        }.padding(.horizontal)
    }
}

#Preview {
    StepsWidget().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
