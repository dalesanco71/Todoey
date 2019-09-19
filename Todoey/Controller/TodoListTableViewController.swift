//
//  ViewController.swift
//  Todoey
//
//  Created by Daniel Alesanco on 17/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController {
    
    var itemList = [Item]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item1 = Item()
        item1.title = "hola"
        itemList = [item1]
        
        let item2 = Item()
        item2.title = "qué tal estás?"
        itemList.append(item2)
        
        let item3 = Item()
        item3.title = "yo estoy bien"
        itemList.append(item3)
        
        defaults.removeObject(forKey: "ItemList")
        defaults.set([item1.title,item1.done], forKey: "ItemList")
        defaults.set([item2.title,item2.done], forKey: "ItemList")
        defaults.set([item3.title,item3.done], forKey: "ItemList")
        
        if let itemArray = defaults.array(forKey: "ItemList")  {
            print("hay items en default")
            print(itemArray)
            
        } else {
            print("No hay items en default")
        }
        
    }
    
    
    //--------------------------------------------
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemList[indexPath.row].title
        
        return cell
    }
    
    
    //--------------------------------------------
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = itemList[indexPath.row]
        
        tableView.cellForRow(at: indexPath)?.accessoryType = item.done ? .none : .checkmark
        
        itemList[indexPath.row].done = !itemList[indexPath.row].done
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //--------------------------------------------
    // MARK: - Add items method
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Add new todo item"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newItem = Item()
            newItem.title = ac.textFields![0].text!
            
            if !(newItem.title.isBlank) {
                self.itemList.append(newItem)
                self.defaults.set(self.itemList, forKey: "ItemList")
            }
            
            self.tableView.reloadData()
            
        }
        
        ac.addAction(addAction)
        
        present(ac, animated: true)
        
    }
}


//--------------------------------------------
// MARK: - Utility extensions

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}

