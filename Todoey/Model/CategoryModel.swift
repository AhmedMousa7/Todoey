//
//  CategoryModel.swift
//  Todoey
//
//  Created by Ahmed Mousa on 01/02/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String = ""
    let items = List<ItemModel>()
}
