
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = fetchWidgetData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = fetchWidgetData()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), totalSteps: 5000, distance: 1.40, flightsClimbed: 3, AverageSteps: 6789)
    }
    
    private func fetchWidgetData() -> WidgetEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.basgallop.StrideSyncApp")
        let totalSteps = sharedDefaults?.integer(forKey: "totalSteps") ?? 0
        let distance = sharedDefaults?.double(forKey: "distance") ?? 0.0
        let flightsClimbed = sharedDefaults?.integer(forKey: "flightsClimbed") ?? 0
        let averageSteps = sharedDefaults?.integer(forKey: "averageSteps") ?? 0
        
        return WidgetEntry(date: Date(), totalSteps: totalSteps, distance: distance, flightsClimbed: flightsClimbed, AverageSteps: averageSteps)
    }
}

struct WidgetEntry: TimelineEntry {
    var date: Date
    var totalSteps : Int
    var distance : Double
    var flightsClimbed: Int
    var AverageSteps: Int
}

struct StrideSyncWidgetEntryView : View {
    var entry: WidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View {
        switch widgetFamily{
        case .systemSmall:
            SmallWidget(entry: entry)
            
        case .systemMedium:
            MediumWidget(entry: entry)
            
        default:
            Text("")
        }
    }
}

struct SmallWidget : View {
    var entry : WidgetEntry
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading){
                Text("\(entry.totalSteps)")
                    .foregroundStyle(.brandCharcoal)
                    .font(.system(size: 30, weight: .bold))
                
                Text("\(String(format: "%.1f", entry.distance))km")
                    .foregroundStyle(.brandCharcoal)
                    .font(.system(size: 16, weight: .bold))
                
                HStack(spacing:5){
                    Text("\(entry.flightsClimbed)")
                        .foregroundStyle(.brandCharcoal)
                        .font(.system(size: 16, weight: .bold))
                    
                    Image(systemName: "stairs").foregroundStyle(.brandCharcoal)
                }
            }
        }
        .containerBackground(for: .widget){
            Color.brandLightGray
        }
    }
}

struct MediumWidget : View {
    var entry : WidgetEntry
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                
                Text("Current vs Average daily")
                    .foregroundStyle(.brandCharcoal)
                    .font(.system(size: 14, weight: .bold))
                
                Spacer()
                
                Text("\(String(format: "%.1f", entry.distance))km")
                    .foregroundStyle(.brandCharcoal)
                    .font(.system(size: 14, weight: .bold))
                
                HStack(spacing: 4){
                    Text("\(entry.flightsClimbed)")
                        .foregroundStyle(.brandCharcoal)
                        .font(.system(size: 14, weight: .bold))
                    
                    Image(systemName: "figure.stairs").foregroundStyle(.brandCharcoal).font(.system(size: 12))
                }.padding(.leading, 2)
            }
            
            Spacer().frame(height: 15)
            
            VStack(alignment: .leading, spacing: 5){
                HStack {
                    Text("\(entry.totalSteps.formatted())")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.brandCharcoal)
                    Text("steps")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                Rectangle()
                    .fill(.brandPink1)
                    .frame(height: 8)
                    .cornerRadius(5)
                    .frame(width: barWidth(for: entry.totalSteps))
            }
            
            VStack(alignment: .leading, spacing: 5){
                HStack {
                    Text("\(entry.AverageSteps.formatted())")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.brandCharcoal)
                    Text("steps")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                Rectangle()
                    .fill(.brandPurple1)
                    .frame(height: 8)
                    .cornerRadius(5)
                    .frame(width: barWidth(for: entry.AverageSteps))
            }.padding(.bottom, 5)
        }
        .containerBackground(for: .widget){
            Color.brandLightGray
        }
    }
    
    func barWidth(for steps: Int) -> CGFloat {
        let maxSteps = max(entry.totalSteps, entry.AverageSteps)
        let maxWidth: CGFloat = 290
        return CGFloat(steps) / CGFloat(maxSteps) * maxWidth
    }
}

@main
struct StrideSyncWidget: Widget {
    let kind: String = "StrideSyncWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StrideSyncWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Stride Sync Widget")
        .description("Widget for displaying health data")
    }
}


#Preview(as: .systemMedium) {
    StrideSyncWidget()
} timeline: {
    WidgetEntry(date: .now, totalSteps: 5000, distance: 1.40, flightsClimbed: 3, AverageSteps: 6709)
}



