import SwiftUI
import SwiftData

struct Home: View {
    @AppStorage("username") private var username: String = ""
    /// View Properties
    @Query(sort: [.init(\Habit.createdAt, order: .reverse)], animation: .snappy) private var habits: [Habit]
    @State private var selectedHabit: Habit?
    @Namespace private var animationID
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                HeaderView()
                    .padding(.bottom, 15)
                
                ForEach(habits) { habit in
                    HabitCardView(animationID: animationID, habit: habit)
                        .onTapGesture {
                            selectedHabit = habit
                        }
                }
            }
            .padding(15)
            .overlay {
                if habits.isEmpty {
                    ContentUnavailableView("Start tracking your habits", systemImage: "checkmark.seal.fill")
                        .fixedSize(horizontal: false, vertical: true)
                        .visualEffect { content, proxy in
                            content
                                .offset(y: ((proxy.bounds(of: .scrollView)?.height ?? 0) - 50) / 2)
                        }
                }
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        /// Create Button With some nice progressive background effect
        .safeAreaInset(edge: .bottom) {
            CreateButton()
        }
        .background {
            Rectangle()
                .fill(.primary.opacity(0.05))
                .ignoresSafeArea()
                .scaleEffect(1.5)
        }
        .navigationDestination(item: $selectedHabit) { habit in
            HabitCreationView(habit: habit)
                .navigationTransition(.zoom(sourceID: habit.uniqueID, in: animationID))
        }
    }
    
    /// Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back!")
                .font(.largeTitle.bold())
            
            HStack(spacing: 0) {
                Text(username)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(", " + Date.startDateOfThisMonth.format("MMMM YY"))
                    .textScale(.secondary)
                    .foregroundStyle(.gray)
            }
            .font(.title3)
        }
        .hSpacing(.leading)
    }
    
    /// Create Button
    @ViewBuilder
    func CreateButton() -> some View {
        NavigationLink {
            HabitCreationView()
                .navigationTransition(.zoom(sourceID: "CREATEBUTTON", in: animationID))
        } label: {
            HStack(spacing: 10) {
                Text("Create Habit")
                
                Image(systemName: "plus.circle.fill")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.green.gradient, in: .capsule)
            /// Adding Zoom Transitions as well
            .matchedTransitionSource(id: "CREATEBUTTON", in: animationID)
        }
        .hSpacing(.center)
        .padding(.vertical, 10)
        /// Progressive Background Masking
        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(.linearGradient(colors: [
                            .white.opacity(0),
                            .white.opacity(0.5),
                            .white,
                            .white
                        ], startPoint: .top, endPoint: .bottom))
                }
                .ignoresSafeArea()
                .scaleEffect(3, anchor: .top)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
