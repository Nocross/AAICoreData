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
import AAIFoundation

extension NSManagedObjectContext {
    
    @available(iOS 10.0, *)
    public convenience init(parent: NSManagedObjectContext, concurrencyType ct: NSManagedObjectContextConcurrencyType? = nil) {
        let concurrencyType = ct ?? parent.concurrencyType
        
        self.init(concurrencyType: concurrencyType)
        
        self.parent = parent
        self.automaticallyMergesChangesFromParent = true
    }
    
    @available(iOS 5.0, *)
    public convenience init(fromCoordinatorOf context: NSManagedObjectContext, concurrencyType ct: NSManagedObjectContextConcurrencyType? = nil) {
        let concurrencyType = ct ?? context.concurrencyType
        self.init(concurrencyType: concurrencyType)
        
        var root: NSManagedObjectContext? = context
        repeat {
            if let coordinator = root?.persistentStoreCoordinator {
                self.persistentStoreCoordinator = coordinator
                root = nil
            } else {
                root = root?.parent
            }
        } while root != nil
        
        precondition(self.persistentStoreCoordinator != nil)
    }
    
    //MARK: -
    
    //MARK: -
    
    open func insert<S>(_ objects: S) where S : Sequence, S.Element : NSManagedObject {
        //TODO: Add bunch of check(s) to prevent potential exception raisal
        objects.forEach { self.insert($0) }
    }
    
    open func delete<S>(_ objects: S) where S : Sequence, S.Element : NSManagedObject {
        //TODO: Add bunch of check(s) to prevent potential exception raisal
        objects.forEach { self.delete($0) }
    }
    
    //MARK: -
    
    open func object<ManagedType>(for objectID: NSManagedObjectID) -> ManagedType where ManagedType : NSManagedObject {
        
        guard let object = object(with: objectID) as? ManagedType else {
            let type = Swift.type(of: self.object(with: objectID))
            let typeName = String(describing: type)
            let entityTypeName = String(describing: objectID.entity.managedObjectClassName)
            let message = "Type mismatch objectID type - \(entityTypeName) | object - \(typeName)"
            preconditionFailure(message)
        }
        
        return object
    }
    
    @available(iOS 3.0, *)
    public func existingObject<ManagedType>(for objectID: NSManagedObjectID) throws -> ManagedType where ManagedType : NSManagedObject {
        
        guard let object = try existingObject(with: objectID) as? ManagedType else {
            let type = Swift.type(of: self.object(with: objectID))
            let typeName = String(describing: type)
            let entityTypeName = String(describing: objectID.entity.managedObjectClassName)
            let message = "Type mismatch objectID type - \(entityTypeName) | object - \(typeName)"
            preconditionFailure(message)
        }
        
        return object
    }
    
    //MARK: -
    
    @available(iOS 5.0, *)
    public func evaluateAndWait<Result>(_ body: @escaping () -> Result) -> Result {
        var result: Result!
        
        let concurrencyType = self.concurrencyType
        let isMainQueue: Bool
        if #available(iOS 9.0, *) {
            let isRelevant = concurrencyType == .mainQueueConcurrencyType
            isMainQueue = isRelevant && Thread.isMainThread
        } else {
            let isRelevant = concurrencyType == .mainQueueConcurrencyType || concurrencyType == .confinementConcurrencyType
            isMainQueue = isRelevant && Thread.isMainThread
        }
        
        if isMainQueue {
            result = body()
        } else {
            var outcome: Outcome<Result, Error> = nil
            
            let block = {
                let value = body()
                
                outcome = .conclusion(value)
            }
            performAndWait(block)
            
            result = try! outcome.get()
        }
        
        return result
    }
    
    @available(iOS 5.0, *)
    public func evaluateAndWait<ManagedObject, Result>(for objectID: NSManagedObjectID, body: @escaping (ManagedObject) -> Result) throws -> Result where ManagedObject : NSManagedObject {
        let object = try existingObject(for: objectID) as ManagedObject
        let result = evaluateAndWait { () -> Result in
            return body(object)
        }
        
        return result
    }

    //MARK: - Root

    public func rootObject<T>() throws -> T where T : NSManagedObject {
        concurrencyGuard()

        let objectID = try rootObjectID()

        return object(for: objectID)
    }
    
    public func existingRootObject<T>() throws -> T where T : NSManagedObject {
        concurrencyGuard()
        
        let objectID = try rootObjectID()
        
        return try existingObject(for: objectID)
    }

    public func rootObjectID() throws -> NSManagedObjectID {
        concurrencyGuard()

        var result: NSManagedObjectID? = nil;

        guard let request = self.persistentStoreCoordinator?.managedObjectModel.rootEntityFetchRequest() else {
            preconditionFailure("Root entity fetch request not set")
        }
        request.resultType = .managedObjectIDResultType

        let objects = try self.fetch(request)

        switch objects.count {
        case 0:
            let root = NSManagedObject(entity: request.entity!, insertInto: self)
            try self.obtainPermanentIDs(for: [root])

            result = root.objectID
        case 1:
            result = objects.last as? NSManagedObjectID
        default:
            preconditionFailure("Multiple Root objects")
        }

        return result!
    }

    //MARK: - Save

    @available(iOS 5.0, *)
    public func recursiveSave() throws {
        guard self.hasChanges && self.persistentStoreCoordinator != nil else {
            return
        }

        var saveError: Error! = nil

        let block = {
            do {
                try self.save()
            } catch {
                saveError = error
            }
        }

        switch self.concurrencyType {
        case .confinementConcurrencyType:
            fallthrough
        case .privateQueueConcurrencyType:
            self.performAndWait(block)

        case .mainQueueConcurrencyType:
            block()
        @unknown default:
            let typeName = String(describing: NSManagedObjectContextConcurrencyType.self)
            preconditionFailure("Uknown value for \(typeName) - \(self.concurrencyType)")
        }

        if let error = saveError {
            throw error
        } else if let parent = self.parent {
            try parent.recursiveSave()
        }
    }

    //MARK: - Private

    @available(iOS 5.0, *)
    fileprivate func concurrencyGuard() {
        let isMainThread = Thread.isMainThread
        let concurrencyType = self.concurrencyType
        
        let hasAccessedPrivateQueueContextFromMain = isMainThread && concurrencyType == .privateQueueConcurrencyType
        let hasAccessedMainQueueContextFromOtherQueue = !isMainThread && concurrencyType == .mainQueueConcurrencyType

        if hasAccessedPrivateQueueContextFromMain || hasAccessedMainQueueContextFromOtherQueue {
            preconditionFailure("Violated core data queue isolation")
        }
    }
}
