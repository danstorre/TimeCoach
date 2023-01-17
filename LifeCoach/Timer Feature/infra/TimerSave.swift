//
//  TimerSave.swift
//  LifeCoach
//
//  Created by Daniel Torres on 1/16/23.
//

import Foundation

public protocol TimerSave {
    func saveTime(completion: @escaping (TimeInterval) -> Void)
}
