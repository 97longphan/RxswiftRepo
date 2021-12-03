import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {
    
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        setupViews()
    }
    
    func setupViews() {}
}
