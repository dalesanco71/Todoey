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
    var dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ItemDataFile.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    
    //--------------------------------------------
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
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
                
                self.saveData()
            }
        }
        
        ac.addAction(addAction)
        
        present(ac, animated: true)
        
    }
    
    
    //--------------------------------------------
    // MARK: - Utility methods
    
    // Save Data Items to File Mnager
    func saveData () {
        
        let encoder = PropertyListEncoder()

        do{
            let data = try encoder.encode(self.itemList)
            do {
                try data.write(to: self.dataPath!)
            } catch {
                print("error writting file to dataPath")
            }
        } catch {
            print("error encoding itemlist")
        }
        self.tableView.reloadData()
    }
    
    // Load Data Items from File Manager
    func loadData () {
        
        let decoder = PropertyListDecoder()
        
        do{
            let data = try Data.init(contentsOf: self.dataPath!)
            
            do {
                self.itemList = try decoder.decode([Item].self, from: data)
            } catch {
                print("error decoding data")
            }
        } catch {
            print("error reading data file from dataPath")
        }
    }
}


//--------------------------------------------
// MARK: - Utility extensions

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}

