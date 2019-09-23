//
//  CategoriesTableViewController.swift
//  Todoey
//
//  Created by Daniel Alesanco on 21/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesTableViewController: UITableViewController {

    //--------------------------------------------
    // MARK: global variables definition
    
    let realm  = try! Realm()
    var categoryList: Results<Category>?

    //--------------------------------------------
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
    }

    //--------------------------------------------
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categoryList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        if let category = categoryList?[indexPath.row] {
            
            cell.textLabel?.text = category.name
        }
        
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
            
            do{
                try realm.write {
                    realm.delete(categoryList![indexPath.row])
                    tableView.reloadData()
                }
            } catch {
                print("error deleting category \(error)")
            }
        }
    }
    
    // perform segue when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItemSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        let remoteVC = segue.destination as! ItemListTableViewController
        
        remoteVC.currentCategory = categoryList![indexPath.row]
    }
    
    //--------------------------------------------
    // MARK: - Add category method
    
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Add new category"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let category = Category()
            category.name = ac.textFields![0].text!

            if !(category.name.isBlank) {
                do {
                    try self.realm.write {
                        self.realm.add(category)
                        self.tableView.reloadData()
                    }
                } catch {
                    print("error adding new category \(error)")
                }
            }
        }
                
        ac.addAction(addAction)
        present(ac, animated: true)
        
    }
    
    //--------------------------------------------
    // MARK: - Utility methods
                
    func loadCategory(){
    
        categoryList = realm.objects(Category.self)
        tableView.reloadData()
    }
}

//--------------------------------------------
// MARK: - Search Bar delegate methods extension

extension CategoriesTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)

        if !(searchBar.text!.isBlank) {
           
            categoryList = realm.objects(Category.self).filter(searchPredicate)
                
        } else {
            
            categoryList = realm.objects(Category.self)
                
        }
        
        tableView.reloadData()

        searchBar.resignFirstResponder()
    }
}
