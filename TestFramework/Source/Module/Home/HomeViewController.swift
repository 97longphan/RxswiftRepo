//
//  HomeViewController.swift
//  TestFramework
//
//  Created by ps1.longph on 08/12/2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    @IBAction func toListPokemon(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func toDependencyInjection(_ sender: Any) {
        let vc = UIStoryboard.init(name: "DependencyInjection", bundle: Bundle.main).instantiateViewController(withIdentifier: "DependencyInjectionViewController") as? DependencyInjectionViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    


}
