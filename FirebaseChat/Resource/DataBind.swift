//
//  ProjectStructure
//
//  Created by MultiQoS on 05/04/2021.
//  Copyright © 2021 MultiQoS. All rights reserved.
//

import Foundation

class DataBind<T> {
    
    typealias Observer = (T) -> ()
    var observer: Observer?
    
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
    
    func subscribe(_ observer: Observer?) {
        self.observer = observer
        observer?(value)
    }
    
}
