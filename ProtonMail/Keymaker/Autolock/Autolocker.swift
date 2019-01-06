//
//  Autolocker.swift
//  Keymaker - Created on 23/10/2018.
//
//
//  The MIT License
//
//  Copyright (c) 2018 Proton Technologies AG
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation

public protocol SettingsProvider {
    var lockTime: AutolockTimeout { get }
}

public class Autolocker {
    // there is no need to persist this value anywhere except memory since we can not unlock the app automatically after relaunch (except NoneProtection case)
    // by the same reason we can benefit from system uptime value instead of current Date which can be played with in Settings.app
    private var autolockCountdownStart: TimeInterval?
    private var userSettingsProvider: SettingsProvider
    
    public init(lockTimeProvider: SettingsProvider) {
        self.userSettingsProvider = lockTimeProvider
    }
    
    internal func updateAutolockCountdownStart() {
        self.autolockCountdownStart = ProcessInfo().systemUptime
    }
    
    internal func releaseCountdown() {
        self.autolockCountdownStart = nil
    }
    
    internal func shouldAutolockNow() -> Bool {
        // no countdown started - no need to lock
        guard let lastBackgroundedAt = self.autolockCountdownStart else {
            return false
        }
        
        switch self.userSettingsProvider.lockTime {
        case .always: return true
        case .never: return false
        case .minutes(let numberOfMinutes):
            return TimeInterval(numberOfMinutes * 60) < ProcessInfo().systemUptime - lastBackgroundedAt
        }
    }
}
