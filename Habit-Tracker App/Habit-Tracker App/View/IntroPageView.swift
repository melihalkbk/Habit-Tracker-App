import SwiftUI

struct IntroPageView: View {
    /// View Properties
    @State private var selectedItem: IntroPageItem = staticIntroItems.first!
    @State private var introItems: [IntroPageItem] = staticIntroItems
    @State private var activeIndex: Int = 0
    @State private var askUsername: Bool = false
    @AppStorage("username") private var username: String = ""
    @AppStorage("isIntroCompleted") private var isIntroCompleted: Bool = false
    var body: some View {
        /// Now Let's Start Building the actual Intro Page UI
        VStack(spacing: 0) {
            /// Back Button
            Button {
                updateItem(isForward: false)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(.green.gradient)
                    .contentShape(.rect)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            /// Only Visible from second item
            .opacity(selectedItem.id != introItems.first?.id ? 1 : 0)
            
            ZStack {
                /// Animated Icons
                ForEach(introItems) { item in
                    AnimatedIconView(item)
                }
            }
            .frame(height: 250)
            .frame(maxHeight: .infinity)
            
            VStack(spacing: 6) {
                /// Progress Indicator View
                HStack(spacing: 4) {
                    ForEach(introItems) { item in
                        Capsule()
                            .fill((selectedItem.id == item.id ? Color.green : .gray).gradient)
                            .frame(width: selectedItem.id == item.id ? 25 : 4, height: 4)
                    }
                }
                .padding(.bottom, 15)
                
                Text(selectedItem.title)
                    .font(.title.bold())
                    .contentTransition(.numericText())
                
                /// YOUR CUSTOM DESCRIPTION HERE
                Text(selectedItem.description)
                    .contentTransition(.numericText())
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
                /// Next/Continue Button
                Button {
                    if selectedItem.id == introItems.last?.id {
                        /// Continue Button Pressed
                        askUsername.toggle()
                    }
                    
                    updateItem(isForward: true)
                } label: {
                    Text(selectedItem.id == introItems.last?.id ? "Continue" : "Next")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .frame(width: 250)
                        .padding(.vertical, 12)
                        .background(.green.gradient, in: .capsule)
                }
                .padding(.top, 25)
            }
            .multilineTextAlignment(.center)
            .frame(width: 300)
            .frame(maxHeight: .infinity)
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .overlay {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(.black.opacity(askUsername ? 0.3 : 0))
                    .ignoresSafeArea()
                    .onTapGesture {
                        askUsername = false
                    }
                
                if askUsername {
                    UserNameView()
                        .transition(.move(edge: .bottom).combined(with: .offset(y: 100)))
                }
            }
            .animation(.snappy, value: askUsername)
        }
    }
    
    @ViewBuilder
    func AnimatedIconView(_ item: IntroPageItem) -> some View {
        let isSelected = selectedItem.id == item.id
        
        Image(systemName: item.image)
            .font(.system(size: 80))
            .foregroundStyle(.white.shadow(.drop(radius: 10)))
            .blendMode(.overlay)
            .frame(width: 120, height: 120)
            .background(.green.gradient, in: .rect(cornerRadius: 32))
            .background {
                RoundedRectangle(cornerRadius: 35)
                    .fill(.background)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: 1, y: 1)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: -1, y: -1)
                    .padding(-3)
                    .opacity(selectedItem.id == item.id ? 1 : 0)
            }
            /// Resetting Rotation
            .rotationEffect(.init(degrees: -item.rotation))
            .scaleEffect(isSelected ? 1.1 : item.scale, anchor: item.anchor)
            .offset(x: item.offset)
            .rotationEffect(.init(degrees: item.rotation))
            /// Placing active icon at the top
            .zIndex(isSelected ? 2 : item.zindex)
    }
    
    /// User Name View
    @ViewBuilder
    func UserNameView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Let's Start With Your Name")
                .font(.caption)
                .foregroundStyle(.gray)
            
            TextField("Justine Ezarik", text: $username)
                .applyPaddedBackground(10, hPadding: 15, vPadding: 12)
                .opacityShadow(.black, opacity: 0.1, radius: 5)
            
            Button {
                isIntroCompleted = true
            } label: {
                Text("Start Tracking Your Habits")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.green.gradient, in: .rect(cornerRadius: 10))
            }
            .disableWithOpacity(username.isEmpty)
            .padding(.top, 10)
        }
        .applyPaddedBackground(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    /// Let's shift active icon to the center when continue or back button is pressed
    func updateItem(isForward: Bool) {
        /// Now let's implement backwards interaction as well
        guard isForward ? activeIndex != introItems.count - 1 : activeIndex != 0 else {
            return
        }
        
        var fromIndex: Int
        var extraOffset: CGFloat
        /// To Index
        if isForward {
            activeIndex += 1
        } else {
            activeIndex -= 1
        }
        /// From Index
        if isForward {
            fromIndex = activeIndex - 1
            extraOffset = introItems[activeIndex].extraOffset
        } else {
            extraOffset = introItems[activeIndex].extraOffset
            fromIndex = activeIndex + 1
        }
        
        /// Resetting ZIndex
        for index in introItems.indices {
            introItems[index].zindex = 0
        }
        
        /// Swift 6 Error
        Task { [fromIndex, extraOffset] in
            /// Shifting from and to icon locations
            withAnimation(.bouncy(duration: 1)) {
                introItems[fromIndex].scale = introItems[activeIndex].scale
                introItems[fromIndex].rotation = introItems[activeIndex].rotation
                introItems[fromIndex].anchor = introItems[activeIndex].anchor
                introItems[fromIndex].offset = introItems[activeIndex].offset
                /// Temporary Adjustment
                introItems[activeIndex].offset = extraOffset
                /// The moment selected item is updated, it pushes the from card all the way to the back in terms of the zIndex
                /// To solve this we can make use of Zindex property to just place the from card below the to card
                /// EG: To card Postion: 2
                /// From Card Postion: 1
                /// Others 0
                introItems[fromIndex].zindex = 1
            }
            
            try? await Task.sleep(for: .seconds(0.1))
            
            withAnimation(.bouncy(duration: 0.9)) {
                /// To location is always at the center
                introItems[activeIndex].scale = 1
                introItems[activeIndex].rotation = .zero
                introItems[activeIndex].anchor = .center
                introItems[activeIndex].offset = .zero
                
                /// Updating Selected Item
                selectedItem = introItems[activeIndex]
            }
        }
    }
}

#Preview {
    IntroPageView()
}
