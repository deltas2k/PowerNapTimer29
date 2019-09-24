//
//  TimerViewController.swift
//  PowerNapTimer
//
//  Created by Matthew O'Connor on 9/24/19.
//  Copyright © 2019 Matthew O'Connor. All rights reserved.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController {
    
    //MARK: Outlets and actions
    let myTimer = TimerController()
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer.delegate = self
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTimer()
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
            cancelNotification()
        }else {
            myTimer.startTimer(10)
            scheduleNotification()
        }
        updateViews()
    }
    func updateViews() {
        if myTimer.isOn {
            startButton.setTitle("Stop Timer", for: .normal)
        } else {
            startButton.setTitle("Start Nap", for: .normal)
        }
        updateTimerTextLabel()
    }
    func resetTimer() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            let timerLocalNotification = requests.filter({ $0.identifier == self.userNotificationIdentifier})
            guard let timerNotificationRequest = timerLocalNotification.last,
                let trigger = timerNotificationRequest.trigger as? UNCalendarNotificationTrigger,
                let fireDate = trigger.nextTriggerDate()
                else { return }
            
            self.myTimer.stopTimer()
            self.myTimer.startTimer(fireDate.timeIntervalSinceNow)
        }
    }

    func updateTimerTextLabel() {
        //take the time remaining and set the label.text appropriately
        timerLabel.text = myTimer.timeAsString()
    }
    
    // MARK: Alertcontroller
    func setUpAlertController() {
        var snoozetextfield: UITextField?
        let alert = UIAlertController(title: "Wake Up", message: "Time to wake up", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Snooze for how long..."
            textField.keyboardType = .numberPad
            snoozetextfield = textField
        }
        let snoozeAction  = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let snoozeTimeText = snoozetextfield?.text,
                let time = TimeInterval(snoozeTimeText)
                else { return }
            self.myTimer.startTimer(time)
            self.updateViews()
            self.scheduleNotification()
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            self.updateViews()
        }
        
        alert.addAction(snoozeAction)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Notificaations
    func scheduleNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Wake Up"
        notificationContent.body = "wake up please"
        guard let timeRemaining = myTimer.timeRemaining else { return }
        let fireDate = Date(timeInterval: timeRemaining, since: Date())
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
               print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    private let userNotificationIdentifier = "TimerNotification"
    
    func cancelNotification() {
        //remove all pending notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
    }
    
}

// MARK: Timer Delegate
extension TimerViewController: TimerDelegate {
    func timerSecondTick() {
        updateTimerTextLabel()
    }
    
    func timerCompleted() {
        updateViews()
        setUpAlertController()
        scheduleNotification()
    }
    
    func timerStopped() {
        updateViews()
        // fire alert controller
    }
    
    
}
