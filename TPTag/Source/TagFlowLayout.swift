//
//  TagFlowLayout.swift
//  CalendarDemo
//
//  Created by Truc Pham on 27/08/2021.
//

import Foundation
import UIKit
protocol TagCellLayoutDelegate : AnyObject {
    
}
protocol AlignedCollectionAlignment {}
struct AlignmentAxis<A: AlignedCollectionAlignment> {
    let alignment: A
    let position: CGFloat
}
enum AlignedCollectionHorizontalAlignment : AlignedCollectionAlignment{
    case left
    case justified
    case right
}
enum AlignedCollectionVerticalAlignment : AlignedCollectionAlignment{
    case top
    case center
    case bottom
}
class AlignedCollectionViewFlowLayout : UICollectionViewFlowLayout {
    
    
    weak var tagCellLayoutDelegate : TagCellLayoutDelegate? = nil
    var horizontalAlignment: AlignedCollectionHorizontalAlignment = .justified
    var verticalAlignment: AlignedCollectionVerticalAlignment = .center
    fileprivate var alignmentAxis: AlignmentAxis<AlignedCollectionHorizontalAlignment>? {
        switch horizontalAlignment {
        case .left:
            return AlignmentAxis(alignment: AlignedCollectionHorizontalAlignment.left, position: sectionInset.left)
        case .right:
            guard let collectionViewWidth = collectionView?.frame.size.width else {
                return nil
            }
            return AlignmentAxis(alignment: AlignedCollectionHorizontalAlignment.right, position: collectionViewWidth - sectionInset.right)
        default:
            return nil
        }
    }
    private var contentWidth: CGFloat? {
        guard let collectionViewWidth = collectionView?.frame.size.width else {
            return nil
        }
        return collectionViewWidth - sectionInset.left - sectionInset.right
    }
    init(horizontalAlignment: AlignedCollectionHorizontalAlignment = .justified, verticalAlignment: AlignedCollectionVerticalAlignment = .center) {
        super.init()
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        if horizontalAlignment != .justified {
            layoutAttributes.alignHorizontally(collectionViewLayout: self)
        }
        if verticalAlignment != .center {
            layoutAttributes.alignVertically(collectionViewLayout: self)
        }
        return layoutAttributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // We may not change the original layout attributes or UICollectionViewFlowLayout might complain.
        let layoutAttributesObjects = copy(super.layoutAttributesForElements(in: rect))
        layoutAttributesObjects?.forEach({ (layoutAttributes) in
            setFrame(forLayoutAttributes: layoutAttributes)
        })
        return layoutAttributesObjects
    }
    
