//
//  ViewController.swift
//  HQListView
//
//  Created by arcangelw on 09/07/2022.
//  Copyright (c) 2022 arcangelw. All rights reserved.
//

import MJRefresh
import SnapKit
import StockListView
import Then
import UIKit

extension UIColor {
    /// Random color.
    static var random: UIColor {
        UIColor(
            red: CGFloat.random(in: 0.0 ... 255.0) / 255.0,
            green: CGFloat.random(in: 0.0 ... 255.0) / 255.0,
            blue: CGFloat.random(in: 0.0 ... 255.0) / 255.0,
            alpha: 1.0
        )
    }
}

struct Item {
    let index: Int
}

let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]

final class Cell: UICollectionViewCell, StockListView.CellType {
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .random
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(snp.centerY)
            make.left.equalTo(15)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(itemModel: Any) {
        assert(itemModel is Item)
        let item = itemModel as! Item // swiftlint:disable:this force_cast
        titleLabel.text = "index: \(item.index)"
        contentView.backgroundColor = colors[item.index % colors.count]
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func itemDidAppear() {}

    func itemDidDisappear() {}
}

final class Menu: UICollectionReusableView, StockListView.ViewType {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .darkGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func visualOffsetChange(_ offset: CGFloat) {
        debugPrint("Menu offset: \(offset)")
    }

    func itemDidAppear() {}

    func itemDidDisappear() {}
}

class ViewController: UIViewController, ListViewDataSource, ListViewDelegate {

    private var num = 20

    private let listView = StockListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        listView.register(cellType: Cell.self, for: .freeze)
        listView.register(cellType: Cell.self, for: .active)
        listView.register(viewType: Menu.self, for: .freeze)
        listView.register(viewType: Menu.self, for: .active)
        listView.options.marginInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        listView.options.freezeWidth = 100
        listView.options.activeWidth = view.frame.width
        listView.options.rowSpacing = 10
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        listView.delegate = self
        listView.dataSource = self
        listView.reloadData()
        listView.scrollView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadMore()
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listView.listViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listView.listViewDidDisappear()
    }

    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.num += 20
            self.listView.reloadData()
            self.listView.scrollView.mj_footer?.endRefreshing()
        }
    }

    func numberOfItems(in _: StockListView) -> Int {
        num
    }

    func listView(_: StockListView, itemModelAt index: Int) -> Any? {
        return Item(index: index)
    }

    func listView(_: StockListView, didSelectListAt _: Int) {
        debugPrint("\(#function)")
        let control = ViewController()
        navigationController?.pushViewController(control, animated: true)
    }

    func listView(
        _ listView: StockListView,
        menuViewOfKind kind: StockListView.Kind,
        visualOffsetChange offset: CGFloat
    ) {
        debugPrint("visualOffsetChange \(offset) for kind: \(kind)")
    }
}
