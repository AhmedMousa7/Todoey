//
//  CategoriesViewController.swift
//  Todoey
//
//  Created by Ahmed Mousa on 31/01/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<CategoryModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    func loadData() {
        categories = realm.objects(CategoryModel.self)
        self.tableView.reloadData()
    }
    
    func saveData(category: CategoryModel) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error while Saving \(error)")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        showAddigDialog()
    }
    
    private func showAddigDialog() {
        let alert = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        
        var textAddField = UITextField()
        alert.addTextField { (textField) in
            textField.placeholder = "Create new category"
            textAddField = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if !textAddField.text.isNilOrEmpty {
                let category = CategoryModel()
                category.name = textAddField.text!
                category.cellColor = UIColor.randomFlat().hexValue()
                self.saveData(category: category)
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - update model
    override func updateModel(at index: IndexPath) {
        do {
            if let selectedItem = self.categories?[index.row]{
                try self.realm.write {
                    self.realm.delete(selectedItem)
                }
            }
        } catch {
            print("Error while deleting item \(error)")
        }
    }
}

// MARK: - Table view data source and click

extension CategoriesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cellItem = categories?[indexPath.row] {
            cell.textLabel?.text = cellItem.name
            cell.backgroundColor = UIColor(hexString: cellItem.cellColor)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: cellItem.cellColor)!, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "categoryItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? TodoViewController
        if let selectedIndex = tableView.indexPathForSelectedRow?.row {
            destinationVC?.selectedCategory = categories?[selectedIndex]
        }
    }
}
