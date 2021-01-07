//
//  CategoryViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 11/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
class CategoryViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var colorView: UIView!
    private let segueID = "SelectColor"
    var category: Category?
    
    //MARK: - Naviagation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == segueID {
            guard let destination = segue.destination as? ColorViewController else { return }
            destination.delegate = self
            if let color = category?.color {
                print("color present : \(color.toHex!)")
                destination.color = color
            }
        }
    }
    
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Category"
        nameField.text = category?.name
        colorView.layer.cornerRadius = 5
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1.0
        colorView.backgroundColor = category?.color
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let name = nameField.text, !name.isEmpty {
            category?.name = name
        }
    }
}
extension CategoryViewController: ColorViewControllerDelegate {
    func controller(_ controller: UIViewController, didPick color: UIColor) {
        colorView.backgroundColor = color
        category?.color = color
    }
}
