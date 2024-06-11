//
//  LeftAlignCollectionLayout.swift
//  Blue
//
//  Created by Blue.

import UIKit

class LeftAlignCollectionLayout: UICollectionViewFlowLayout {
    
    /*
     the designated initializers for the LeftAlignCollectionLayout class. They ensure that the superclass's designated initializer is called properly.
     */
    required override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
     This method is an override of the layoutAttributesForElements(in:) method provided by UICollectionViewFlowLayout. It calculates and returns the layout attributes (position and size) for all the cells and supplementary views within the specified rectangle.
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // This line retrieves the original layout attributes from the superclass (UICollectionViewFlowLayout). If these attributes cannot be obtained, an empty array is returned.
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else {return []}
        
        // Copy each item to prevent "UICollectionViewFlowLayout has cached frame mismatch" warning
        // This line creates a mutable copy of the layout attributes obtained from the superclass. It ensures that modifying the attributes won't affect the original array.
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return [] }
        
        // These variables store the current x and y coordinates for positioning the cells within the collection view. They are initialized with the right section inset and an initial value of -1.0 for y to indicate that no cells have been laid out yet.
        var x: CGFloat = sectionInset.right
        var y: CGFloat = -1.0
        
        // This loop iterates over each layout attribute in the attributes array.
        for a in attributes {
            
            // This condition checks if the layout attribute represents a cell. If it's not a cell, the loop continues to the next iteration.
            if a.representedElementCategory != .cell { continue }
            
            // This condition checks if the current cell is on a new line (i.e., its y coordinate is greater than or equal to the previous cell's maximum y coordinate). If true, it resets the x position to the right section inset to start a new line.
            if a.frame.origin.y >= y { x = sectionInset.right }
            
            // This line sets the x position of the cell's frame to the current x coordinate.
            a.frame.origin.x = x
            
            // This updates the x position for the next cell by adding the cell's width and the minimum interitem spacing (the spacing between adjacent cells in the same line).
            x += a.frame.width + minimumInteritemSpacing
            
            // This updates the y coordinate to the maximum y value of the current cell's frame. It ensures that subsequent cells in the same line are aligned correctly.
            y = a.frame.maxY
        }
        
        // Finally, the modified attributes array is returned as the layout attributes for the collection view cells.
        return attributes
    }
}
