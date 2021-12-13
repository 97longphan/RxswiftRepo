//
//  ViewControllerTest.swift
//  TestFrameworkTests
//
//  Created by ps1.longph on 13/12/2021.
//
@testable import TestFramework
import XCTest
import RxCocoa
import RxSwift
import RxBlocking

class PokemonUseCaseMock: PokemonUseCase {
    var getListPokemonMock = Single<PokemonListModel>.never()
    func getListPokemon(limit: Int, loadMore: String?) -> Single<PokemonListModel> {
        getListPokemonMock
    }
    
    var getDetailPokemonMock = Single<PokemonDetailModel>.never()
    func getDetailPokemon(id: String) -> Single<PokemonDetailModel> {
        getDetailPokemonMock
    }
    
    
}
class ListPokemonTest: XCTestCase {
    private var viewModel: ViewModel!
    private var useCase: PokemonUseCaseMock!
    private var input: ViewModel.Input!
    private var output: ViewModel.Output!
    private var disposeBag: DisposeBag!
    //trigger
    private let didLoadTrigger = PublishSubject<Void>()
    private let searchTrigger = PublishSubject<String>()
    private let loadMoreTrigger = PublishSubject<Void>()
    private let pullToRefreshTrigger = PublishSubject<Void>()
    private let retryTrigger = PublishSubject<Void>()
    
    override func setUp() {
        useCase = PokemonUseCaseMock()
        viewModel = ViewModel(useCase: useCase)
        input = ViewModel.Input(didLoadTrigger: didLoadTrigger, searchTrigger: searchTrigger.asDriverOnErrorJustComplete(), loadMoreTrigger: loadMoreTrigger, pullToRefreshTrigger: pullToRefreshTrigger, retryTrigger: retryTrigger)
        disposeBag = DisposeBag()
    }
    
    func test_transformNoThrowError() throws {
        XCTAssertNoThrow(viewModel.transform(input: input))
    }
    
    func mockError<T>() -> Single<T> {
        Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.asyncInstance).flatMap { _ -> Observable<T> in
            throw URLError(.cancelled)
        }.asSingle()
    }
    
    func test_loadList() throws {
        let spy = BehaviorRelay<[PokemonModel]?>(value: nil)
        let output = viewModel.transform(input: input)
        output.loadListPokemon.asObservable().bind(to: spy).disposed(by: disposeBag)
        didLoadTrigger.onNext(())
        searchTrigger.onNext((""))
        let values = try spy.filterNil().first().toBlocking().toArray()
        XCTAssertFalse(values.isEmpty)
    }
    
    func test_isLoading() throws {
        let spy = BehaviorRelay<Bool?>(value: nil)
        let output = viewModel.transform(input: input)
        output.isLoading.bind(to: spy).disposed(by: disposeBag)
        let values = try spy.filterNil().first().toBlocking().toArray()
        XCTAssertFalse(values.isEmpty)
    }
    
    func test_isError() throws {
        useCase.getListPokemonMock = mockError()
        let spy = BehaviorRelay<Error?>(value: nil)
        let output = viewModel.transform(input: input)
        output.error.bind(to: spy).disposed(by: disposeBag)
        didLoadTrigger.onNext(())
        searchTrigger.onNext((""))
        let values = try spy.filterNil().first().toBlocking().toArray()
        XCTAssertFalse(values.isEmpty)
    }
    
    override func setUpWithError() throws {
        //
    }

    override func tearDownWithError() throws {
        //
    }

}
