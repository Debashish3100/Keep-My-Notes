//
//  TagsViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 13/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
import CoreData

class TagsViewController: UIViewController {
    
    var note: Note?
    
    private enum Segue {
        static let addTag = "AddTag"
        static let tag = "Tag"
    }
    private lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        guard let context = note?.managedObjectContext else {
            fatalError("unable to load managed object context")
        }
        let tagFetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        tagFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: tagFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    //MARK: - Outlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tags"
        setupView()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("fetching error in TagsViewController")
        }
        updateView()
    }
    //MARK: - Navitation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Segue.addTag:
            guard let destination = segue.destination as? AddTagViewController else { return }
            destination.managedObjectContext = note?.managedObjectContext
        case Segue.tag:
            guard let destination = segue.destination as? TagViewController else { return }
            guard let cell = sender as? TagsTableViewCell else { return }
            guard let  indexPath = tableView.indexPath(for: cell) else { return }
            destination.tag = fetchedResultsController.object(at: indexPath)
        default:
            fatalError("Unknown segue from TagsViewController")
        }
    }
    
    //MARK: - Helper Methods
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(sender:)))
    }
    private func setupMessageLabel() {
        messageLabel.text = "You don't have any Tags yet !"
    }
    private func setupView() {
        setupBarButtonItems()
        setupMessageLabel()
    }
    private func updateView() {
        var tagsLoaded = false
        if let tags = fetchedResultsController.fetchedObjects {
            tagsLoaded = tags.count > 0
        }
        tableView.isHidden = !tagsLoaded
        messageLabel.isHidden = tagsLoaded
    }
    // MARK: - Actions

    @objc private func add(sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.addTag, sender: self)
    }
}
extension TagsViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()

        updateView()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TagsTableViewCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }

}

extension TagsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TagsTableViewCell.id, for: indexPath) as? TagsTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        // Configure Cell
        configure(cell, at: indexPath)

        return cell
    }

    func configure(_ cell: TagsTableViewCell, at indexPath: IndexPath) {
        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)

        // Configure Cell
        cell.titleLabel.text = tag.name

        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            cell.titleLabel.textColor = .bitterSweet
        } else {
            cell.titleLabel.textColor = .black
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)

        // Delete Tag
        note?.managedObjectContext?.delete(tag)
    }

}

extension TagsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)

        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            note?.removeFromTags(tag)
        } else {
            note?.addToTags(tag)
        }
    }

}
