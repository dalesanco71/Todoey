//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by Daniel Alesanco on 17/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit
import CoreData

class TodoListTableViewController: UITableViewController {
    
    //--------------------------------------------
    // MARK: global variables definition

    var itemList = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var category : Category? {
        didSet {
            loadData()
        }
    }
    
    //--------------------------------------------
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //--------------------------------------------
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = itemList[indexPath.row]

        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    //--------------------------------------------
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = itemList[indexPath.row]
        
        tableView.cellForRow(at: indexPath)?.accessoryType = item.done ? .none : .checkmark
        
        itemList[indexPath.row].done = !itemList[indexPath.row].done
        
        self.saveData()

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // add swipe to delete to table. Data is deleted from CoreData
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            context.delete(itemList[indexPath.row])
            itemList.remove(at: indexPath.row)
            
            self.saveData()
        }
    }
    
    
    
    
    //--------------------------------------------
    // MARK: - Add items method
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Add new todo item"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = ac.textFields![0].text!
            newItem.itemCategory = self.category
            
            if !(newItem.title!.isBlank) {
                self.itemList.append(newItem)
                self.saveData()
            }
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
        
    }
    
    
    //--------------------------------------------
    // MARK: - Utility methods
    
    // Save Data Items to Core Data
    func saveData () {

        do{
            try context.save()
        } catch {
            print("error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // Load Data Items from Core Datar
    func loadData (with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        let categoryPredicate =  NSPredicate(format: "itemCategory.name MATCHES[cd] %@", category!.name!)
        
        // if there are already predicates in the request (as search predicate) we add the category predicate
        // otherwise the current predicate y only the category predicate
        if let currentPredicate = request.predicate {
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [categoryPredicate, currentPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do{
            itemList = try context.fetch(request)
        } catch {
            print("Error fetching data from CoreData \(error)")
        }
        
        self.tableView.reloadData()

    }
}

//--------------------------------------------
// MARK: - Search Bar delegate methods extension

extension TodoListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // if there is no text to search then show all results (no request predicate)
        if !(searchBar.text!.isEmpty) {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        }
                
        loadData(with: request)
        
        searchBar.resignFirstResponder()
    }
}



//--------------------------------------------
// MARK: - Utility extensions

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}

