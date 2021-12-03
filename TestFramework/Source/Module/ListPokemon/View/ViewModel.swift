import RxCocoa
import Action
import RxSwift

class ViewModel: ViewModelType {
    init(useCase: UseCase) {
        self.useCase = useCase
    }
    
    private var disposeBag = DisposeBag()
    private let useCase: UseCase
    private let listPokemon = BehaviorRelay<PokemonListModel?> (value: nil)
    private var pokemonListModelNew: [PokemonModel] = []
    private let numberOfItem = 1000
    lazy var getListPokemonAction: Action<(limit: Int, loadMore: String?), PokemonListModel> = {
        Action<(limit: Int, loadMore: String?), PokemonListModel> { [unowned self] in
            useCase.getListPokemon(limit: $0, loadMore: $1).asObservable()
        }
    }()
    
    lazy var getDetailPokemonAction: Action<String, PokemonDetailModel> = {
        Action<String, PokemonDetailModel> { [unowned self] in
            useCase.getDetailPokemon(id: $0).asObservable()
        }
    }()
    
    private func mergedObjectData(_ pokemonListModel: [PokemonModel], _ pokemonDetail: PokemonDetailModel) -> [PokemonModel] {
        pokemonListModel.forEach { pokemonModel in
            if pokemonModel.name == pokemonDetail.name {
                var pokemonModelNew = pokemonModel
                pokemonModelNew.avatar = pokemonDetail.sprites?.front_default
                pokemonListModelNew.append(pokemonModelNew)
            }
        }
        return pokemonListModelNew
    }
    
    func transform(input: Input) -> Output {
        var listPokemonModel: [PokemonModel] = []
        var loadMoreUrl: String?
        
        input.retryTrigger
            .map { [unowned self] in (numberOfItem, loadMoreUrl) }
            .bind(to: getListPokemonAction.inputs)
            .disposed(by: disposeBag)
        
        input.didLoadTrigger
            .map {[unowned self] in (numberOfItem, nil) }
            .bind(to: getListPokemonAction.inputs)
            .disposed(by: disposeBag)
        
        input.loadMoreTrigger
            .map { [unowned self] in (numberOfItem, loadMoreUrl) }
            .bind(to: getListPokemonAction.inputs)
            .disposed(by: disposeBag)
        
        input.pullToRefreshTrigger
            .do(onNext: { [unowned self] in
                listPokemonModel.removeAll()
                pokemonListModelNew.removeAll()
            })
                .map {[unowned self] in (numberOfItem, nil)}
                .bind(to: getListPokemonAction.inputs)
                .disposed(by: disposeBag)
        
        
        let listPokemon = getListPokemonAction.elements
            .do(onNext: {
                loadMoreUrl = $0.next
                if listPokemonModel.count == 0 {
                    listPokemonModel = $0.results
                } else {
                    listPokemonModel.append(contentsOf: $0.results)
                }})
                .map {
                    $0.results }
                .map {
                    $0.map { $0.url } }
                .flatMapLatest {
                    Observable.from($0) }
                .flatMap{ [unowned self] in
                    useCase.getDetailPokemon(id: $0) }
                .map { [unowned self] in
                    mergedObjectData(listPokemonModel, $0)}
        
        let search = input.searchTrigger
            .map{searchKey -> [PokemonModel] in
                if searchKey.isEmpty || searchKey == "" {
                    return listPokemonModel
                }
                return listPokemonModel.filter { ($0.name).lowercased().contains(searchKey) }
            }
        
        let isLoading = getListPokemonAction.executing
        
        let error = getListPokemonAction.underlyingError
        
//                let finalList = Driver.combineLatest(listPokemon.asDriver(onErrorJustReturn: []),
//                                                      input.searchTrigger )
//                    .map { listPokemon, searchKey -> [PokemonModel] in // get lastes of list pokemon && latest of input
//                        if searchKey.isEmpty || searchKey == "" {
//                            return listPokemon
//                        }
//                        return listPokemon.filter { ($0.name).lowercased().contains(searchKey) }
//                    }
        
        return Output(loadListPokemon: Driver.merge(listPokemon.asDriver(onErrorJustReturn: []), search), isLoading: isLoading, error: error)
    }
    
    
}
extension ViewModel {
    struct Input {
        let didLoadTrigger: Observable<Void>
        let searchTrigger: Driver<String>
        let loadMoreTrigger: Observable<Void>
        let pullToRefreshTrigger: Observable<Void>
        let retryTrigger: Observable<Void>
    }
    
    struct Output {
        let loadListPokemon: Driver<[PokemonModel]>
        let isLoading: Observable<Bool>
        let error: Observable<Error>
    }
}
