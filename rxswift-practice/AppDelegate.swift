//
//  AppDelegate.swift
//  rxswift-practice
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift

func myInterval(_ interval: TimeInterval) -> Observable<Int> {
    var next = 0
    return Observable.create { observer in
        print("Subscribed")
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.scheduleRepeating(deadline: DispatchTime.now() + interval, interval: interval)

        let cancel = Disposables.create {
            print("Disposed")
            timer.cancel()
        }

        timer.setEventHandler {
            if cancel.isDisposed {
                return
            }
            observer.on(.next(next))
            next += 1
        }
        timer.resume()

        return cancel
    }
}

func testCounterLogic() {
    let counter = myInterval(0.1)

    print("Started ----")

    let subscription1 = counter
        .subscribe(onNext: { n in
            print("First \(n)")
        })

    Thread.sleep(forTimeInterval: 0.5)

    subscription1.dispose()

    let subscription2 = counter
        .subscribe(onNext: { n in
            print("Second \(n)")
        })

    Thread.sleep(forTimeInterval: 0.5)

    subscription2.dispose()

    print("Ended ----")
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        testCounterLogic()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

