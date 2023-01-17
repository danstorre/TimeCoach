//
//  LocalElapsedSeconds+ElapsedSeconds.swift
//  LifeCoach
//
//  Created by Daniel Torres on 1/16/23.
//

import Foundation

extension LocalElapsedSeconds {
    public var timeElapsed: ElapsedSeconds {
        ElapsedSeconds.init(elapsedSeconds,
                            startDate: startDate,
                            endDate: endDate)
    }
}
