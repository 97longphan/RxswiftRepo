import UIKit
import RxSwift
import RxCocoa
let plS = PublishSubject<String>()
let plR = PublishRelay<String>()


let bhS = BehaviorSubject<String>(value: "a")
let bhR = BehaviorRelay<String>(value: "a")



let bag = DisposeBag()

plS.subscribe(onNext: {
    print("first\($0)")
}).disposed(by: bag)

plS.onNext("1")

plS.onNext("2")

plS.subscribe(onNext: {
    print("second\($0)")
}).disposed(by: bag)

plS.onNext("3")
//
////------------------------
bhS.subscribe(onNext: {
    print("first\($0)")
}).disposed(by: bag)


bhS.onNext("1")

bhS.onNext("2")

bhS.subscribe(onNext: {
    print("second\($0)")
}).disposed(by: bag)

bhS.onNext("3")

bhS.onNext("4")




//plR.subscribe(onNext: {
//    print("first\($0)")
//}).disposed(by: bag)
//
//
//
//plR.accept("1")
//
//plR.accept("2")
//
//plR.subscribe(onNext: {
//    print("second\($0)")
//}).disposed(by: bag)
//
//plR.accept("3")
//
//bhS.subscribe






