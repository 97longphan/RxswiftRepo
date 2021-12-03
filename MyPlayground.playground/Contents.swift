import UIKit
import RxSwift
import RxCocoa
let a = PublishSubject<String>()
let b = PublishSubject<String>()


//let c = Driver.combineLatest(a, b)
//    .map { a, b -> String in
//        return a.appending(b)
//    }.drive(onNext: {
//        print($0)
//    })

let aa = Observable.combineLatest(a,b)
//    .map({ pbs, b -> String in
//        return pbs.appending("hello").appending(b)
//    })
    .subscribe(onNext: {
        print($0)
    })

//let ab = Observable.merge([a, b])
//    .subscribe(onNext: {
//        print($0)
//    })



a.onNext("a onnext")

b.onNext("b onnext")



