//
//  TagCollectionViewCell.swift
//  CalendarDemo
//
//  Created by Truc Pham on 01/09/2021.
//

import Foundation
import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "TagCollectionViewCell"
    var didSelected : (TagCollectionViewCell, Bool) -> () = {_,_ in }
    
    var paddingLeftConstraint: NSLayoutConstraint?
    var paddingRightConstraint: NSLayoutConstraint?
    var paddingTopConstraint: NSLayoutConstraint?
    var paddingBottomConstraint: NSLayoutConstraint?
    var heightLeftView: NSLayoutConstraint?
    var widthtLeftView: NSLayoutConstraint?
    var heightRightView: NSLayoutConstraint?
    var widthtRightView: NSLayoutConstraint?
    
    private lazy var _leftView : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var _rightView : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    lazy var wordLabel : UILabel = {
        let lbl = UILabel()
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 14)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var _isSelected : Bool = false {
        didSet {
            didSelected(self, _isSelected)
        }
    }
    
    var leftView : UIView? = nil {
        didSet {
            guard let v = self.leftView else {
                return
            }
            self._leftView.subviews.forEach({ $0.removeFromSuperview()})
            self._leftView.addSubview(v)
        }
    }
    
    var rightView : UIView? = nil {
        didSet {
            guard let v = self.rightView else {
                return
            }
            self._rightView.subviews.forEach({ $0.removeFromSuperview()})
            self._rightView.addSubview(v)
        }
    }
    
    
    var hashtag: TagModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var padding : UIEdgeInsets = .zero {
        didSet {
            self.paddingLeftConstraint?.constant = padding.left
            self.paddingTopConstraint?.constant = padding.top
            self.paddingBottomConstraint?.constant = -1 * padding.bottom
            self.paddingRightConstraint?.constant = -1 * padding.right
        }
    }
    
    var leftViewSize : CGSize = .zero {
        didSet {
            self._leftView.isHidden = leftViewSize == .zero
            self.widthtLeftView?.constant = leftViewSize.width
            self.heightLeftView?.constant = leftViewSize.height
        }
    }
    var rightViewSize : CGSize = .zero {
        didSet {
            self._rightView.isHidden = rightViewSize == .zero
            self.widthtRightView?.constant = rightViewSize.width
            self.heightRightView?.constant = rightViewSize.height
        }
    }
   
    
    func setup() {
        self.clipsToBounds = true
        [_leftView, _rightView, wordLabel].forEach({
            self.addSubview($0)
        })
        // Padding left
        self.paddingLeftConstraint = self._leftView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        // Padding top
        self.paddingTopConstraint = self.wordLabel.topAnchor.constraint(equalTo: self.topAnchor)
        // Padding bottom
        self.paddingBottomConstraint = self.wordLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        // Padding right
        self.paddingRightConstraint = self._rightView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        
        self.heightLeftView = self._leftView.heightAnchor.constraint(equalToConstant: 0)
        self.widthtLeftView = self._leftView.widthAnchor.constraint(equalToConstant: 0)
        
        self.heightRightView = self._rightView.heightAnchor.constraint(equalToConstant: 0)
        self.widthtRightView = self._rightView.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            self.wordLabel.leadingAnchor.constraint(equalTo: self._leftView.trailingAnchor),
            self.paddingTopConstraint!,
            self.paddingBottomConstraint!,
            self.wordLabel.trailingAnchor.constraint(equalTo: self._rightView.leadingAnchor),
            
            self.paddingLeftConstraint!,
            self.paddingRightConstraint!,
            
            self._leftView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.heightLeftView!,
            self.widthtLeftView!,
            self._rightView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.heightRightView!,
            self.widthtRightView!
            
//            self._leftView.bottomAnchor.constraint(equalTo: self.wordLabel.bottomAnchor),
//            self._rightView.bottomAnchor.constraint(equalTo: self.wordLabel.bottomAnchor)
            
        ])
        self.backgroundColor = .clear
    }
    
    override func prepareForInterfaceBuilder() {
        self.wordLabel.text = ""
        super.prepareForInterfaceBuilder()
    }
    
    func configureWithTag(tag: TagModel) {
        self.hashtag = tag
        wordLabel.text = tag.text
    }
    
    
}
