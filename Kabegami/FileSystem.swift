//
//  FileSystem.swift
//  Kabegami
//
//  Created by Victor Gama on 29/11/21.
//

import Foundation
import AppKit

class FileSystem {
    fileprivate static var targetDir: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }()
    
    class func exportToDownloads() -> [URL]? {
        let url: URL
        do {
            url = try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch let err {
            NSLog("Error obatining downloads directory: \(err)")
            return nil
        }
        guard let images = images() else { return nil }
        var urls: [URL] = []
        for i in images {
            do {
                let target = url.appendingPathComponent(i.pathComponents.last!)
                try FileManager.default.copyItem(at: i, to: target)
                urls.append(target)
            } catch let err {
                NSLog("Error writing file: \(err)")
                return nil
            }
        }
        
        return urls
    }
    
    class func images() -> [URL]? {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: targetDir, includingPropertiesForKeys: nil)
            return directoryContents.filter{ $0.pathExtension == "png" }
        } catch let err {
            NSLog("Failed reading files: \(err)")
            return nil
        }
    }
    
    class func saveImage(_ img: NSImage, forDisplay display: Int, apply: Bool) -> Bool {
        guard let cgRef = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
        let newRep = NSBitmapImageRep(cgImage: cgRef)
        newRep.size = img.size
        guard let pngData = newRep.representation(using: .png, properties: [:]) else { return false }
        let targetImage = targetDir.appendingPathComponent("\(display)-\(UUID().uuidString).png")
            
        do {
            if let allImages = images() {
                if let toRemove = allImages.first(where: { $0.pathComponents.last!.starts(with: "\(display)-") }) {
                    try FileManager.default.removeItem(at: toRemove)
                }
            }
            try pngData.write(to: targetImage)
            NSLog("Wrote \(targetImage)")
        } catch let err {
            NSLog("Failed writing file: \(err)")
            return false
        }
        
        if apply {
            do {
                try NSWorkspace.shared.setDesktopImageURL(targetImage, for: NSScreen.screens[display], options: [:])
            } catch let err {
                NSLog("Failed setting desktop image: \(err)")
                return false
            }
        }
        return true
    }
}
