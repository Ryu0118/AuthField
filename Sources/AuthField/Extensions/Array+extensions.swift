//
//  Array+extensions.swift
//  
//
//  Created by Ryu on 2022/04/19.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