    private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
    }
    
    private func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.representedElementCategory == .cell { // Do not modify header views etc.
            let indexPath = layoutAttributes.indexPath
            if let newFrame = layoutAttributesForItem(at: indexPath)?.frame {
                layoutAttributes.frame = newFrame
            }
        }
    }
    
    
    fileprivate func originalLayoutAttribute(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    
    /// kiem tra 2 item cung nam tren 1 line
    fileprivate func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes, inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let lineWidth = contentWidth else {
            return false
        }
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(x: sectionInset.left,
                               y: firstItemFrame.origin.y,
                               width: lineWidth,
                               height: firstItemFrame.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }
    
    /// lay danh sach item nam tren line frame
    fileprivate func layoutAttributes(forItemsInLineWith layoutAttributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
        guard let lineWidth = contentWidth else {
            return [layoutAttributes]
        }
        var lineFrame = layoutAttributes.frame
        lineFrame.origin.x = sectionInset.left
        lineFrame.size.width = lineWidth
        return super.layoutAttributesForElements(in: lineFrame) ?? []
    }
    
    fileprivate func verticalAlignmentAxis(for currentLayoutAttributes: UICollectionViewLayoutAttributes) -> AlignmentAxis<AlignedCollectionVerticalAlignment>? {
        let layoutAttributesInLine = layoutAttributes(forItemsInLineWith: currentLayoutAttributes)
        // It's okay to force-unwrap here because we pass a non-empty array.
        return verticalAlignmentAxisForLine(with: layoutAttributesInLine)
    }
    
    private func verticalAlignmentAxisForLine(with layoutAttributes: [UICollectionViewLayoutAttributes]) -> AlignmentAxis<AlignedCollectionVerticalAlignment>? {
        
        guard let firstAttribute = layoutAttributes.first else {
            return nil
        }
        
        switch verticalAlignment {
        case .top:
            let minY = layoutAttributes.reduce(CGFloat.greatestFiniteMagnitude) { min($0, $1.frame.minY) }
            return AlignmentAxis(alignment: .top, position: minY)
            
        case .bottom:
            let maxY = layoutAttributes.reduce(0) { max($0, $1.frame.maxY) }
            return AlignmentAxis(alignment: .bottom, position: maxY)
            
        default:
            let centerY = firstAttribute.center.y
            return AlignmentAxis(alignment: .center, position: centerY)
        }
    }
}
fileprivate extension UICollectionViewLayoutAttributes {
    
    private var currentSection: Int {
        return indexPath.section
    }
    
    private var currentItem: Int {
        return indexPath.item
    }
    
    /// The index path for the item preceding the item represented by this layout attributes object.
    private var precedingIndexPath: IndexPath {
        return IndexPath(item: currentItem - 1, section: currentSection)
    }
    
    /// The index path for the item following the item represented by this layout attributes object.
    private var followingIndexPath: IndexPath {
        return IndexPath(item: currentItem + 1, section: currentSection)
    }
    
    /// kiem tra co item phia truoc tren cung 1 dong voi item hien tai hay khong
    func isRepresentingFirstItemInLine(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
        if currentItem <= 0 {
            return true
        }
        else {
            if let layoutAttributesForPrecedingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: precedingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForPrecedingItem)
            }
            else {
                return true
            }
        }
    }
    
    /// kiem tra co item phia sau tren cung 1 dong voi item hien tai hay khong
    func isRepresentingLastItemInLine(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
        guard let itemCount = collectionViewLayout.collectionView?.numberOfItems(inSection: currentSection) else {
            return false
        }
        
        if currentItem >= itemCount - 1 {
            return true
        }
        else {
            if let layoutAttributesForFollowingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: followingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForFollowingItem)
            }
            else {
                return true
            }
        }
    }
    
    /// set  origin horizontally cho item dau tien tren dong
    func align(toAlignmentAxis alignmentAxis: AlignmentAxis<AlignedCollectionHorizontalAlignment>) {
        switch alignmentAxis.alignment {
        case .left:
            frame.origin.x = alignmentAxis.position
        case .right:
            frame.origin.x = alignmentAxis.position - frame.size.width
        default:
            break
        }
    }
    
    ///set  origin Vertical cho item dau tien tien tren dong
    func align(toAlignmentAxis alignmentAxis: AlignmentAxis<AlignedCollectionVerticalAlignment>) {
        switch alignmentAxis.alignment {
        case .top:
            frame.origin.y = alignmentAxis.position
        case .bottom:
            frame.origin.y = alignmentAxis.position - frame.size.height
        default:
            center.y = alignmentAxis.position
        }
    }
    
    /// set frame origin x cho item hien tai khi truoc no co 1 item khac
    private func alignToPrecedingItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
            frame.origin.x = precedingItemAttributes.frame.maxX + itemSpacing
        }
    }
    
    /// Positions the frame left of the following item's frame, leaving a spacing between the frames
    /// as defined by the collection view layout's `minimumInteritemSpacing`.
    ///
    /// - Parameter collectionViewLayout: The layout on which to perfom the calculations.
    private func alignToFollowingItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
            frame.origin.x = followingItemAttributes.frame.minX - itemSpacing - frame.size.width
        }
    }
    
    /// set frame horizontally
    func alignHorizontally(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        
        guard let alignmentAxis = collectionViewLayout.alignmentAxis else {
            return
        }
        
        switch collectionViewLayout.horizontalAlignment {
            
        case .left:
            if isRepresentingFirstItemInLine(collectionViewLayout: collectionViewLayout) {
                align(toAlignmentAxis: alignmentAxis)
            } else {
                alignToPrecedingItem(collectionViewLayout: collectionViewLayout)
            }
            
        case .right:
            if isRepresentingLastItemInLine(collectionViewLayout: collectionViewLayout) {
                align(toAlignmentAxis: alignmentAxis)
            } else {
                alignToFollowingItem(collectionViewLayout: collectionViewLayout)
            }
            
        default:
            return
        }
    }
    
    /// set frame vertically  `verticalAlignment`.
    ///
    /// - Parameter collectionViewLayout: The layout providing the alignment information.
    func alignVertically(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        if let alignmentAxis = collectionViewLayout.verticalAlignmentAxis(for: self) {
            align(toAlignmentAxis: alignmentAxis)
        }
    }
    
}
