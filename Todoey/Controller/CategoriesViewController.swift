//
//  CategoriesViewController.swift
//  Todoey
//
//  Created by Ahmed Mousa on 31/01/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController {

    var categories = [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData(request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error while loading \(error)")
        }
        self.tableView.reloadData()
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error while loading \(error)")
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
                let category = CategoryModel(context: self.context)
                category.name = textAddField.text
                self.categories.append(category)
                self.saveData()
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table view data source and click

extension CategoriesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItem", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "categoryItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? TodoViewController
        if let selectedIndex = tableView.indexPathForSelectedRow?.row {
            destinationVC?.selectedCategory = categories[selectedIndex]
        }
    }
}
