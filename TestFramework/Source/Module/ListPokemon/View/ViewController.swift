import UIKit
import RxSwift
import RxCocoa
import RxSwift
import ESPullToRefresh
import Nuke
import RxGesture
import Resolver

class ViewController: UIViewController, Resolving {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    private let viewModel: ViewModel = ViewModel(useCase: UseCase())
//    private let viewModel: ViewModelV2 = ViewModelV2(useCase: UseCase())
    private let loadMoreTrigger = PublishSubject<Void>()
    private let pullToRefreshTrigger = PublishSubject<Void>()
    private let retryTrigger = PublishSubject<Void>()
    private let disposebag = DisposeBag()
    private var errorView: ErrorView = ErrorView()
    @Injected var testInjectionModel: TestInjectionModel

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.setupView()
        self.setupTableView()
        self.setupErrorView()
        print("test resolver")
        print(testInjectionModel.age)
    }
    
    private func setupTableView() {
        tableView.registerNibForCell(PokemonTableViewCell.self)
        tableView.rowHeight = 80
        tableView.es.addInfiniteScrolling { [unowned self] in
            loadMoreTrigger.onNext(())
        }
        tableView.es.addPullToRefresh { [unowned self] in
            pullToRefreshTrigger.onNext(())
        }
    }
    
    private func setupErrorView() {
        errorView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
        errorView.errorImageView
            .rx
            .tapGesture()
            .when(.recognized)
            .mapToVoid()
            .do(onNext: { [unowned self] in
                self.isShowErrorView(false)
            })
            .bind(to: retryTrigger)
            .disposed(by: disposebag)
        
        self.view.addSubview(errorView)
        self.errorView.isHidden = true
    }
    
    private func isShowErrorView(_ isShow: Bool) {
        self.errorView.isHidden = !isShow
    }
    
    private func setupView() {
        self.indicator.hidesWhenStopped = true
        self.indicator.style = UIActivityIndicatorView.Style.large
    }
    
    private func showIndicator(_ isShow: Bool) {
        if isShow {
            self.indicator.startAnimating()
        } else {
            self.indicator.stopAnimating()
        }
    }
    
    private func bindViewModel() {
//        let input = ViewModelV2.Input(didLoadTrigger: rx.viewWillAppear.take(1),
//                                      searchTrigger: searchTextField.rx.text.orEmpty.asDriver(),
//                                      loadMoreTrigger: loadMoreTrigger,
//                                      pullToRefreshTrigger: pullToRefreshTrigger,
//                                      retryTrigger: retryTrigger)
        
        let input = ViewModel.Input(didLoadTrigger: rx.viewWillAppear.take(1),
                                    searchTrigger: searchTextField.rx.text.orEmpty.asDriver(),
                                    loadMoreTrigger: loadMoreTrigger,
                                    pullToRefreshTrigger: pullToRefreshTrigger,
                                    retryTrigger: retryTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.loadListPokemon
            .drive(tableView.rx.items(cellIdentifier: "PokemonTableViewCell",
                                      cellType: PokemonTableViewCell.self)) {[weak self] _, item, cell in
                self?.isShowErrorView(false)
                self?.tableView.es.stopLoadingMore()
                self?.tableView.es.stopPullToRefresh()
                cell.setup(item)
            }
            .disposed(by: disposebag)
        
        output.isLoading
            .subscribe(onNext: { [unowned self] in
                showIndicator($0)
            })
            .disposed(by: disposebag)
        
        output.error
            .subscribe(onNext: { [unowned self] _ in
                isShowErrorView(true)
            })
            .disposed(by: disposebag)
        
    }
}
