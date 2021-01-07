//
//  TagViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 13/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
class TagViewController: UIViewController {
    
    var tag: Tag?
    
    @IBOutlet weak var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit tag"
        messageField.text = tag?.name
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let editedName = messageField.text, !editedName.isEmpty else { return }
        tag?.name = editedName
    }
}
