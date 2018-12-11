//
//  AlarmNotificationService.swift
//  nightguard
//
//  Created by Florian Preknya on 12/10/18.
//  Copyright © 2018 private. All rights reserved.
//

import UIKit
import UserNotifications

// Alarm notification authorization, triggering & handling logic.
class AlarmNotificationService {
    
    static let shared = AlarmNotificationService()
    
    // service state
    var enabled: Bool {
        get {
            return UserDefaultsRepository.readAlarmNotificationState()
        }
        
        set(value) {
            UserDefaultsRepository.saveAlarmNotificationState(value)
            if value {
                requestAuthorization()
            }
        }
    }
    /*
     * Request authorization from user to use local notifications for alarms
     */
    func requestAuthorization(completion: ((Error?) -> Void)? = nil) {
        
        // enable local notifications (alarms in background)
        let authorizationOptions: UNAuthorizationOptions
        if #available(iOS 12.0, *) {
            authorizationOptions = [.badge, .alert, .sound, .criticalAlert]
        } else {
            authorizationOptions = [.badge, .alert, .sound]
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions) { (granted, error) in
            // Enable or disable features based on authorization.
            
            completion?(error)
        }
    }
    
    /*
     * Trigger a local notification if alarm is activated (and the app is in background).
     */
    func notifyIfAlarmActivated() {
        
        // PRECONDITIONS:
        // 1. service should be enabled
        guard enabled else {
            return
        }
        
        // 2. app should be in background
        guard UIApplication.shared.applicationState != .active else {
            return
        }
        
        // 3. alarm should be active
        let nightscoutData = NightscoutCacheService.singleton.getCurrentNightscoutData()
        guard AlarmRule.isAlarmActivated(nightscoutData, bloodValues: NightscoutCacheService.singleton.getTodaysBgData()) else {
            return
        }
        
        // trigger notification
        let content = UNMutableNotificationContent()
        let units = (UserDefaultsRepository.readUnits() == Units.mmol) ? "mmol" : "mg/dL"
        content.title = "\(nightscoutData.sgv) \(nightscoutData.bgdeltaArrow)\t\(nightscoutData.bgdeltaString) \(units)"
        //            content.body = "High BG alert"
        // TODO: content body will contain the alarm name
        if let sgv = Float(nightscoutData.sgv) {
            content.badge = NSNumber(value: sgv)
        }
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed("alarm-notification.m4a", withAudioVolume: 0.6)
        } else {
            content.sound = UNNotificationSound(named: "alarm-notification.m4a")
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "ALARM", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private init() {
    }
}
