//
//  TimerController.swift
//  PowerNapTimer
//
//  Created by Matthew O'Connor on 9/24/19.
//  Copyright © 2019 Matthew O'Connor. All rights reserved.
//

import Foundation

protocol TimerDelegate: class {
    func timerSecondTick()
    func timerCompleted() //time runs out
    func timerStopped() //cancel manually
}
class TimerController {
    //SOT
    var timer: Timer?
    var timeRemaining: TimeInterval?
    var isOn: Bool {
        return timeRemaining != nil ? true : false
    }
    
    weak var delegate: TimerDelegate?
    
    func secondTick() {
        guard let timeRemaining = timeRemaining else { return }
        if timeRemaining > 0 {
            self.timeRemaining = timeRemaining - 1
            delegate?.timerSecondTick() //update label
        } else {
            timer?.invalidate() //stop counting down
            self.timeRemaining = nil
            delegate?.timerCompleted()
        }
    }
    
    func startTimer(_ time: TimeInterval) {
        if isOn == false { // !isOn
            timeRemaining = time
            DispatchQueue.main.async {
                self.secondTick()
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                    self.secondTick()
                })
            }
        }
    }
    
    func stopTimer() {
        if isOn == true {
            timeRemaining = nil
            timer?.invalidate()
            delegate?.timerStopped()
        }
    }
    
    func timeAsString() -> String {
        let timeRemaining = Int(self.timeRemaining ?? 20*60)
        let minutesLeft = timeRemaining / 60
        let secondsLeft = timeRemaining - (minutesLeft*60)
        return String(format: "%02d : %02d", arguments: [minutesLeft,secondsLeft])
    }
}
