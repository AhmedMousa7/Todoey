//
//  ItemModel.swift
//  Todoey
//
//  Created by Ahmed Mousa on 01/02/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ItemModel: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: CategoryModel.self, property: "items")
}
