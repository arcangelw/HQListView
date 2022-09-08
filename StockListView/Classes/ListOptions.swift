//
//  ListOptions.swift
//  Pods
//
//  Created by 吴哲 on 2022/9/7.
//

import Foundation

/// 嵌套容器配置
struct NestOptions {
    /// 位置
    var frame: CGRect = .zero {
        didSet {
            fix(rect: frame)
        }
    }

    /// 内容宽度
    var contentWidth: CGFloat = 0 {
        didSet {
            fix(rect: frame)
        }
    }

    /// 冻结菜单栏
    var menuPinToVisibleBounds: Bool = true
    /// 菜单Size
    var menuSize: CGSize = .zero
    /// 列表Size
    var itemSize: CGSize = .zero
    /// 列表行间距
    var rowSpacing: CGFloat = 0
    /// 内边距
    var inset: UIEdgeInsets = .zero
    /// 容器尺寸
    private(set) var contentSize: CGSize = .zero
    private(set) var nestListFrame: CGRect = .zero
    mutating func fix(rect: CGRect) {
        contentSize = .init(width: max(rect.width, contentWidth), height: rect.height)
        nestListFrame = .init(origin: .zero, size: .init(width: contentWidth, height: rect.height))
    }
}

/// 列表参数
public struct ListOptions {
    /// 外边距
    public var marginInset: UIEdgeInsets = .zero
    /// 内边距
    // public var paddingInset: UIEdgeInsets = .zero
    /// 冻结菜单栏
    public var menuPinToVisibleBounds: Bool = true
    /// 菜单高度
    public var menuHeight: CGFloat = 50
    /// 冻结列表和活动列表之间的间距
    public var spacing: CGFloat = 0
    /// 列表行间距
    public var rowSpacing: CGFloat = 0
    /// 列表行高
    public var rowHeight: CGFloat = 44
    /// 冻结列宽度
    public var freezeWidth: CGFloat = 100
    /// 活动宽度
    public var activeWidth: CGFloat = 0

    public init() {}

    /// 内部视图展示区域
    private(set) var visableRect: CGRect = .zero
    /// 冻结列表参数
    var freezeOptions: NestOptions = .init()
    /// 活动列表参数
    var activeOptions: NestOptions = .init()

    mutating func fix(rect: CGRect) {
        let fixRect = rect.inset(by: marginInset)
        visableRect = fixRect
        /// 计算冻结列表
        let freezeFrame: CGRect = .init(
            x: fixRect.minX, y: fixRect.minY,
            width: freezeWidth, height: fixRect.height
        )
        freezeOptions.menuPinToVisibleBounds = menuPinToVisibleBounds
        freezeOptions.frame = freezeFrame
        freezeOptions.contentWidth = freezeWidth
        freezeOptions.menuSize = .init(width: freezeWidth, height: menuHeight)
        freezeOptions.itemSize = .init(width: freezeWidth, height: rowHeight)
        freezeOptions.rowSpacing = rowSpacing
        /// 计算活动列表
        let activeLeft = freezeFrame.maxX + spacing
        /// 容器
        let activeContainerWidth = fixRect.maxX - activeLeft
        let activeFrame: CGRect = .init(
            x: activeLeft, y: fixRect.minY,
            width: activeContainerWidth, height: fixRect.height
        )
        activeOptions.menuPinToVisibleBounds = menuPinToVisibleBounds
        activeOptions.frame = activeFrame
        activeOptions.contentWidth = activeWidth
        activeOptions.menuSize = .init(width: activeWidth, height: menuHeight)
        activeOptions.itemSize = .init(width: activeWidth, height: rowHeight)
        activeOptions.rowSpacing = rowSpacing
    }
}
