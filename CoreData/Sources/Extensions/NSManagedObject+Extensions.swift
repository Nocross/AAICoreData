/*
    Copyright (c) 2016 Andrey Ilskiy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

import CoreData

extension NSManagedObject {
    public convenience init(withProperties properties: [String : Any], context moc: NSManagedObjectContext) {
        if #available(iOS 10.0, *) {
            self.init(context: moc)
        } else {
            guard let entity = moc.persistentStoreCoordinator?.managedObjectModel.entity(for: type(of: self)) else {
                preconditionFailure("Missing entity")
            }

            self.init(entity: entity, insertInto: moc)
        }

        self.setValuesForKeys(properties)
    }
    
    public func withValueAcces(for property: NSPropertyDescription, access: () throws -> Void) rethrows -> Void {
        let entity = self.entity
        let hasProperty = entity.properties.contains { $0 == property }
        guard hasProperty else {
            preconditionFailure("Missing property - \(property) in \(entity) ")
        }
        
        willAccessValue(for: property)
        defer { didAccessValue(for: property) }
        
        try access()
    }
    
    public func withValueAcces(forProperty name: NSPropertyDescription.Name, access: () throws -> Void) rethrows -> Void {
        let entity = self.entity
        let hasProperty = entity.propertiesByNameValue.contains { $0.key == name }
        
        guard hasProperty else {
            preconditionFailure("Missing property for name - \(name) in \(entity) ")
        }
        
        willAccessValue(forProperty: name)
        defer { didAccessValue(forProperty: name) }
        
        try access()
    }
    
    
    private func withValueAcces(for key: String, access: () throws -> Void) rethrows -> Void {
        
        let entity = self.entity
        let hasProperty = entity.propertiesByName.contains { $0.key == key }
        guard hasProperty else {
            preconditionFailure("Missing property for key - \(key) in \(entity) ")
        }
        
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        
        try access()
    }
    
    public func willAccessValue(for property: NSPropertyDescription?) {
        self.willAccessValue(forProperty: property?.nameValue)
    }
    
    public func didAccessValue(for property: NSPropertyDescription?) {
        self.didAccessValue(forProperty: property?.nameValue)
    }
    
    public func willAccessValue(forProperty name: NSPropertyDescription.Name?) {
        self.willAccessValue(forKey: name?.rawValue)
    }
    
    public func didAccessValue(forProperty name: NSPropertyDescription.Name?) {
        self.didAccessValue(forKey: name?.rawValue)
    }
}
