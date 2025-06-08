//
//  SymHandler.swift
//  Pocket Poster
//
//  Created by lemin on 5/31/25.
//

import Foundation

class SymHandler {
    
    // MARK: 获取 URL 操作
    
    /// 获取应用的文档目录路径（~/Documents）
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    /// 获取 LC_HOME 环境变量指定的 Documents 目录（用于 TrollStore 或越狱 App 特殊路径）
    static func getLCDocumentsDirectory() -> URL {
        let lcPath = ProcessInfo.processInfo.environment["LC_HOME_PATH"]
        if let lcPath = lcPath {
            return URL(fileURLWithPath: "\(lcPath)/Documents")
        }
        return getDocumentsDirectory()
    }
    
    /// 获取软链接文件应创建的位置（.Trash 目录作为临时链接点）
    private static func getSymlinkURL() -> URL {
        return getLCDocumentsDirectory().appendingPathComponent(".Trash", conformingTo: .symbolicLink)
    }
    
    // MARK: 创建符号链接（Symlink）
    
    /// 创建符号链接到指定路径，并返回链接地址
    static func createSymlink(to path: String) throws -> URL {
        let symURL = getSymlinkURL()
        cleanup() // 清理旧链接
        
        // 创建新的软链接，指向指定目录
        try FileManager.default.createSymbolicLink(at: symURL, withDestinationURL: URL(fileURLWithPath: path, isDirectory: true))
        
        return symURL
    }
    
    /// 创建指向指定 App 容器目录（根据 appHash）的符号链接
    static func createAppSymlink(for appHash: String) throws -> URL {
        return try createSymlink(to: "/var/mobile/Containers/Data/Application/\(appHash)")
    }
    
    /// 创建指向 PRBPoster 壁纸描述符目录的符号链接
    static func createDescriptorsSymlink(appHash: String, ext: String) throws -> URL {
        print("linking to \(appHash)/Library/Application Support/PRBPosterExtensionDataStore/61/Extensions/\(ext)/descriptors")
        return try createAppSymlink(for: "\(appHash)/Library/Application Support/PRBPosterExtensionDataStore/61/Extensions/\(ext)/descriptors")
    }
    
    /// 清理 `.Trash` 符号链接（如果存在）
    static func cleanup() {
        let symURL = getSymlinkURL()
        try? FileManager.default.removeItem(at: symURL)
    }
}
