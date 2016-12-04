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

public extension NSManagedObject {
    convenience init(withProperties properties: [String : AnyObject], context moc: NSManagedObjectContext) {
        if #available(iOS 10.0, *) {
            self.init(context: moc)
        } else {
            guard let entity = moc.persistentStoreCoordinator?.managedObjectModel.entity(ForClass: type(of: self)) else {
                preconditionFailure("Missing entity")
            }

            self.init(entity: entity, insertInto: moc)
        }

        self.setValuesForKeys(properties)
    }
}
