import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit
import Alamofire
protocol PokemonUseCase {
    func getListPokemon(limit: Int, loadMore: String?) -> Single<PokemonListModel>
    func getDetailPokemon(id: String) -> Single<PokemonDetailModel>
}

class DefaultPokemonUseCase: PokemonUseCase {
    func getListPokemon(limit: Int, loadMore: String?) -> Single<PokemonListModel> {
        var loadMoreString: String? = nil
        if loadMore != "" {
            loadMoreString = loadMore
        }
        let request = ApiRouter.getListPokemon(limit: limit, loadMore: loadMoreString).urlRequest
        
        return URLSession.shared.rx.data(request: request!)
            .observeOn(MainScheduler.instance)
            .map { try JSONDecoder().decode(PokemonListModel.self, from: $0) }
            .asSingle()
    }
    
    func getDetailPokemon(id: String) -> Single<PokemonDetailModel> {
        let request = ApiRouter.getDetailPokemon(id: id).urlRequest
        
        return URLSession.shared.rx.data(request: request!)
            .observeOn(MainScheduler.instance)
            .map { try JSONDecoder().decode(PokemonDetailModel.self, from: $0) }
            .asSingle()
    }
}

enum ApiRouter: URLRequestConvertible {
    case getListPokemon(limit: Int, loadMore: String?)
    case getDetailPokemon(id: String)
    
    private var baseUrl: String {
        switch self {
        case .getDetailPokemon(let id):
            return id
        case .getListPokemon(_ , let loadMore):
            if let loadMore = loadMore, loadMore != "" {
                return loadMore
            } else {
                return "https://pokeapi.co/api/v2/"
            }
        }
    }
    
    private var path: String? {
        switch self {
        case .getListPokemon(_ , let loadMore):
            if let loadMore = loadMore, loadMore != "" {
                return nil
            } else {
                return "pokemon"
            }
        case .getDetailPokemon:
            return nil
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .getListPokemon, .getDetailPokemon:
            return .get
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .getListPokemon(let limit, let loadMore):
            if let loadMore = loadMore, loadMore != "" {
                return nil
            } else {
                return ["limit": limit]
            }
        case .getDetailPokemon:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try baseUrl.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path ?? ""))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        if let parameters = parameters {
            do {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            } catch {
                print("Encoding fail")
            }
        }
        
        return urlRequest
    }
}




