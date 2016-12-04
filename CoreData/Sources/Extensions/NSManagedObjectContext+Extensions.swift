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

public extension NSManagedObjectContext {

    //MARK: - Root

    public func rootObject() throws -> NSManagedObject {
        self.concurrencyGuard()

        let objectID = try self.rootObjectID()

        return try self.existingObject(with: objectID)
    }

    public func rootObjectID() throws -> NSManagedObjectID {
        self.concurrencyGuard()

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
            self.perform(block)
        }

        if let error = saveError {
            throw error
        } else if let parent = self.parent {
            try parent.recursiveSave()
        }
    }

    //MARK: - Private

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
