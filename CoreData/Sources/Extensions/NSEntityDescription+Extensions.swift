/*
    Copyright (c) 2019 Andrey Ilskiy.

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
import AAIFoundation

extension NSEntityDescription {
    open var propertiesByNameValue: [NSPropertyDescription.Name : NSPropertyDescription] {
        
        typealias Name = NSPropertyDescription.Name
        typealias Value = NSPropertyDescription
        
        var result = [Name : Value]()
        
        result = propertiesByName.lazy.reduce(into: result) {
            let key = Name(rawValue: $1.key)
            $0[key] = $1.value
        }
        
        return result
    }
    
    open var attributesByNameValue: [NSAttributeDescription.Name : NSAttributeDescription] {
        typealias Name = NSAttributeDescription.Name
        typealias Value = NSAttributeDescription
        
        var result = [Name : Value]()
        
        result = attributesByName.lazy.reduce(into: result) {
            let key = Name(rawValue: $1.key)
            $0[key] = $1.value
        }
        
        return result
    }
    
    open var relationshipsByNameValue: [NSRelationshipDescription.Name : NSRelationshipDescription] {
        typealias Name = NSRelationshipDescription.Name
        typealias Value = NSRelationshipDescription
        
        var result = [Name : Value]()
        
        result = relationshipsByName.lazy.reduce(into: result) {
            let key = Name(rawValue: $1.key)
            $0[key] = $1.value
        }
        
        return result
    }
}
