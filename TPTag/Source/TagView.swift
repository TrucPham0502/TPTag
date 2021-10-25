//
//  TagView.swift
//  CalendarDemo
//
//  Created by Truc Pham on 01/09/2021.
//

import Foundation
import UIKit
protocol TagViewDelegate: AnyObject {
    /**
     Chỉnh sửa layout cho Tag.
     - Parameters:
         - tagView: Tag View
         - tag: tag
         - indexPath: Vị trí tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     */
    func tagView(_ tagView : TagView, update tag : TagCollectionViewCell, indexPath : IndexPath, data: TagModel, isSelected : Bool)
    /**
     Xử lý khi Tag được chọn.
     - Parameters:
         - tagView: Tag View
         - tag: tag
         - indexPath: Vị trí tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     */
    func tagView(_ tagView : TagView, tagSeleted tag : TagCollectionViewCell, indexPath : IndexPath, data: TagModel, isSelected : Bool)
    /**
     Xử lý khi layout tag View thay đổi.
     - Parameters:
         - style: Tag View
         - viewShouldResizeTo: size khi thay đổi
     */
    func tagView(_ tagView : TagView, viewShouldResizeTo size : CGSize)
    /**
     Chỉnh sửa style của Tag.
     - Parameters:
         - tagView: Tag View
         - indexPath: Vị trí Tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     */
    func tagView(_ tagView : TagView, textAttribute indexPath : IndexPath , data: TagModel, isSelected : Bool) -> NSAttributedString
    /**
     Thêm view bên trái cho Tag.
     - Parameters:
         - tagView: Tag View
         - indexPath: Vị trí Tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     - Returns: trả về uiview.
     */
    func tagView(_ tagView : TagView, leftView indexPath : IndexPath, data: TagModel, isSelected : Bool) -> UIView?
    /**
     Kích thước của view bên trái.
     - Parameters:
         - tagView: Tag View
         - indexPath: Vị trí Tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     - Returns: trả về size.
     */
    func tagView(_ tagView : TagView, leftViewSize indexPath : IndexPath, data: TagModel, isSelected : Bool) -> CGSize
    /**
     Thêm view bên phải cho Tag.
     - Parameters:
         - tagView: Tag View
         - indexPath: Vị trí Tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     - Returns: trả về uiview.
     */
    func tagView(_ tagView : TagView, rightView indexPath : IndexPath, data: TagModel, isSelected : Bool) -> UIView?
    /**
     Kích thước của view bên phải.
     - Parameters:
         - tagView: Tag View
         - indexPath: Vị trí Tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     - Returns: trả về size.
     */
    func tagView(_ tagView : TagView, rightViewSize indexPath : IndexPath, data: TagModel, isSelected : Bool) -> CGSize
    
    /**
     Font
     - Parameters:
         - tagView: Tag View
         - indexPath: Vị trí Tag
         - data: Data của tag
         - isSelected: Tag có đang được chọn không
     - Returns: trả về size.
     */
    func tagView(_ tagView : TagView, font indexPath : IndexPath, data: TagModel, isSelected : Bool) -> UIFont
}

extension TagViewDelegate {
    func tagView(_ tagView : TagView, leftView indexPath : IndexPath, data: TagModel, isSelected : Bool) -> UIView? {
        let v = UIImageView(image: .init(named: ""))
        v.backgroundColor = .red
        return v
    }
    func tagView(_ tagView : TagView, leftViewSize indexPath : IndexPath, data: TagModel, isSelected : Bool) -> CGSize {
        return isSelected ? .init(width: 14, height: 11) : .zero
    }
    
    func tagView(_ tagView : TagView, rightView indexPath : IndexPath, data: TagModel, isSelected : Bool) -> UIView? {
        return nil
    }
    func tagView(_ tagView : TagView, rightViewSize indexPath : IndexPath, data: TagModel, isSelected : Bool) -> CGSize {
        return .zero
    }
    
    func tagView(_ tagView : TagView, update tag : TagCollectionViewCell, indexPath : IndexPath, data: TagModel, isSelected : Bool) {
        tag.layer.cornerRadius = 18
        tag.layer.borderWidth = 2
        tag.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    func tagView(_ tagView : TagView, tagSeleted tag : TagCollectionViewCell, indexPath : IndexPath, data: TagModel, isSelected : Bool) {
        if isSelected {
            tag.backgroundColor = .yellow
        }
        else {
            tag.backgroundColor = .white
        }
    }
    func tagView(_ tagView : TagView, viewShouldResizeTo size : CGSize) {}
    func tagView(_ tagView : TagView, textAttribute indexPath : IndexPath , data: TagModel, isSelected : Bool) -> NSAttributedString {
        return NSAttributedString(string: data.text, attributes: [.font : self.tagView(tagView, font: indexPath, data: data, isSelected: isSelected), .foregroundColor : UIColor.black])
    }
    func tagView(_ tagView : TagView, font indexPath : IndexPath, data: TagModel, isSelected : Bool) -> UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
}
@IBDesignable
class TagView: UIView {
    enum TagType{
        case none
        case single
        case multiple(Int)
        case all
    }
    private var lastDimension: CGSize?
    
