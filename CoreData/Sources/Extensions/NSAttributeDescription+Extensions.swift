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

public protocol AttributeTypeValueProtocol {
    var attributeType: NSAttributeType { get }
}

extension NSAttributeDescription {
    public var defaultTypedValue: AttributeType? {
        return AttributeType(attribute: attributeType, value: defaultValue)
    }
}

extension NSAttributeDescription {
    public enum AttributeType {
        case undefinedAttributeType
        
        case integer16AttributeType(short: Int16)
        
        case integer32AttributeType(int: Int32)
        
        case integer64AttributeType(long: Int64)
        
        case decimalAttributeType(decimal: Decimal)
        
        case doubleAttributeType(double: Double)
        
        case floatAttributeType(float: Float)
        
        case stringAttributeType(string: String)
        
        case booleanAttributeType(flag: Bool)
        
        case dateAttributeType(date: Date)
        
        case binaryDataAttributeType(data: Data)
        
        @available(iOS 11.0, *)
        case UUIDAttributeType(uuid: UUID)
        
        @available(iOS 11.0, *)
        case URIAttributeType(uri: URL)
        
        @available(iOS 3.0, *)
        case transformableAttributeType // If your attribute is of NSTransformableAttributeType, the attributeValueClassName must be set or attribute value class must implement NSCopying.
        
        @available(iOS 3.0, *)
        case objectIDAttributeType(objectID: NSManagedObjectID)
        
        fileprivate init?(attribute type: NSAttributeType, value: Any?) {
            guard let value = value else { return nil }
            
            switch type {
            case .undefinedAttributeType:
                self = .undefinedAttributeType
                
            case .integer16AttributeType:
                self = .integer16AttributeType(short: value as! Int16)
                
            case .integer32AttributeType:
                self = .integer32AttributeType(int: value as! Int32)
                
            case .integer64AttributeType:
                self = .integer64AttributeType(long: value as! Int64)
                
            case .decimalAttributeType:
                self = .decimalAttributeType(decimal: value as! Decimal)
                
            case .doubleAttributeType:
                self = .doubleAttributeType(double: value as! Double)
                
            case .floatAttributeType:
                self = .floatAttributeType(float: value as! Float)
                
            case .stringAttributeType:
                self = .stringAttributeType(string: value as! String)
                
            case .booleanAttributeType:
                self = .booleanAttributeType(flag: value as! Bool)
                
            case .dateAttributeType:
                self = .dateAttributeType(date: value as! Date)
                
            case .binaryDataAttributeType:
                self = .binaryDataAttributeType(data: value as! Data)
                
            case .UUIDAttributeType:
                self = .UUIDAttributeType(uuid: value as! UUID)
                
            case .URIAttributeType:
                self = .URIAttributeType(uri: value as! URL)
                
            case .transformableAttributeType:
                self = .transformableAttributeType
                
            case .objectIDAttributeType:
                self = .objectIDAttributeType(objectID: value as! NSManagedObjectID)
                
            @unknown default:
                let message = "Unknown NSAttributeType value - \(type)"
                fatalError(message)
            }
        }
        
        public static func make(from attributeType: NSAttributeType, value: Any?) -> AttributeType? {
            return `AttributeType`(attribute: attributeType, value: value)
        }
        
        public static func make(from attributeDescription: NSAttributeDescription, value: Any?) -> AttributeType? {
            let type = attributeDescription.attributeType
            return AttributeType(attribute: type, value: value)
        }
    }
}

extension NSAttributeDescription.AttributeType: RawRepresentable {
    public typealias RawValue = NSAttributeType
    
    public init?(rawValue: RawValue) {
        return nil
    }
    
    public var rawValue: RawValue {
        let result: RawValue
        
        switch self {
        case .undefinedAttributeType:
           result = .undefinedAttributeType
            
        case .integer16AttributeType:
            result = .integer16AttributeType
            
        case .integer32AttributeType:
            result = .integer32AttributeType
            
        case .integer64AttributeType:
            result = .integer64AttributeType
            
        case .decimalAttributeType:
            result = .decimalAttributeType
            
        case .doubleAttributeType:
            result = .doubleAttributeType
            
        case .floatAttributeType:
            result = .floatAttributeType
            
        case .stringAttributeType:
            result = .stringAttributeType
            
        case .booleanAttributeType:
            result = .booleanAttributeType
            
        case .dateAttributeType:
            result = .dateAttributeType
            
        case .binaryDataAttributeType:
            result = .binaryDataAttributeType
            
        case .UUIDAttributeType:
            result = .UUIDAttributeType
            
        case .URIAttributeType:
            result = .URIAttributeType
            
        case .transformableAttributeType:
            result = .transformableAttributeType
            
        case .objectIDAttributeType:
            result = .objectIDAttributeType
        }
        
        return result
    }
}
