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

extension NSFetchRequest {
    public struct Template {
        private init () {}
    }
}

extension NSFetchRequest.Template {
    //TODO: File a bug - breaks swift compiler for some reason
    /*
    public struct Name: StringRepresentableIdentifierProtocol {
        
        //MARK: - RawRepresentable
        
        public typealias RawValue = String
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
    */
}

extension NSFetchRequest.Template {
    public typealias Variable = ExpressionPredicateSubstitutionVariableProcol
}