//
//  HQListView.swift
//
//
//  Created by 吴哲 on 2022/9/7.
//

import Then
import UIKit

extension StockListView {
    public typealias ViewType = ListViewMenuDelegateProvider
    public typealias CellType = ListViewDataSourceProvider & ListViewDelegateProvider

    public enum Kind {
        /// 冻结列表
        case freeze
        /// 活跃列表
        case active
    }
}

open class StockListView: UIView {

    public weak var dataSource: ListViewDataSource? {
        didSet {
            freezeListView.dataSource = dataSource
            activeListView.dataSource = dataSource
        }
    }

    public weak var delegate: ListViewDelegate? {
        didSet {
            freezeListView.delegate = delegate
            activeListView.delegate = delegate
        }
    }

    public private(set) lazy var scrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.scrollsToTop = true
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.backgroundColor = .clear
    }

    /// 冻结列表
    private lazy var freezeListView = NestListView(options: options.freezeOptions, listView: self, kind: .freeze)

    /// 活动列表
    private lazy var activeListView = NestListView(options: options.activeOptions, listView: self, kind: .active)

    private lazy var observes: [NSKeyValueObservation] = []

    public var options: ListOptions

    public init(options: ListOptions = ListOptions()) {
        self.options = options
        super.init(frame: .zero)
        setUpView()
    }

    public required init?(coder: NSCoder) {
        options = .init()
        super.init(coder: coder)
        setUpView()
    }

    deinit {
        for observe in observes {
            observe.invalidate()
        }
        observes.removeAll()
    }

    private func setUpView() {
        backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(scrollView)
        scrollView.addSubview(freezeListView)
        scrollView.addSubview(activeListView)
        setUpNestedScrollingMode()
    }

    private func setUpNestedScrollingMode() {
        observes.append(scrollView.observe(\.contentOffset, options: [.old, .new], changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            self.layoutNestScrollingList()
        }))
        observes.append(scrollView.observe(\.contentSize, options: [.old, .new], changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            self.layoutNestScrollingList()
        }))
        observes.append(freezeListView.collectionView.observe(
            \.contentSize,
            options: [.old, .new],
            changeHandler: { [weak self] _, change in
                guard let self = self, let newSize = change.newValue else { return }
                self.layoutContainerScrollView(contentSize: newSize)
            }
        ))
        observes.append(activeListView.collectionView.observe(
            \.contentSize,
            options: [.old, .new],
            changeHandler: { [weak self] _, change in
                guard let self = self, let newSize = change.newValue else { return }
                self.layoutContainerScrollView(contentSize: newSize)
            }
        ))
    }

    /// 设置容器
    private func layoutContainerScrollView(contentSize: CGSize) {
        var targetSize = scrollView.frame.size
        targetSize.height = max(contentSize.height, targetSize.height)
        scrollView.contentSize = targetSize
        bringScrollViewIndicatorToFront()
    }

    private func layoutNestScrollingList() {
        for listView in [freezeListView, activeListView] {
            var listOptions = listView.options
            let subScrollViewContentHeight = listView.collectionView.contentSize.height
            let subScrollViewOriginalTop = options.visableRect.minY
            let subScrollViewTopLine = subScrollViewOriginalTop
            let subScrollViewBottomLine = subScrollViewOriginalTop + subScrollViewContentHeight
            /// 更新计算新的frame
            var viewFrame = listOptions.frame
            let scrollOffsetY = scrollView.contentOffset.y
            var targetTop = scrollOffsetY
            var targetHeight = viewFrame.height
            if targetTop < subScrollViewTopLine {
                /// 小于原始位置的，保持在原始位置
                targetTop = subScrollViewTopLine
            } else if targetTop + viewFrame.height > subScrollViewBottomLine {
                /// 始终保持在可视范围内, 超过实际值修正计算高度
                targetTop = scrollOffsetY
                targetHeight = max(0, subScrollViewBottomLine - targetTop)
            }
            /// 调整view的frame
            viewFrame.origin.y = targetTop
            viewFrame.size.height = targetHeight
            listOptions.frame = viewFrame
            listView.scrollingFix(options: listOptions)

            /// contentOffset
            let verticalInset = listView.collectionView.contentInset.top + listView.collectionView.contentInset.bottom
            let originalLastTargetTop = subScrollViewBottomLine - viewFrame.height
            let targetOffsetY = min(
                max(0, scrollOffsetY - subScrollViewOriginalTop),
                (subScrollViewContentHeight + verticalInset) - listView.frame.height
            ) + max(targetTop - originalLastTargetTop, 0)
            listView.collectionView.setContentOffset(
                .init(x: listView.collectionView.contentOffset.x, y: targetOffsetY),
                animated: false
            )
        }
    }

    /// bringScrollViewIndicatorToFront
    private func bringScrollViewIndicatorToFront() {
        var indicatorClass: AnyClass?
        if #available(iOS 13, *) {
            indicatorClass = NSClassFromString(String(format: "%@%@%@", "_UIScrollViewSc", "rollIn", "dicator"))
        } else {
            indicatorClass = UIImageView.self
        }
        guard let indicatorClass = indicatorClass else {
            return
        }
        for subView in scrollView.subviews {
            if type(of: subView) == indicatorClass {
                scrollView.bringSubviewToFront(subView)
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        options.fix(rect: bounds)
        freezeListView.layoutFix(options: options.freezeOptions)
        activeListView.layoutFix(options: options.activeOptions)
    }

    public func listViewDidAppear() {
        freezeListView.viewDidAppear()
        activeListView.viewDidAppear()
    }

    public func listViewDidDisappear() {
        freezeListView.viewDidDisappear()
        activeListView.viewDidDisappear()
    }

    public final func register<T: UICollectionViewCell>(cellType: T.Type, for kind: Kind) where T: CellType {
        switch kind {
        case .freeze:
            freezeListView.register(cellType: cellType)
        case .active:
            activeListView.register(cellType: cellType)
        }
    }

    public final func register<T: UICollectionReusableView>(viewType: T.Type, for kind: Kind) where T: ViewType {
        switch kind {
        case .freeze:
            freezeListView.register(viewType: viewType)
        case .active:
            activeListView.register(viewType: viewType)
        }
    }

    public final func reloadData() {
        freezeListView.reloadData()
        activeListView.reloadData()
    }
}
