//
//  ViewController.swift
//  TPTag
//
//  Created by Truc Pham on 21/10/2021.
//

import UIKit

class ViewController: UIViewController {
    lazy var tags: TagView = {
        let tags = TagView()
        tags.backgroundColor = .yellow
//        tags.delegate = self
        tags.allowSelected = .single
        tags.tagNumberOfLines = -1
        tags.containerPadding = .init(top: 20, left: 10, bottom: 20, right: 10)
        tags.translatesAutoresizingMaskIntoConstraints = false
        return tags
    }()
    lazy var button : UIButton = {
        let v = UIButton()
        v.setTitle("add", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.tags)
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            tags.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tags.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tags.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            tags.widthAnchor.constraint(equalTo: self.view.widthAnchor),

            button.topAnchor.constraint(equalTo: self.tags.bottomAnchor),
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        tags.addTags(tags: [TagDefault(text: "hasdad"),TagDefault(text: "cong hoa xa hoi chu nghia viet nam doc lap tu do hanh phuc cong hoa xa hoi chu nghia viet nam doc lap tu do hanh phuc cong hoa xa hoi chu nghia viet nam doc lap tu do hanh phuc cong hoa xa hoi chu nghia viet nam doc lap tu do hanh phuc cong hoa xa hoi chu nghia viet nam doc lap tu do hanh phuc phuc")])
        
    }
    @objc func buttonTap(_ sender : Any?) {
        print(self.tags.tagIndexSelecteds)
        self.tags.addTag(tag: TagDefault(text: "button add"))
    }

}

extension ViewController : TagViewDelegate {
    func tagView(_ tagView: TagView, font indexPath: IndexPath, data: TagModel, isSelected: Bool) -> UIFont {
        return .systemFont(ofSize: 34)
    }
}