    private var horizontalAlignment : AlignedCollectionHorizontalAlignment = .left
    
    private lazy var collectionView: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: horizontalAlignment, verticalAlignment: .top)
        layout.minimumLineSpacing = self.horizontalTagSpacing
        layout.minimumInteritemSpacing = self.verticalTagSpacing
        layout.sectionInset = containerPadding
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.clear
        view.isScrollEnabled = false
        
        view.register(TagCollectionViewCell.self,
                      forCellWithReuseIdentifier: TagCollectionViewCell.cellIdentifier)
        return view
    }()
    
    private var tags: [TagModel] = []
    
    var delegate: TagViewDelegate?
    
    private var indexSeleted = Set<Int>()
    
    /**
        số lượng tag cho phép chọn.
     */
    var allowSelected : TagType = .single {
        didSet {
            setup()
        }
    }
    
    /**
        kích thước tối đa của tag.
     */
    @IBInspectable
    var tagMaxSize : CGSize = .init(width: UIScreen.main.bounds.width, height: 32){
        didSet {
            setup()
        }
    }
    
    /**
        tag view padding.
     */
    @IBInspectable
    var containerPadding : UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            setup()
        }
    }
    
    /**
        tag padding.
     */
    @IBInspectable
    var tagPadding: UIEdgeInsets = .init(top: 6, left: 12, bottom: 6, right: 12) {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    /**
        horizontal tag spacing.
     */
    @IBInspectable
    var horizontalTagSpacing: CGFloat = 5.0 {
        didSet {
            setup()
        }
    }
    
    /**
        vertical tag spacing.
     */
    @IBInspectable
    var verticalTagSpacing: CGFloat = 5.0 {
        didSet {
            setup()
        }
    }
    
    
    /**
       text number line
     */
    @IBInspectable
    var tagNumberOfLines: Int = 1 {
        didSet {
            reloadData()
        }
    }
    
    // MARK: Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override  func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        
        var size = self.collectionView.collectionViewLayout.collectionViewContentSize
        
        size.width = size.width + self.containerPadding.left + self.containerPadding.right
        size.height = size.height + self.containerPadding.top + self.containerPadding.bottom
        
        return size
    }
    
    override  func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = .init(origin: .init(x: self.containerPadding.left, y: self.containerPadding.top), size: .init(width: self.bounds.width - self.containerPadding.left - self.containerPadding.right, height: self.bounds.height - self.containerPadding.top - self.containerPadding.bottom))
    }
    
    func setup() {
        self.clipsToBounds = true
        self.collectionView.removeFromSuperview()
        self.addSubview(self.collectionView)
    }
    
    func resize() {
        guard let delegate = self.delegate else {
            return
        }
        
        let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
        
        if self.lastDimension != nil {
            if lastDimension!.height != contentSize.height {
                delegate.tagView(self, viewShouldResizeTo: contentSize)
            }
        } else {
            delegate.tagView(self, viewShouldResizeTo: contentSize)
        }
        self.lastDimension = contentSize
    }
    
    
}

extension TagView {
    
    func addTag(tag: TagModel) {
        self.tags.append(tag)
        reloadData()
    }
    
    func addTags(tags: [TagModel]) {
        self.tags.append(contentsOf: tags)
        reloadData()
    }
    
    func removeTag(at index : Int) {
        guard index < self.tags.count, index > -1 else {
            return
        }
        self.tags.remove(at: index)
        self.clearTagSelected(at: index)
    }
    /**
        Xoá tất cả tag.
     */
    func removeAllTag() {
        self.tags.removeAll()
        self.clearAllTagSelected()
    }
    /**
     - Returns : DS data tag.
     */
    func getTags() -> [TagModel] {
        return self.tags
    }
    /**
        Cập nhật lại tag view.
     */
    func reloadData(){
        self.collectionView.reloadData()
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
        resize()
    }
    /**
        get tag view.
         - Parameters:
                - indexPath: vị trí của tag
         - Returns: tag view
     */
    func indexPathForItem(at index : Int) -> TagCollectionViewCell? {
        return self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? TagCollectionViewCell
    }
    
