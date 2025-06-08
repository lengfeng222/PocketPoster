//
//  Bundle++.swift
//  Pocket Poster
//
//  Created by lemin on 6/1/25.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
