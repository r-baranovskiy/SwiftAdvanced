import SwiftUI

struct ContentView: View
{
    @State private var counter = 0
    
    var body: some View {
        let _ = Self._printChanges()
        
        ZStack {
            Color.random.ignoresSafeArea()
            
            VStack {
                Text("Counter: \(counter)")
                    .font(.system(size: 30))
                    .bold()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                    )
                                
                Button {
                    counter += 1
                } label: {
                    Text("Tap")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        )
                }
                .padding(.top, 50)
            }
        }
//        .onChange(of: counter) { value in
//            
//        }
//        .showGraph()
    }
}

struct NoRenderingCounterView: View
{
    @State private var counter = 0

    var body: some View {
        let _ = Self._printChanges()
        
        ZStack {
 //           Color.random.ignoresSafeArea()
            
            VStack {
                CounterView(counter: counter)
                    .equatable()
                Button {
                    counter += 1
                } label: {
                    Text("Tap")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        )
                }
                .padding(.top, 50)
            }
        }
    }
}

struct CounterView: View {
    let counter: Int
    
    var body: some View {
        Text("Counter: \(counter)")
    }
}

extension CounterView: Equatable
{
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.counter == rhs.counter
    }
}

#Preview {
    VStack {
//        ContentView()
        NoRenderingCounterView()
    }
}
