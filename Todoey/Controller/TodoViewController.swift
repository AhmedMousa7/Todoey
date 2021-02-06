//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory: CategoryModel? {
        didSet {
            loadData()
        }
    }
    
    var itemArray: Results<ItemModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let category = selectedCategory {
            title = category.name
            if let backgroundColor = UIColor(hexString: category.cellColor) {
                let backgroundColorContrasted = ContrastColorOf(backgroundColor, returnFlat: true)
                searchBar.barTintColor = backgroundColor
                searchBar.searchTextField.backgroundColor = .white
                navigationController?.navigationBar.tintColor = backgroundColorContrasted
                
                if #available(iOS 13.0, *) {
                    let navBarAppearance = UINavigationBarAppearance()
                    navBarAppearance.configureWithOpaqueBackground()
                    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: backgroundColorContrasted]
                    navBarAppearance.backgroundColor = backgroundColor
                    navigationController?.navigationBar.standardAppearance = navBarAppearance
                    navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                }
            }
        }
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
                do {
                    try self.realm.write {
                        let item = ItemModel()
                        item.title = value!
                        self.selectedCategory?.items.append(item)
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error while saving new item \(error)")
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            alertTextField = textField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func loadData() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
    
    // MARK: - update model
    override func updateModel(at index: IndexPath) {
        do {
            if let selectedItem = self.itemArray?[index.row]{
                try self.realm.write {
                    self.realm.delete(selectedItem)
                }
            }
        } catch {
            print("Error while deleting item \(error)")
        }
    }
    
}

// MARK: - Manipulate tableview

extension TodoViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cellItem = itemArray?[indexPath.row] {
            cell.textLabel?.text = cellItem.title
            cell.accessoryType = cellItem.isChecked ? .checkmark : .none
            let percentage = CGFloat(indexPath.row) / CGFloat(itemArray!.count)
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(percentage)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items added!"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellItem = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    cellItem.isChecked = !cellItem.isChecked
                    self.tableView.reloadData()
                }
            } catch {
                print("Error updating item in realm \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SearchBar delegate

extension TodoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text.isNilOrEmpty {
            itemArray = itemArray?.filter(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
                .sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
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
