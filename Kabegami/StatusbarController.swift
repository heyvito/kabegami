//
//  StatusbarController.swift
//  Kabegami
//
//  Created by Victor Gama on 29/11/21.
//

import Cocoa

class StatusBarController {
    private var statusBar: NSStatusBar!
    private var statusItem: NSStatusItem!
    private var menu: NSMenu

    init(_ menu: NSMenu) {
        self.menu = menu
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: 28.0)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "Monitor")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
    }

    @objc func togglePopover(sender _: AnyObject) {
        let rawOrigin = statusItem.button!.bounds.origin
        let origin = NSPoint(x: rawOrigin.x, y: rawOrigin.y + statusItem.button!.frame.height)
        menu.popUp(positioning: nil, at: origin, in: statusItem.button!)
    }
}