    /**
         - Returns: danh sách vt tag được chọn.
     */
    var tagIndexSelecteds : [Int] {
        return Array(self.indexSeleted)
    }
    /**
        Xoá tất cả các tag được chọn.
     */
    func clearAllTagSelected() {
        self.indexSeleted.removeAll()
        reloadData()
    }
    /**
        Xoá các tag được chọn.
         - Parameters:
                - indexPath: vị trí của tag
     */
    func clearTagSelected(at index : Int) {
        guard index < self.tags.count, index > -1 else {
            return
        }
        self.indexSeleted.remove(index)
        reloadData()
    }
    /**
        Thêm hoặc xoá tag được chọn .
         - Parameters:
                - indexPath: vị trí của tag
     */
    func toggleTagSelected(at index : Int) {
        guard index < self.tags.count, index > -1 else {
            return
        }
        switch allowSelected {
        case let .multiple(number):
            if self.indexSeleted.contains(index) {
                self.indexSeleted.remove(index)
            }
            else if self.indexSeleted.count < number {
                self.indexSeleted.insert(index)
            }
        case .single:
            if let i = self.indexSeleted.popFirst(){
                if let cell = collectionView.cellForItem(at: .init(item: i, section: 0)) as? TagCollectionViewCell {
                    cell._isSelected = false
                }
                if i != index {
                    self.indexSeleted.insert(index)
                }
            }
            else {
                self.indexSeleted.insert(index)
            }
            
        case .all:
            if self.indexSeleted.contains(index) {
                self.indexSeleted.remove(index)
            }
            else {
                self.indexSeleted.insert(index)
            }
        default:
            break
        }
        reloadData()
    }
}

extension TagView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag: TagModel = self.tags[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.cellIdentifier,
                                                      for: indexPath)
        if let cell = cell as? TagCollectionViewCell {
            let isSelected = self.indexSeleted.contains(indexPath.item)
            cell._isSelected = isSelected
            cell.padding = self.tagPadding
            cell.wordLabel.text = tag.text
            if let delegate = self.delegate {
                cell.wordLabel.numberOfLines = self.tagNumberOfLines
                cell.wordLabel.attributedText = delegate.tagView(self, textAttribute: indexPath, data: tag, isSelected: isSelected)
                if let leftView = delegate.tagView(self, leftView: indexPath, data: tag, isSelected: isSelected) {
                    let size = delegate.tagView(self, leftViewSize: indexPath, data: tag, isSelected: isSelected)
                    leftView.frame.size = size
                    cell.leftView = leftView
                    cell.leftViewSize = size
                }
                
                if let rightView = delegate.tagView(self, rightView: indexPath, data: tag, isSelected: isSelected) {
                    let size = delegate.tagView(self, rightViewSize: indexPath, data: tag, isSelected: isSelected)
                    rightView.frame.size = size
                    cell.rightView = rightView
                    cell.rightViewSize = size
                }
                
                cell.didSelected = { c, isSeleted in
                    delegate.tagView(self, tagSeleted: c, indexPath: indexPath, data: tag, isSelected: isSeleted)
                }
                delegate.tagView(self, update: cell, indexPath: indexPath, data: tag, isSelected: isSelected)
            }
            
        }
        return cell
    }
    
    //    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    //        switch allowSelected {
    //        case .single:
    //            if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
    //                cell._isSelected = false
    //                self.indexSeleted.remove(indexPath.item)
    //                reloadData()
    //            }
    //        default:
    //            break
    //        }
    //
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleTagSelected(at: indexPath.item)
    }
}

extension TagView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag: TagModel = self.tags[indexPath.item]
        let isSelected = self.indexSeleted.contains(indexPath.item)
        
        let leftViewSize = self.delegate?.tagView(self, leftViewSize: indexPath, data: tag, isSelected: isSelected) ?? .zero
        let rightViewSize = self.delegate?.tagView(self, rightViewSize: indexPath, data: tag, isSelected: isSelected) ?? .zero
        
        let maxWidth = self.tagMaxSize.width - self.containerPadding.left - self.containerPadding.right - self.tagPadding.left - self.tagPadding.right
        
        
        let wordSize : CGSize = delegate?.tagView(self, textAttribute: indexPath, data: tag, isSelected: isSelected).StringSize(considering: maxWidth - rightViewSize.width - leftViewSize.width) ?? NSAttributedString(string: tag.text, attributes: [.font : self.delegate?.tagView(self, font: indexPath, data: tag, isSelected: isSelected) ?? .systemFont(ofSize: 14)]).StringSize(considering: maxWidth)
        
        var calculatedHeight = CGFloat()
        var calculatedWidth = CGFloat()
        
        calculatedHeight =  min(self.tagPadding.top + max(wordSize.height, leftViewSize.height, rightViewSize.height) + self.tagPadding.bottom, self.tagMaxSize.height)
        calculatedWidth = min(self.tagPadding.left + wordSize.width + leftViewSize.width + rightViewSize.width + self.tagPadding.right, maxWidth)
        
        return CGSize(width: calculatedWidth, height: calculatedHeight)
    }
}

protocol TagModel  {
    var id : String { get }
    var text: String { get }
}


struct TagDefault : TagModel {
    var id: String = UUID().uuidString
    var text: String
}

extension NSAttributedString {
    func StringSize(considering maxWidth: CGFloat = UIScreen.main.bounds.width) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        return rect.size
    }
}
