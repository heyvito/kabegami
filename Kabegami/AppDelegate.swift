//
//  AppDelegate.swift
//  Kabegami
//
//  Created by Victor Gama on 29/11/21.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBar: StatusBarController?
    var menu = NSMenu()
    var refreshOnWake: NSMenuItem?
    var refreshOnLaunch: NSMenuItem?
    var oneImagePerDisplay: NSMenuItem?
    var generator = Generator()
    
    let kRefreshOnWake = "kRefreshOnWake"
    let kRefreshOnLaunch = "kRefreshOnLaunch"
    let kOneImagePerDisplay = "kOneImagePerDisplay"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menu.addItem(withTitle: "Kabegami", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Refresh", action: #selector(doRefresh(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Export Wallpaper to Downloads", action: #selector(saveCurrentImage(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        refreshOnWake = menu.addItem(withTitle: "Refresh on Wake", action: #selector(toggleRefreshOnWake(_:)), keyEquivalent: "")
        refreshOnLaunch = menu.addItem(withTitle: "Refresh on Launch", action: #selector(toggleRefreshOnLaunch(_:)), keyEquivalent: "")
        oneImagePerDisplay = menu.addItem(withTitle: "Generate One Image per Display", action: #selector(toggleOneImagePerDisplay(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Project Homepage", action: #selector(projectHomePage(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(quit(_:)), keyEquivalent: "")
        
        statusBar = StatusBarController.init(menu)
        
        updateToggles()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(wakeListener(_:)),
                                                              name: NSWorkspace.didWakeNotification, object: nil)
        
        if refreshOnLaunch!.state == .on {
            doRefresh(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func wakeListener(_ sender: AnyObject) {
        if refreshOnWake!.state == .on {
            doRefresh(sender)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
    
    func updateToggles() {
        let ud = UserDefaults.standard
        
        refreshOnWake!.state = ud.bool(forKey: kRefreshOnWake) ? .on : .off
        refreshOnLaunch!.state = ud.bool(forKey: kRefreshOnLaunch) ? .on : .off
        oneImagePerDisplay!.state = ud.bool(forKey: kOneImagePerDisplay) ? .on : .off
    }
    
    @objc func doRefresh(_: AnyObject) {
        let imagesToGenerate = UserDefaults.standard.bool(forKey: kOneImagePerDisplay) ? NSScreen.screens.count : 1
        for i in 0..<imagesToGenerate {
            if !FileSystem.saveImage(generator.makeImage(), forDisplay: i, apply: true) {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Could not set wallpaper"
                alert.informativeText = "An error prevented the desktop image to be changed. Check console logs for further info."
                alert.runModal()
                return
            }
        }
    }
    
    @objc func saveCurrentImage(_: AnyObject) {
        guard let allImages = FileSystem.images() else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Could not list wallpapers"
            alert.informativeText = "An error prevented the operation from complting. Check console logs for further info."
            alert.runModal()
            return
        }
        
        if allImages.isEmpty {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "No wallpapers"
            alert.informativeText = "No wallpaper is currently active. Hit 'Refresh' before trying to export it."
            alert.runModal()
            return
        }
        
        guard let urls = FileSystem.exportToDownloads() else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Failed exporting"
            alert.informativeText = "An error prevented the action from completing. Check console logs for further info."
            alert.runModal()
            return
        }
        
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }
    
    func toggleUserDefault(named name: String) {
        let ud = UserDefaults.standard
        ud.set(!ud.bool(forKey: name), forKey: name)
    }
    
    @objc func toggleRefreshOnWake(_: AnyObject) {
        toggleUserDefault(named: kRefreshOnWake)
        updateToggles()
    }
    
    @objc func toggleRefreshOnLaunch(_: AnyObject) {
        toggleUserDefault(named: kRefreshOnLaunch)
        updateToggles()
    }
    
    @objc func toggleOneImagePerDisplay(_: AnyObject) {
        toggleUserDefault(named: kOneImagePerDisplay)
        updateToggles()
    }
    
    @objc func projectHomePage(_: AnyObject) {
        NSWorkspace.shared.open(URL(string: "https://github.com/heyvito/kabegami")!)
    }
    
    @objc func quit(_ sender: AnyObject) {
        NSApp.terminate(sender)
    }
}

