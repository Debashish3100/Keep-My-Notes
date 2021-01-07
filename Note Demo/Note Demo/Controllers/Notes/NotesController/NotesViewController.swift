//
//  ViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 21/09/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit
import CoreData
class NotesViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backView: UIView!
    
    //MARK: - Property
    
    private let addNoteSegueID = "ToAddNoteVC"
    private let noteSegueID = "ToNoteVC"

    private var hasNotes: Bool {
        get {
            guard let noteCount = fetchedController.fetchedObjects else { return false }
            return noteCount.count > 0
        }
    }
    private var updatedAtFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter
    }
    private lazy var fetchedController: NSFetchedResultsController<Note> = {
        let noteFetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        noteFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]
        
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: noteFetchRequest, managedObjectContext: CoreDataStack.shared().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    //MARK: - Saving data
    
    @objc func saveChanges(notificaiton: Notification) {
        saveChanges()
    }
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges(notificaiton:)), name:  UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges(notificaiton:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    private func saveChanges() {
        print("save in note")
        CoreDataStack.shared().save()
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addNoteSegueID {
            guard let addNoteVC = segue.destination as? AddNoteViewController else { return }
            //addNoteVC.managedObjectContext = coreDataManager.mainManagedObjectContext
            //addNoteVC.managedObjectContext = persistantContainer.viewContext
            addNoteVC.managedObjectContext = CoreDataStack.shared().context
        }
        if segue.identifier == noteSegueID {
            guard let destination = segue.destination as? NoteViewController else { return }
            //guard let indexPath = tableView.indexPathForSelectedRow, let note = notes?[indexPath.row] else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let note = fetchedController.object(at: indexPath)
            destination.note = note
        }
    }
    
    //MARK: - ViewLifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationHandling()
        tableView.delegate = self
        tableView.dataSource = self
        title = "My Notes"
//        persistantContainer.loadPersistentStores { (_, error) in
//            if let error = error {
//                print("error in loading persistantStore : \(error.localizedDescription)")
//            } else {
//
//            }
//            self.setupView()
//            self.fetchNotes()
//            self.updateView()
//        }
        CoreDataStack.shared().loadPersistantStore {
            self.setupView()
            self.fetchNotes()
            self.updateView()
            print("loaded")
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(observeManagedObjectContextDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: coreDataManager.managedObjectContext)
    }
    
    //MARK: - Helper Methods
//    @objc func observeManagedObjectContextDidChange(_ notification: Notification) {
//        guard let userInfo = notification.userInfo else { return }
//
//        var didNotesChanged = false
//
//        // for newly added notes
//        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
//            for insert in inserts {
//                if let newNote = insert as? Note {
//                    notes?.append(newNote)
//                    didNotesChanged = true
//                }
//            }
//        }
//
//        //for deleted notes
//        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
//            for delete in deletes {
//                if let deletedNote = delete as? Note {
//                    if let index = notes?.firstIndex(of: deletedNote) {
//                        notes?.remove(at: index)
//                        didNotesChanged = true
//                    }
//                }
//            }
//        }
//
//        //for updated notes
//        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
//            for update in updates {
//                if let _ = update as? Note {
//                    didNotesChanged = true
//                }
//            }
//        }
//        if didNotesChanged {
//            notes?.sort { $0.updatedAtAsDate > $1.updatedAtAsDate }
//            tableView.reloadData()
//            setupView()
//        }
//
//    }
    private func setupView() {
        activityIndicator.stopAnimating()
        backView.isHidden = false
        updateView()
    }
    private func updateView() {
        messageLabel.isHidden = hasNotes
        tableView.isHidden = !hasNotes
    }
//    private func fetchNotes() {
//        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
//        //TODO: ADD sort descriptor
//        coreDataManager.managedObjectContext.performAndWait {
//            do {
//                notes = try fetchRequest.execute()
//                tableView.reloadData()
//
//            } catch {
//                print(error.localizedDescription)
//                fatalError("fetch Error")
//            }
//        }
//    }
    private func fetchNotes() {
        do {
            try fetchedController.performFetch()
            print(fetchedController.fetchedObjects?.count ?? -100)
        } catch {
            print("Error fetching notes with fetchedController")
            print(error.localizedDescription)
        }
    }
    private func configure(cell: NoteTableViewCell, indexPath: IndexPath) {
        let note = fetchedController.object(at: indexPath)
        cell.titleLabel.text = note.title
        cell.contentLabel.text = note.contents
        cell.updatedAtLabel.text = updatedAtFormatter.string(from: note.updatedAtAsDate)
        cell.categoryColorView.backgroundColor = note.category?.color
    }
    @IBAction func addNoteAction(_ sender: Any) {
        
    }
    

}

//MARK: - TableView Delegate & Datasource


extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return fetchedController.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return notes?.count ?? 0
        guard let sections = fetchedController.sections?[section] else { return 0}
        return sections.numberOfObjects
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //guard let note = notes?[indexPath.row] else { fatalError("no data") }
        let noteCell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.cellID) as! NoteTableViewCell
        configure(cell: noteCell, indexPath: indexPath)
        return noteCell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
//        if let note = notes?[indexPath.row] {
//            //note.managedObjectContext?.delete(note)
//            coreDataManager.managedObjectContext.delete(note)
//        }
        let note = fetchedController.object(at: indexPath)
        //coreDataManager.mainManagedObjectContext.delete(note)
        //persistantContainer.viewContext.delete(note)
        CoreDataStack.shared().context.delete(note)
    }
}

//MARK: - NSFetchedRequestController delegate
extension NotesViewController: NSFetchedResultsControllerDelegate {
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
                configure(cell: cell, indexPath: indexPath)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [oldIndexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }
}
