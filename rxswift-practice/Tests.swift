//
//  Tests.swift
//  rxswift-practice
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import RxSwift

func myInterval(_ interval: TimeInterval) -> Observable<Int> {
    return Observable.create { observer in
        print("Subscribed")
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: DispatchTime.now() + interval, repeating: interval)
        //        timer.scheduleRepeating(deadline: DispatchTime.now() + interval, interval: interval)

        let cancel = Disposables.create {
            print("Disposed")
            timer.cancel()
        }

        var next = 0
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

enum HTTPError: Error {
    case nonHttpResponse
}

extension Reactive where Base: URLSession {
    public func response(urlString: String) -> Observable<Data> {
        return Observable.create { observer in
            let task = self.base.dataTask(
                with: URLRequest(url: URL(string: urlString)!)
            ) { (data, response, error) in
                guard let data = data else {
                    return
                }
                observer.onNext(data)
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

func generateRandomIntAfterDelay() -> Observable<Int> {
    return Observable.create { observer in
        print("Processing request...")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("Generating random int...")
            observer.onNext(Int.random(in: 0 ..< 10))
            observer.onCompleted()
        }
        return Disposables.create()
    }
}

enum Tests {
    static func testGeneration() {
        let observable = generateRandomIntAfterDelay()
        observable.subscribe(onNext: { randInt in
            print("1: Got \(randInt)")
        })
        observable.subscribe(onNext: { randInt in
            print("2: Got \(randInt)")
        })
    }

    static func testTwoRequests() {
        let observable = URLSession.shared.rx.response(urlString: "https://placekitten.com/200/300")
        let once = observable.publish()
        once.subscribe(onNext: { data in
            print("Got the data!")
        })
        once.subscribe(onNext: { data in
            print("Data second time")
        })
        once.connect()
    }

    static func testCounterLogic() {
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
}
