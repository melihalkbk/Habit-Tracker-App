import SwiftUI

struct HabitCalendarView: View {
    var isDemo: Bool = false
    var createdAt: Date
    var frequncies: [Frequency]
    var completedDates: [TimeInterval]
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 12) {
            if !isDemo {
                ForEach(Frequency.allCases, id: \.rawValue) { frequency in
                    Text(frequency.rawValue.prefix(3))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            /// We need to determine the start date offset of the month so that it aligns with the actual weekday. Currently, it consistently begins on Sunday
            ForEach(0..<Date.startOffsetOfThisMonth, id: \.self) { _ in
                Circle()
                    .fill(.clear)
                    .frame(height: 30)
                    .hSpacing(.center)
            }
            
            /// This Months Dates
            ForEach(Date.datesInThisMonth, id: \.self) { date in
                let day = date.format("dd")
                
                Text(day)
                    .font(.caption)
                    .frame(height: 30)
                    .hSpacing(.center)
                    .background {
                        let isHabitCompleted = completedDates.contains {
                            $0 == date.timeIntervalSince1970
                        }
                        
                        /// The habit must be started from its creation date, and any previous matching dates need to be omitted
                        let isHabitDay = frequncies.contains {
                            $0.rawValue == date.weekDay
                        } && date.startOfDay >= createdAt.startOfDay
                        
                        let isFutureHabits = date.startOfDay > Date()
                        
                        if isHabitCompleted && isHabitDay && !isDemo {
                            Circle()
                                .fill(.green.tertiary)
                        } else if isHabitDay && !isFutureHabits && !isDemo {
                            Circle()
                                .fill((date.isToday ? Color.yellow : Color.red).tertiary)
                        } else {
                            if isHabitDay {
                                Circle()
                                    .fill(.fill)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    HabitCalendarView(createdAt: .now, frequncies: [.sunday, .wednesday, .saturday], completedDates: [])
}
