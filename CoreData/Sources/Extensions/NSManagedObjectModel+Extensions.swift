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

extension NSManagedObjectModel {
    public static var fileExtension: String  {
        return "momd"
    }

    public static var defaultConfigurationName: String {
        return "Default"
    }

    public convenience init?(withName name: String, inBundle bundle: Bundle = Bundle.main) {
        guard let url = bundle.url(forResource: name, withExtension: NSManagedObjectModel.fileExtension) else {
            return nil
        }

        self.init(contentsOf: url)
    }

    public static func modelURLs(FromBundles bundles: [Bundle] = [Bundle.main]) -> [URL]? {
        var modelURLs: [URL]!

        for bundle in bundles {
            if let urls = bundle.urls(forResourcesWithExtension: self.fileExtension, subdirectory: nil) {
                if modelURLs == nil {
                    modelURLs = urls
                } else {
                    modelURLs.append(contentsOf: urls)
                }
            }
        }

        return modelURLs
    }

    public func rootEntityFetchRequest(_ bundle: Bundle = Bundle.main) -> NSFetchRequest<NSFetchRequestResult>? {

        var result: NSFetchRequest<NSFetchRequestResult>? = nil

        if let template = bundle.object(forInfoDictionaryKey: SPXRootEntityFetchRequestTemplateInfoKey) as? String {
            result = self.fetchRequestTemplate(forName: template)?.copy() as? NSFetchRequest<NSFetchRequestResult>
        } else {
            result = self.fetchRequestTemplate(forName: "Root")
            if result == nil {
                if let entity = bundle.object(forInfoDictionaryKey: SPXRootEntityInfoKey) as? String {
                    result = NSFetchRequest(entityName: entity)
                }
            } else {
                result = result?.copy() as? NSFetchRequest<NSFetchRequestResult>
            }
        }

        return result
    }

    public func entity(ForClass cls: AnyClass, forConfigurationName configuration: String? = nil) -> NSEntityDescription? {
        var result: NSEntityDescription? = nil

        let name = String(describing: cls)

        if configuration == nil {
            result = self.entitiesByName[name]
        }

        if result == nil {
            guard let entities = self.entities(forConfigurationName: configuration) else {
                preconditionFailure("Missing configuration name - \(String(describing: configuration))")
            }

            result = entities.first(where: { $0.managedObjectClassName == name })
        }

        return result
    }
    
    public func hasKind<ManagedType>(of type: ManagedType.Type, for objectID: NSManagedObjectID, in configuration: Configuration? = nil) -> Bool where ManagedType : NSManagedObject {
        
        let entity = self.entity(for: type, in: configuration)
        let result = entity != nil && entity!.isKindOf(entity: objectID.entity)
        
        return result
    }
}

//MARK: - Info Keys

public var SPXRootEntityFetchRequestTemplateInfoKey: String {
    return "SPXRootEntityFetchRequestTemplateName"
}
public var SPXRootEntityInfoKey: String {
    return "SPXRootEntityName"
}

public var SPXModelNameKey: String {
    return "SPXModelNameKey"
}
