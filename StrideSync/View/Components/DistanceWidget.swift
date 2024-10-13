import SwiftUI
import HealthKit

struct DistanceWidget: View {
    @EnvironmentObject var viewModel : HomeViewModel
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandBlue.gradient)
                .frame(width: (screenWidth - 45) / 2, height: 175)
            
            VStack(alignment: .leading){
                Text("Distance")
                    .foregroundStyle(.brandCharcoal)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(alignment: .center){
                    Text("\(String(format: "%.1f", viewModel.distance))")
                        .foregroundStyle(.brandCharcoal)
                        .font(.system(size: 70, weight: .semibold))
                    Text("km")
                }
                
                Spacer()
                
                HStack{
                    Spacer()
                    Image(systemName: "figure.walk").font(.system(size: 25))
                }
            }
            .padding()
            .frame(width: (screenWidth - 45) / 2, height: 175)
        }
    }
}

#Preview {
    DistanceWidget().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
