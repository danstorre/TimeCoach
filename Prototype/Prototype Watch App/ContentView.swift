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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Environment(\.scenePhase) private var scenePhase
    
    @State var lastTime: CFAbsoluteTime?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            TimelineView(PeriodicTimelineSchedule(from: Date.now, by: 1)) { context in
                switch context.cadence {
                case .seconds:
                    Text(Formatter
                        .makeTimerFormatter()
                        .string(from: timeInterval)!)
                    .font(.timerFont)
                    .foregroundColor(.red)
                    .opacity(isLuminanceReduced ? 0.75 : 1.0)
                case .minutes:
                    Text(Formatter
                        .makeMinuteTimerFormatter()
                        .string(from: timeInterval)!)
                    .font(.timerFont)
                    .foregroundColor(.red)
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
                case .live:
                    Text(Formatter
                        .makeTimerFormatter()
                        .string(from: timeInterval)!)
                    .font(.timerFont)
                    .foregroundColor(.red)
                @unknown default:
                    fatalError("*** Received an unknown cadence: \(context.cadence) ***")
                }
            }
            
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
            .opacity(isLuminanceReduced ? 0.0 : 1.0)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                if timeInterval < 0 {
                    timeInterval = 0
                    stopButton()
                }
                
                print("The app has become active.")
                break
            case .inactive:
                if let lastTime = lastTime {
                    let difference = CFAbsoluteTimeGetCurrent() - lastTime
                    
                    if !isPause {
                        timeInterval = timeInterval - difference
                    }
                    
                    self.lastTime = nil
                }
                print("The app has become inactive.")
                break
            case .background:
                lastTime = CFAbsoluteTimeGetCurrent()
                print("The app has moved to the background.")
                break
            @unknown default:
                fatalError("The app has entered an unknown state.")
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
        Group {
            ContentView()
            ContentView()
                .environment(\.isLuminanceReduced, true)
            ContentView()
                .environment(\.scenePhase, .background)
        }
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
    
    static func makeMinuteTimerFormatter() -> DateComponentsFormatter {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.zeroFormattingBehavior = .pad
        dateFormatter.allowedUnits = [.minute]
        
        return dateFormatter
    }
}
