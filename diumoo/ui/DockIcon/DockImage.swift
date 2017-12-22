//
//  DockImage.swift
//  diumoo
//
//  Created by leave on 22/12/2017.
//

import AppKit

class DockImage {

    static func processedImage(_ image: NSImage?) -> NSImage? {
        guard let image = image else {
            return nil
        }
        if abs(image.size.width - image.size.height) < 3 {
            return image
        }

        let edge = min(image.size.height, image.size.width, 100)
        return image.resizeImage(size: CGSize(width: edge, height: edge))
    }

}

extension NSImage {

    func resizeImage(size: CGSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()

        var visiableRect = NSRect.zero
        let originalSize = self.size
        if originalSize.height > originalSize.width {
            visiableRect.origin.x = 0
            visiableRect.origin.y = (originalSize.height - originalSize.width) / 2
            visiableRect.size.width = originalSize.width
            visiableRect.size.height = originalSize.width
        } else {
            visiableRect.origin.y = 0
            visiableRect.origin.x = (originalSize.width - originalSize.height) / 2
            visiableRect.size.width = originalSize.height
            visiableRect.size.height = originalSize.height
        }

        let ctx = NSGraphicsContext.current()
        ctx?.imageInterpolation = .high
        self.draw(in: NSMakeRect(0, 0, size.width, size.height),
                  from: visiableRect,
                  operation: .copy, fraction: 1)
        newImage.unlockFocus()
        return newImage
    }
}

