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

extension NSManagedObjectModel {
    open func setFetchRequestTemplate(_ fetchRequestTemplate: NSFetchRequest<NSFetchRequestResult>?, for name: FetchRequest.Template.Name) {
        setFetchRequestTemplate(fetchRequestTemplate, forName: name.rawValue)
    }

    open func fetchRequestTemplate(for name: FetchRequest.Template.Name) -> NSFetchRequest<NSFetchRequestResult>? {
        return fetchRequestTemplate(forName: name.rawValue)
    }

    open func fetchRequestFromTemplate<VariableType>(with name: FetchRequest.Template.Name, substituting variables: [VariableType]) -> NSFetchRequest<NSFetchRequestResult>? where VariableType : FetchRequest.Template.Variable {

        var reduced = [String : Any]()
        reduced = variables.reduce(into: reduced) { (result, variable) in
            let key = String(variable.name.rawValue)
            result[key] = variable.value
        }
        
        let result = fetchRequestFromTemplate(withName: name.rawValue, substitutionVariables: reduced)
        return result
    }
}

extension NSManagedObjectModel {
    public struct FetchRequest {
        private init() {}
        
        public struct Template {
            private init() {}
        }
    }
}


extension NSManagedObjectModel.FetchRequest.Template {
//    public typealias Name = String //NSFetchRequest<NSFetchRequestResult>.Template.Name
    public typealias Variable = NSFetchRequest<NSFetchRequestResult>.Template.Variable
    
    public struct Name: StringRepresentableIdentifierProtocol {
        
        //MARK: - RawRepresentable
        
        public typealias RawValue = String
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
}
