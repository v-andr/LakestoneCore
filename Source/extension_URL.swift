//
//  extension_URL.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/21/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//
// --------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if !COOPER
    import Foundation
#endif

extension URL {
    
    public static func from(string: String) -> URL? {
        #if COOPER
            return try? URL(string)
        #else
            return URL(string: string)
        #endif
    }
    
}