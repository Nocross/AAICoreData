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
    public struct Configuration {
        public let name: Name
    }
    
    open func entities(for configuration: Configuration? = nil) -> [NSEntityDescription]? {
        return entities(forConfigurationName: configuration?.name)
    }
    
    open func setEntities(_ entities: [NSEntityDescription], for configuration: Configuration) {
        setEntities(entities, forConfigurationName: configuration.name)
    }
    
    private func entities(forConfigurationName name: Configuration.Name?) -> [NSEntityDescription]? {
        return entities(forConfigurationName: name?.rawValue)
    }
    
    private func setEntities(_ entities: [NSEntityDescription], forConfigurationName name: Configuration.Name) {
        setEntities(entities, forConfigurationName: name.rawValue)
    }
    
    public func entity<ManagedType>(for type: ManagedType.Type, in configuration: Configuration? = nil) -> NSEntityDescription? where ManagedType : NSManagedObject {
        return entity(for: type, forConfiguration: configuration?.name)
    }
    
    private func entity<ManagedType>(for type: ManagedType.Type, forConfiguration name: Configuration.Name? = nil) -> NSEntityDescription? where ManagedType : NSManagedObject {
        return entity(ForClass: type, forConfigurationName: name?.rawValue)
    }
}

extension NSManagedObjectModel.Configuration {
    public static var `default`: NSManagedObjectModel.Configuration {
        return NSManagedObjectModel.Configuration(name: Name.default)
    }
}

extension NSManagedObjectModel.Configuration {
    public struct Name: StringRepresentableIdentifierProtocol {
        
        //MARK: - RawRepresentable
        
        public typealias RawValue = String
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
        
        //MARK - Hashable
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
        
        public func hash(into hasher: inout Hasher) {
            rawValue.hash(into: &hasher)
        }
        
        //MARK: - Comparable
        
        public static func < (lhs: NSManagedObjectModel.Configuration.Name, rhs: NSManagedObjectModel.Configuration.Name) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}

extension NSManagedObjectModel.Configuration.Name {
    public static var `default`: NSManagedObjectModel.Configuration.Name {
        return NSManagedObjectModel.Configuration.Name(rawValue: "Default")
    }
}
