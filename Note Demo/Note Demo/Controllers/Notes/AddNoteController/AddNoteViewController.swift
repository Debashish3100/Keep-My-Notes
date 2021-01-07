//
//  AddNoteViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 30/09/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class AddNoteViewController: UIViewController {
    @IBOutlet var titleField: UITextField!
    @IBOutlet var contentField: UITextView!
    var managedObjectContext: NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add New Note"
    }
    @IBAction func saveAction(_ sender: Any) {
        guard let managedObject = managedObjectContext, let title = titleField.text, let content = contentField.text else { print("Cant be empty") ; return }
        let note = Note(context: managedObject)
        note.title = title
        note.contents = content
        note.createdAt = Date()
        note.updatedAt = Date()
        navigationController?.popViewController(animated: true)
    }
}
