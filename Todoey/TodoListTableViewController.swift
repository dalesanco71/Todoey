//
//  ViewController.swift
//  Todoey
//
//  Created by Daniel Alesanco on 17/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController {

    var itemList = [""]
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let itemArray = defaults.array(forKey: "ItemList") as? [String] {
            itemList = itemArray
        }
    }


    //--------------------------------------------
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemList[indexPath.row]
        
        return cell
    }
    
    
    //--------------------------------------------
    // MARK: - TableView delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //--------------------------------------------
    // MARK: - Add items method
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Add new todo item"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let answer = ac.textFields![0]
            
            if !answer.text!.isBlank {
                self.itemList.append(answer.text!)
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

