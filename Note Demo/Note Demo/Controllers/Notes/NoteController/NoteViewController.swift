//
//  NoteViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 01/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    var note: Note?
    private enum Segue {
        static let category = "Category"
        static let tag = "Tag"
    }
    //MARK: - Navgation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Segue.category:
            guard let destination = segue.destination as? CateogoriesViewController else { return }
            destination.note = note
        case Segue.tag:
            guard let destination = segue.destination as? TagsViewController else { return }
            destination.note = note
        default:
            fatalError("Unknow segue from NoteViewController")
        }
    }
    
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Note"
        guard let _ = note else { return }
        titleField.text = note?.title
        contentField.text = note?.contents
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(notification:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: note?.managedObjectContext)
        
        updateCategoryLabel()
        updateTagLabel()
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        if (updates.filter { return $0 == note }).count > 0 {
            print("updates is true")
            updateCategoryLabel()
            updateTagLabel()
        } else {
            //let v = updates.filter { print($0) ; return $0 == note }
            print("not found")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let title = titleField.text, !title.isEmpty else { return }
        note?.title = title
        note?.updatedAt = Date()
        note?.contents = contentField.text
    }
    
    private func updateCategoryLabel() {
        categoryLabel.text = note?.category?.name ?? "No Category"
    }
    private func updateTagLabel() {
        tagLabel.text = note?.alphabetizedTagsAsString ?? "No Tags"
    }
}
