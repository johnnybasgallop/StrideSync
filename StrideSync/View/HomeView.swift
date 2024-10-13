import SwiftUI
import HealthKit

var screenWidth = UIScreen.main.bounds.width
var screenHeight = UIScreen.main.bounds.height

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View{
        VStack(spacing: 0){
            HStack(alignment:.center){
                Text("StrideSync")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .offset(y:-5)
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            
            List {
                VStack(spacing: 10) {
                    StepsWidget().environmentObject(viewModel)
                    
                    HStack(spacing: 10) {
                        DistanceWidget().environmentObject(viewModel)
                        FlightsWidget().environmentObject(viewModel)
                    }
                    .padding(.horizontal)
                    
                    StepComparisonView().environmentObject(viewModel)
                    
                    StepChartWidget().environmentObject(viewModel)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .frame(width: screenWidth)
            .scrollContentBackground(.hidden)
            
            .refreshable {
                viewModel.fetchAllData()
            }
            .onAppear{
                viewModel.fetchAllData()
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
