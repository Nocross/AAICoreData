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

import Foundation
import CoreData

import AAIFoundation

private let unfair = OSUnfairLock()

extension NSPersistentStore {
    public typealias StoreType = String
    public typealias StoreOptions = [AnyHashable : Any]
    public typealias StoreTypeOptionsMap = [StoreType : StoreOptions]

    fileprivate final class var key: UnsafeRawPointer {
        let selector = #selector(setDefaultOptions)
        return unsafeBitCast(selector, to: UnsafeRawPointer.self)
    }

    public static func defaultOptions() -> StoreTypeOptionsMap? {
        var result: StoreTypeOptionsMap? = nil

        unfair.lock()

        if let map = objc_getAssociatedObject(self, key) as? StoreTypeOptionsMap {
            result = map
        }

        unfair.unlock()

        return result
    }

    public static func defaultOptions(forStoreType type: String) -> StoreOptions? {
        var result: StoreOptions? = nil

        unfair.lock()

        if let map = objc_getAssociatedObject(self, key) as? StoreTypeOptionsMap {
            result = map[type]
        } else if type == NSSQLiteStoreType {
            result = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true,
                NSPersistentStoreFileProtectionKey : FileProtectionType.complete.rawValue
            ]
        }

        unfair.unlock()

        return result
    }

    @objc
    public class func setDefaultOptions(_ options: StoreOptions, forStoreType type: String) {

        unfair.lock()

        var map: StoreTypeOptionsMap! = objc_getAssociatedObject(self, key) as? StoreTypeOptionsMap

        if map == nil {
            map = StoreTypeOptionsMap();
            objc_setAssociatedObject(self, key, map, .OBJC_ASSOCIATION_RETAIN)
        }

        map[type] = options

        unfair.unlock()
    }
}
