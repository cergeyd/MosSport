//
//  TableViewCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import UIKit

class TableViewCell: UITableViewCell {

    public static var identifier: String { return String(describing: self) }
    lazy var arrowIcon: UIImageView = {
        var icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.image = R.image.arrowIcon()
        return icon
    }()
    lazy var separatorView: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        view.backgroundColor = #colorLiteral(red: 0.9102228284, green: 0.9129777551, blue: 0.947078526, alpha: 1)
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpLayout()
        self.selectionStyle = .none
        self.backgroundColor = AppStyle.color(for: .background)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    //MARK: Liecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.contentView.backgroundColor = .white
        self.backgroundColor = .white
    }

//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        self.contentView.backgroundColor = .white
//        self.backgroundColor = .white
//    }

    open func setUpLayout() {

    }

    //MARK: Func

}
