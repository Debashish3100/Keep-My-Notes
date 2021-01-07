//
//  AddTagViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 13/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
import CoreData

class AddTagViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add New Tag"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save(sender:)))
    }
    @objc private func save(sender: UIBarButtonItem) {
        guard let context = managedObjectContext else { return }
        guard let name = messageField.text, !name.isEmpty else {
            print("can't create category, name can't be empty")
            return
        }
        let tag = Tag(context: context)
        tag.name = name
        _ = navigationController?.popViewController(animated: true)
    }
}
