//
//  ContentView.swift
//  Prototype Watch App
//
//  Created by Daniel Torres on 11/24/22.
//

import SwiftUI

struct ContentView: View {
    @State var isPomodoro: Bool = true
    @State var started: Bool = false
    @State var isPause: Bool = true
    @State var timeInterval: TimeInterval = .pomodoroInSeconds
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text(Formatter
                .makeTimerFormatter()
                .string(from: timeInterval)!)
            .font(.timerFont)
            .foregroundColor(.red)
            .padding([.top], 24)
            
            HStack {
                Button.init(action: stopButton) {
                    Image(systemName: "stop.fill")
                }
                
                Button.init(action: skipButton) {
                    Image(systemName: "forward.end.fill")
                }
                
                Button.init(action: playButton) {
                    if isPause {
                        Image(systemName: "play.fill")
                    } else {
                        Image(systemName: "pause.fill")
                    }
                }
            }
        }
        .onChange(of: isPomodoro, perform: { [isPomodoro] newState in
            timeInterval = newState ? TimeInterval.pomodoroInSeconds : TimeInterval.breakInSeconds
        })
        .onChange(of: isPause, perform: { [isPause] newState in
            started = true
        })
        .onChange(of: started, perform: { [started] newState in
            if newState {
                timeInterval = isPomodoro ? TimeInterval.pomodoroInSeconds : TimeInterval.breakInSeconds
            } else {
                timeInterval = isPomodoro ? TimeInterval.pomodoroInSeconds : TimeInterval.breakInSeconds
                isPause = true
            }
        })
        .onReceive(timer, perform: { time in
            if timeInterval > 0, !isPause {
                timeInterval = timeInterval - 1
            }
        })
    }
}

extension ContentView {
    func stopButton() {
        started = false
    }
    
    func skipButton() {
        isPomodoro = !isPomodoro
        started = false
    }
    
    func playButton() {
        isPause = !isPause
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Font {
    static var timerFont: Font {
        Font.custom("Digital dream Fat", size: 40)
    }
}

extension ClosedRange where Bound
== Date {
    static var pomodoroInterval: ClosedRange<Date>{
        Date.now...Date.now.adding(seconds: .pomodoroInSeconds)
    }
    
    static var breakInterval: ClosedRange<Date>{
        Date.now...Date.now.adding(seconds: .breakInSeconds)
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}

extension TimeInterval {
    static var pomodoroInSeconds: TimeInterval {
        1500
    }
    
    static var breakInSeconds: TimeInterval {
        300
    }
}

extension Formatter {
    
    static func makeTimerFormatter() -> DateComponentsFormatter {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.zeroFormattingBehavior = .pad
        dateFormatter.allowedUnits = [.minute, .second]
        
        return dateFormatter
    }
}
