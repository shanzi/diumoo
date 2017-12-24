//
//  DockImageProvider.swift
//  diumoo
//
//  Created by leave on 22/12/2017.
//

import AppKit

class DockImageProvider {


    static func processedImage(_ image: NSImage?) -> NSImage? {
        guard let image = image else {
            return nil
        }

        let edge = min(image.size.height, image.size.width, 100)
        let radius = 0.2 * edge
        let margin = 0.05 * edge
        return image.resizeImage(to: CGSize(width: edge, height: edge),
                                 radius: radius,
                                 margin: margin)
    }

}

extension NSImage {

    fileprivate func resizeImage(to size: CGSize, radius: CGFloat, margin: CGFloat) -> NSImage {
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
        let imageFrame = NSRect(x: margin, y: margin, width: size.width-margin*2, height: size.height-margin*2)

        let backShape = NSBezierPath(roundedRect: imageFrame.insetBy(dx: -margin*0.5, dy: -margin*0.5)
            , xRadius: radius*1.1, yRadius: radius*1.1)
        NSColor.white.set()
        backShape.fill()

        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: radius, yRadius: radius)
        clipPath.windingRule = .evenOddWindingRule
        clipPath.addClip()


        self.draw(in: imageFrame,
                  from: visiableRect,
                  operation: .copy, fraction: 1)
        newImage.unlockFocus()
        return newImage
    }

}

