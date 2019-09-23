//
//  ItemListTableViewController.swift
//  Todoey
//
//  Created by Daniel Alesanco on 17/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit
import RealmSwift

class ItemListTableViewController: UITableViewController {
    
    //--------------------------------------------
    // MARK: global variables definition

    let realm  = try! Realm()
    var itemList: Results<Item>?

    var currentCategory : Category? {
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
        
        return itemList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        if let item = itemList?[indexPath.row]{

            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        
        return cell
    }
    
    
    //--------------------------------------------
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemList?[indexPath.row] {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = item.done ? .none : .checkmark
            
            try! realm.write {
                item.done = !item.done
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // add swipe to delete to table. Data is deleted from CoreData
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            do{
                try realm.write {
                    realm.delete(itemList![indexPath.row])
                    tableView.reloadData()
                }
            } catch {
                print("error deleting item \(error)")
            }
        }
    }
    
    
    //--------------------------------------------
    // MARK: - Add items method
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Add new todo item"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let item = Item()
            item.title = ac.textFields![0].text!

            if !(item.title.isBlank) {
                do {
                    try self.realm.write {
                        self.realm.add(item)
                        self.currentCategory!.items.append(item)
                        self.tableView.reloadData()
                    }
                } catch {
                    print("error adding new item \(error)")
                }
            }
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    
    //--------------------------------------------
    // MARK: - Utility methods
    

    // Load Data Items from Core Datar
    func loadData () {

        try! realm.write {
            itemList = currentCategory?.items.sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()
        }
    }
}

//--------------------------------------------
// MARK: - Search Bar delegate methods extension

extension ItemListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        do {
            if !(searchBar.text!.isBlank) {
            
                try realm.write {
                    itemList = itemList!.filter(searchPredicate)
                }
            } else {
                
                loadData()
            }
        } catch{
                print("error searching categories \(error)")
        }
        
        tableView.reloadData()

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

