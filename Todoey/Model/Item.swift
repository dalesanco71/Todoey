//
//  Data.swift
//  Todoey
//
//  Created by Daniel Alesanco on 22/09/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done  : Bool   = false

    let categoryParent = LinkingObjects(fromType: Category.self, property: "items")

}
