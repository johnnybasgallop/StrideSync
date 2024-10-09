import SwiftUI
import HealthKit

struct FlightsWidget: View {
    @EnvironmentObject var viewModel : HomeViewModel
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandGreen)
                .frame(width: (screenWidth - 45) / 2, height: 175)
            
            VStack(alignment: .leading){
                Text("Flights")
                    .foregroundStyle(.brandCharcoal)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(alignment: .center){
                    Text("\(String(viewModel.flightsClimbed))")
                        .foregroundStyle(.brandCharcoal)
                        .font(.system(size: 70, weight: .semibold))
                }
                
                Spacer()
                
                HStack{
                    Spacer()
                    Image(systemName: "figure.stairs").font(.system(size: 25))
                }
            }
            .padding()
            .frame(width: (screenWidth - 45) / 2, height: 175)
        }
    }
}

#Preview {
    FlightsWidget().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}

