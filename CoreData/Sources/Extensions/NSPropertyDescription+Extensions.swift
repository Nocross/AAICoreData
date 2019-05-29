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

extension NSPropertyDescription {
    open var localizedName: String? {
        var result: String?
        
        if let some = entity.managedObjectModel.localizationDictionary {
            let keys = modelLocalizationDictionaryKeys
            
            for key in keys {
                if let value = some[key] {
                    result = value
                    break
                }
            }
        }
        
        return result
    }
    
    open var modelLocalizationDictionaryKeys: [String] {
        let global = "Property/\(self.name)"
        
        var result = Array<String>()
        result.reserveCapacity(2)
        
        if let suffix = entity.modelLocalizationDictionaryKey {
            let entitySpecific = "\(global)/\(suffix)"
            
            result.append(entitySpecific)
        }
        result.append(global)
        
        return result
    }
}
