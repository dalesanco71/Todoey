//
//  Category.swift
//  Todoey
//
//  Created by Daniel Alesanco on 22/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    
    @objc dynamic var name : String = ""
    
    let items = List<Item>()
}
