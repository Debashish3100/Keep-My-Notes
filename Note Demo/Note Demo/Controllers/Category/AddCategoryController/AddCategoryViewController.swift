//
//  AddCategoryViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 11/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    
    //MARK: - ViewLifeCycle
    var managedObjectContext: NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Category"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save(sender:)))
    }
    @objc private func save(sender: UIBarButtonItem) {
        guard let context = managedObjectContext else { return }
        guard let text = nameField.text, !text.isEmpty else {
            print("can't create category, name can't be empty")
            return
        }
        let category = Category(context: context)
        category.name = text
        _ = navigationController?.popViewController(animated: true)
    }
}
