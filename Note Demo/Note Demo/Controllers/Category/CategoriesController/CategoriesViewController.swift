//
//  CategoriesViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 11/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//


import UIKit
import CoreData

class CateogoriesViewController: UIViewController {
    
    private let cellID = "CategoriesCell"
    
    var note: Note?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - ViewLifeCycle
    
    private enum Segue {
        static let Cateogry = "Category"
        static let AddCategory = "AddCategory"
    }
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        guard let managedObjectContext = note?.managedObjectContext else {
            fatalError("no managedObject context")
        }
        let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController: NSFetchedResultsController<Category> = NSFetchedResultsController(fetchRequest: categoryFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Segue.Cateogry:
            guard let destination = segue.destination as? CategoryViewController, let cell = sender as? CategoryCell else { return }
            
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            
            let category = fetchedResultsController.object(at: indexPath)
            destination.category = category
            
        case Segue.AddCategory:
            guard let destination = segue.destination as? AddCategoryViewController else { return }
            destination.managedObjectContext = note?.managedObjectContext
        default:
            print("unknown segue")
        }
    }
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "Cateogries"
        setupView()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        updateView()
    }
    private func setupView() {
        setupMessageLabel()
        setupBarButtonItems()
    }
    private func setupMessageLabel() {
        // Configure Message Label
        messageLabel.text = "You don't have any categories yet."
    }

    // MARK: -

    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(sender:)))
    }

    // MARK: - Actions

    @objc private func add(sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.AddCategory, sender: self)
    }
    private func updateView() {
        var hasCategories = false
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            hasCategories = fetchedObjects.count > 0
        }
        tableView.isHidden = !hasCategories
        messageLabel.isHidden = hasCategories
    }
}

extension CateogoriesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                configure(cell, indexPath: indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath {
                tableView.deleteRows(at: [oldIndexPath], with: .fade)
            }
            if let newIndexPath = indexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }
}
extension CateogoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! CategoryCell
        configure(cell, indexPath: indexPath)
        return cell
    }
    //MARK: Cell Configuration Method
    private func configure(_ cell: CategoryCell, indexPath: IndexPath) {
        let cateogry = fetchedResultsController.object(at: indexPath)
        cell.nameLabel.text = cateogry.name
        if note?.category == cateogry {
            cell.nameLabel.textColor = .red
        } else {
            cell.nameLabel.textColor = .black
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let category = fetchedResultsController.object(at: indexPath)
        note?.managedObjectContext?.delete(category)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        note?.category = category
        _ = navigationController?.popViewController(animated: true)
    }
}
