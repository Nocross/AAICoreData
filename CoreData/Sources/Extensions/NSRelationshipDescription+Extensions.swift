//
//  NSRelationshipDescription+Extensions.swift
//  CoreData
//
//  Created by Andrey Ilskiy on 26/05/2019.
//  Copyright © 2019 Andrey Ilskiy. All rights reserved.
//

import CoreData

extension NSRelationshipDescription {
    public enum Plurality {
        case single(destination: NSManagedObject)
        case multiple(kind: MultiplicityKind)
        
        public func getSingle<ManagedType>() throws -> ManagedType where ManagedType : NSManagedObject {
            switch self {
            case .single(let destination):
                guard let object = destination as? ManagedType else { preconditionFailure("Type mismatch") }
                
                return object
            default:
                preconditionFailure()
            }
        }
    }
    
    public enum MultiplicityKind {
        case heap(entities: NSSet)
        case ordered(entities: NSOrderedSet)
    }
}

extension NSRelationshipDescription.Plurality {
    public static func make(from relationship: NSRelationshipDescription, value: Any?) -> NSRelationshipDescription.Plurality? {
        guard let value = value else { return nil }
        
        var result: NSRelationshipDescription.Plurality?
        
        if relationship.isToMany {
            let some: NSRelationshipDescription.MultiplicityKind
            
            if relationship.isOrdered {
                guard let other = value as? NSOrderedSet else { preconditionFailure() }
                
                some = .ordered(entities: other)
            } else {
                guard let other = value as? NSSet else { preconditionFailure() }
                
                some = .heap(entities: other)
            }
            
            result = .multiple(kind: some)
        } else {
            guard let some = value as? NSManagedObject else { preconditionFailure() }
            
            result = .single(destination: some)
        }
        
        return result
    }
}
