//
//  CategoriesTableViewController.swift
//  Todoey
//
//  Created by Daniel Alesanco on 21/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {

    //--------------------------------------------
    // MARK: global variables definition
    
    var categoryList = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //--------------------------------------------
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()

    }

    //--------------------------------------------
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categoryList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryList[indexPath.row]

        cell.textLabel?.text = category.name
        
        return cell
    }
  
    //--------------------------------------------
    // MARK: - TableView delegate methods
    
  
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // add swipe to delete to table. Data is deleted from CoreData
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            context.delete(categoryList[indexPath.row])
            categoryList.remove(at: indexPath.row)
            
            self.saveData()
        }
    }
    
    // perform segue when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItemSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        let remoteVC = segue.destination as! TodoListTableViewController
        
        remoteVC.category = categoryList[indexPath.row]
    }
    
    //--------------------------------------------
    // MARK: - Add category method
    
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Add new category"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = ac.textFields![0].text!

            if !(newCategory.name!.isBlank) {
                self.categoryList.append(newCategory)
                
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
    func loadData (with request: NSFetchRequest<Category> = Category.fetchRequest()) {
            
        do{
            categoryList = try context.fetch(request)
        } catch {
            print("Error fetching data from CoreData \(error)")
        }
            
        self.tableView.reloadData()

    }
}

//--------------------------------------------
// MARK: - Search Bar delegate methods extension

extension CategoriesTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        // if there is no text to search then show all results (no request predicate)
        if !(searchBar.text!.isEmpty) {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadData(with: request)
        
        searchBar.resignFirstResponder()
    }
}
