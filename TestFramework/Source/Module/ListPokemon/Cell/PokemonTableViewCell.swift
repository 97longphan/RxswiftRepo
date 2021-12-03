//
//  PokemonTableViewCell.swift
//  TestFramework
//
//  Created by ps1.longph on 01/12/2021.
//

import UIKit

class PokemonTableViewCell: BaseTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(_ model: PokemonModel) {
        self.titleLabel.text = model.name
        if let urlImage = URL(string: model.avatar ?? "") {
            loadImage(with: urlImage, into: avaImageView)
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
