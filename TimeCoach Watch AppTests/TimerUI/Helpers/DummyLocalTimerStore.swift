//
//  DummyLocalTimerStore.swift
//  TimeCoach Watch AppTests
//
//  Created by Daniel Torres on 8/7/23.
//

import Foundation
import LifeCoach

struct DummyLocalTimerStore: LocalTimerStore {
    func retrieve() throws -> LifeCoach.LocalTimerState? { nil }
    
    func deleteState() throws {}
    
    func insert(state: LifeCoach.LocalTimerState) throws {}
}

