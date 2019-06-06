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

public typealias ManagedCodable = ManagedDecodable & ManagedEncodable

//MARK: -

public typealias ManagedCodingKey = CodingKey & CaseIterable

//MARK: - ManagedEncodable

public protocol ManagedEncodable: Encodable where Self : NSManagedObject {
    associatedtype CodingKeyType: ManagedCodingKey
    
    func getAttribute(for codingKey: CodingKeyType) -> NSAttributeDescription?
}

extension ManagedEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeyType.self)
        
        for key in CodingKeyType.allCases {
            if let attribute = getAttribute(for: key) {
                if let value = value(forKey: attribute.name), let type = NSAttributeDescription.AttributeType.make(from: attribute, value: value) {
                    try container.encode(type, forKey: key)
                } else if !attribute.isOptional {
                    try container.encodeNil(forKey: key)
                }
            }
        }
    }
}

extension ManagedEncodable where CodingKeyType: RawRepresentable, CodingKeyType.RawValue == String {
    func getAttribute(for codingKey: CodingKeyType) -> NSAttributeDescription? {
        return entity.attributesByName[codingKey.rawValue]
    }
}

//MARK: -

extension KeyedEncodingContainerProtocol {
    public mutating func encode(_ attributeValue: NSAttributeDescription.AttributeType, forKey key: Key) throws {
        switch attributeValue {
        case .undefinedAttributeType:
            fatalError("Undefined attribute type")
        case .integer16AttributeType(let value):
            try encode(value, forKey: key)
            
        case .integer32AttributeType(let value):
            try encode(value, forKey: key)
            
        case .integer64AttributeType(let value):
            try encode(value, forKey: key)
            
        case .decimalAttributeType(let value):
            try encode(value, forKey: key)
            
        case .doubleAttributeType(let value):
            try encode(value, forKey: key)
            
        case .floatAttributeType(let value):
            try encode(value, forKey: key)
            
        case .stringAttributeType(let value):
            try encode(value, forKey: key)
            
        case .booleanAttributeType(let value):
            try encode(value, forKey: key)
            
        case .dateAttributeType(let value):
            try encode(value, forKey: key)
            
        case .binaryDataAttributeType(let value):
            try encode(value, forKey: key)
            
        case .UUIDAttributeType(let value):
            try encode(value, forKey: key)
            
        case .URIAttributeType(let value):
            try encode(value.absoluteString, forKey: key)
            
        case .transformableAttributeType:
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Not Supported")
            throw EncodingError.invalidValue(attributeValue, context)
        case .objectIDAttributeType:
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Not Supported")
            throw EncodingError.invalidValue(attributeValue, context)
        }
    }
}


//MARK: - ManagedDecodable

public protocol ManagedDecodable: Decodable where Self : NSManagedObject {
    associatedtype CodingKeyType: ManagedCodingKey
    
    func getAttribute(for codingKey: CodingKeyType) -> NSAttributeDescription?
    
    static func getEntity(for decoder: Decoder) -> NSEntityDescription
}

extension ManagedDecodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyType.self)
        
        let entity = type(of: self).getEntity(for: decoder)
        
        self.init(entity: entity, insertInto: nil)
        
        for key in CodingKeyType.allCases {
            if let attribute = getAttribute(for: key) {
                let value = try container.decode(attribute.attributeType, forKey: key)
                
                setValue(value, forKey: attribute.name)
            }
        }
    }
    
    //MARK: -
    
    public static func getEntity(for decoder: Decoder) -> NSEntityDescription {
        return entity()
    }
}

extension ManagedDecodable where CodingKeyType: RawRepresentable, CodingKeyType.RawValue == String {
    func getAttribute(for codingKey: CodingKeyType) -> NSAttributeDescription? {
        return entity.attributesByName[codingKey.rawValue]
    }
}

//MARK: -

extension KeyedDecodingContainerProtocol {
    public func decode(_ attributeType: NSAttributeType, forKey key: Key) throws -> Any {
        let result: Any
        
        switch attributeType {
        case .undefinedAttributeType:
            fatalError("Undefined attribute type")
        case .integer16AttributeType:
            let value = try decode(Int16.self, forKey: key)
            
            result = value
        case .integer32AttributeType:
            let value = try decode(Int32.self, forKey: key)
            
            result = value
        case .integer64AttributeType:
            let value = try decode(Int64.self, forKey: key)
            
            result = value
        case .decimalAttributeType:
            let value = try decode(Decimal.self, forKey: key)
            
            result = value
        case .doubleAttributeType:
            let value = try decode(Double.self, forKey: key)
            
            result = value
        case .floatAttributeType:
            let value = try decode(Float.self, forKey: key)
            
            result = value
        case .stringAttributeType:
            let value = try decode(String.self, forKey: key)
            
            result = value
        case .booleanAttributeType:
            let value = try decode(Bool.self, forKey: key)
            
            result = value
        case .dateAttributeType:
            let value = try decode(Date.self, forKey: key)
            
            result = value
        case .binaryDataAttributeType:
            let value = try decode(Data.self, forKey: key)
            
            result = value
        case .UUIDAttributeType:
            let value = try decode(UUID.self, forKey: key)
            
            result = value
        case .URIAttributeType:
            let value = try decode(String.self, forKey: key)
            guard let url = URL(string: value) else {
                preconditionFailure()
            }
            
            result = url
        case .transformableAttributeType:
            fatalError("Not supported")
        case .objectIDAttributeType:
            fatalError("Not supported")
        @unknown default:
            fatalError("Uknown attribute type")
        }
        
        return result
    }
}

