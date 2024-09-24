//
//  TimestampStorage.swift

//
//  Created by Carlson Yuan on 2023/8/9.
//

import Foundation

public class TimestampStorage {
    
    public typealias Timestamp = Int64
    
    private var timestamps: [String: Timestamp] = [:]
    
    public init() { }
    
}
