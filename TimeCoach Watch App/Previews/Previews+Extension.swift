//
//  Previews+Extension.swift
//  TimeCoach Watch App
//
//  Created by Daniel Torres on 10/17/23.
//

import SwiftUI
import LifeCoachWatchOS
import LifeCoach
import Combine

struct TimerText_Previews: PreviewProvider {
    static func pomodoroTimer() -> TimerView {
        TimerView(timerViewModel: TimerViewModel(isBreak: true),
                  controlsViewModel: ControlsViewModel(),
                  toggleStrategy: ToggleStrategy(start: nil,
                                                 pause: nil,
                                                 skip: nil,
                                                 stop: nil,
                                                 isPlaying: Just(false).eraseToAnyPublisher()))
    }
    
    static var previews: some View {
        VStack {
            pomodoroTimer()
        }
    }
}

