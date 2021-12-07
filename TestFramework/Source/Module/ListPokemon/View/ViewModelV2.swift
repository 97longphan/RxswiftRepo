import RxCocoa
import Action
import RxSwift

class ViewModelV2: ViewModelType {
    init(useCase: UseCase) {
        self.useCase = useCase
    }
    
    private var disposeBag = DisposeBag()
    private let useCase: UseCase
    private let listPokemon = BehaviorRelay<PokemonListModel?> (value: nil)
    private var pokemonListModelNew: [PokemonModel] = []
    private let numberOfItem = 3
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
    
    private func transformToGetDetail (_ input: [PokemonModel], listPokemonModel: [PokemonModel]) -> Observable<[PokemonModel]> {
        let test = input
        .map { $0.url }
        
        let test2 = Observable.from(test)
        .flatMap { [unowned self] in
            useCase.getDetailPokemon(id: $0) }
        .map { [unowned self] in
            mergedObjectData(listPokemonModel, $0)}
        
        return test2
    }
    
    func transform(input: Input) -> Output {
        var listPokemonModel: [PokemonModel] = []
        var loadMoreUrl: String = ""
        
        let firstLoadData = input.didLoadTrigger
            .merge(with: input.pullToRefreshTrigger)
            .do(onNext: {
                listPokemonModel.removeAll()
                self.pokemonListModelNew.removeAll()
            })
                .map { [unowned self] in (numberOfItem, "") }
                
        let loadMoreData = input.loadMoreTrigger
                .map { [unowned self] in (numberOfItem, loadMoreUrl) }
                

        let listPokemon = firstLoadData.merge(with: loadMoreData)
            .flatMapLatest { [unowned self] in
                useCase.getListPokemon(limit: $0.0, loadMore: $0.1) }
            .do(onNext: {
                loadMoreUrl = $0.next ?? ""
                listPokemonModel.append(contentsOf: $0.results)
            })
            .map { $0.results }
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
        
        
        
        
        return Output(loadListPokemon: Driver.merge(listPokemon.asDriver(onErrorJustReturn: []), search))
    }
    
    
}
extension ViewModelV2 {
    struct Input {
        let didLoadTrigger: Observable<Void>
        let searchTrigger: Driver<String>
        let loadMoreTrigger: Observable<Void>
        let pullToRefreshTrigger: Observable<Void>
        let retryTrigger: Observable<Void>
    }
    
    struct Output {
        let loadListPokemon: Driver<[PokemonModel]>
//        let isLoading: Observable<Bool>
//        let error: Observable<Error>
    }
}
