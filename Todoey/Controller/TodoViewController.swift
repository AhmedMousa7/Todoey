//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: CategoryModel? {
        didSet {
            loadData()
        }
    }
    
    var itemArray = [ItemModel]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        displayAlert()
    }
    
    private func displayAlert() {
        let alert = UIAlertController(title: "Add new Todoey Item", message: nil, preferredStyle: .alert)
        
        var alertTextField = UITextField()
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let value = alertTextField.text
            if !value.isNilOrEmpty {
                let item = ItemModel(context: self.context)
                item.title = value
                item.parentCategory = self.selectedCategory
                self.itemArray.append(item)
                self.saveData()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            alertTextField = textField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func saveData() {
        self.tableView.reloadData()
        do {
            try context.save()
        } catch {
            print("We got some errors while saving \(error)")
        }
    }
    
    private func loadData(with request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(),
                          predicate: NSPredicate? = nil) {
        do {
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            
            if let customPredicate = predicate {
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, customPredicate])
                request.predicate = compoundPredicate
            } else {
                request.predicate = categoryPredicate
            }
            
            itemArray = try context.fetch(request)
        } catch {
            print("We got some errors while decoding \(error)")
        }
        self.tableView.reloadData()
    }
    
}

// MARK: - Manipulate tableview

extension TodoViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let cellItem = itemArray[indexPath.row]
        cell.textLabel?.text = cellItem.title
        cell.accessoryType = cellItem.isChecked ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellItem = itemArray[indexPath.row]
        itemArray[indexPath.row].isChecked = !cellItem.isChecked
        tableView.deselectRow(at: indexPath, animated: true)
        // if we want to delete the selected item
        // context.delete(cellItem)
        // itemArray.remove(at: indexPath.row)
        self.saveData()
    }
}

// MARK: - SearchBar delegate

extension TodoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text.isNilOrEmpty {
            let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadData(with: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

// MARK: - Extensions

extension Optional where Wrapped == String  {
    
    var isNilOrEmpty: Bool {
        if self == nil || self!.isEmpty {
            return true
        }
        return false
    }
    
}
