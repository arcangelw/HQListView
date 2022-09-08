//
//  ListViewProvider.swift
//  HQListView
//
//  Created by 吴哲 on 2022/9/8.
//

import Foundation
import UIKit

/// 数据绑定
public protocol ListViewDataSourceProvider: AnyObject {
    func bind(itemModel: Any)
}

/// 事件代理
public protocol ListViewDelegateProvider: AnyObject {
    func prepareForReuse()
    func itemDidAppear()
    func itemDidDisappear()
}

/// 菜单栏可视化
public protocol ListViewMenuDelegateProvider: ListViewDelegateProvider {
    /// 可视范围变化
    func visualOffsetChange(_ offset: CGFloat)
}

/// 数据源
public protocol ListViewDataSource: AnyObject {
    func numberOfItems(in listView: StockListView) -> Int
    func listView(_ listView: StockListView, itemModelAt index: Int) -> Any?
}

/// 代理
public protocol ListViewDelegate: UIScrollViewDelegate {
    func listView(_ listView: StockListView, didSelectListAt index: Int)
    /// 可视范围变化
    func listView(_ listView: StockListView, menuViewOfKind kind: StockListView.Kind, visualOffsetChange offset: CGFloat) // swiftlint:disable:this line_length
}
