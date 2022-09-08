//
//  NestListView.swift
//  HQListView
//
//  Created by 吴哲 on 2022/9/8.
//

import Then
import UIKit

/// 嵌套列表视图
final class NestListView: UIView {

    weak var dataSource: ListViewDataSource?
    weak var delegate: ListViewDelegate?
    private weak var listView: StockListView!
    private let kind: StockListView.Kind
    private(set) var options: NestOptions

    private var viewType: StockListView.ViewType.Type?
    private var cellType: StockListView.CellType.Type?

    /// layout
    private(set) lazy var collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 0
    }

    /// 列表
    private(set) lazy var collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: collectionViewLayout
    ).then {
        $0.backgroundColor = .clear
        $0.scrollsToTop = false
        $0.bounces = false
        $0.alwaysBounceHorizontal = false
        $0.alwaysBounceVertical = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.contentInsetAdjustmentBehavior = .never
    }

    /// 容器
    private(set) lazy var containerScrollView = UIScrollView().then {
        $0.backgroundColor = .clear
        $0.isPagingEnabled = false
        $0.scrollsToTop = false
        $0.bounces = true
        $0.showsHorizontalScrollIndicator = true
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.contentInsetAdjustmentBehavior = .never
    }

    private var observe: NSKeyValueObservation?

    init(options: NestOptions, listView: StockListView, kind: StockListView.Kind) {
        self.options = options
        self.kind = kind
        super.init(frame: .zero)
        self.listView = listView
        backgroundColor = .clear
        addSubview(containerScrollView)
        collectionView.delegate = self
        collectionView.dataSource = self
        containerScrollView.addSubview(collectionView)
        observe = containerScrollView.observe(
            \.contentOffset,
            options: [.old, .new],
            changeHandler: { [weak self] _, change in
                guard
                    let self = self,
                    let oldOffset = change.oldValue?.x,
                    let newOffset = change.newValue?.x,
                    oldOffset != newOffset
                else { return }
                self.containerScrolling(newOffset)
            }
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        observe?.invalidate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func containerScrolling(_ offset: CGFloat) {
        collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
            .forEach { view in
                (view as? StockListView.ViewType)?.visualOffsetChange(offset)
            }
        delegate?.listView(listView, menuViewOfKind: kind, visualOffsetChange: offset)
    }

    /// 父视图布局修正
    func layoutFix(options: NestOptions) {
        self.options = options
        scrollingFix(options: options)
        if viewType != nil {
            collectionViewLayout.sectionHeadersPinToVisibleBounds = options.menuPinToVisibleBounds
            collectionViewLayout.headerReferenceSize = options.menuSize
        }
        collectionViewLayout.itemSize = options.itemSize
        collectionViewLayout.minimumLineSpacing = options.rowSpacing
        collectionViewLayout.invalidateLayout()
    }

    /// 滚动过程修正
    func scrollingFix(options: NestOptions) {
        frame = options.frame
        containerScrollView.frame = bounds
        containerScrollView.contentSize = options.contentSize
        collectionView.frame = options.nestListFrame
    }

    func viewDidAppear() {
        collectionView.visibleCells.forEach { cell in
            (cell as? StockListView.CellType)?.itemDidAppear()
        }
        collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
            .forEach { view in
                (view as? StockListView.ViewType)?.itemDidAppear()
            }
    }

    func viewDidDisappear() {
        collectionView.visibleCells.forEach { cell in
            (cell as? StockListView.CellType)?.itemDidDisappear()
        }
        collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
            .forEach { view in
                (view as? StockListView.ViewType)?.itemDidDisappear()
            }
    }

    final func register<T: UICollectionViewCell>(cellType: T.Type) where T: StockListView.CellType {
        self.cellType = cellType
        collectionView.register(cellType.self, forCellWithReuseIdentifier: String(reflecting: cellType))
    }

    final func register<T: UICollectionReusableView>(viewType: T.Type) where T: StockListView.ViewType {
        self.viewType = viewType
        collectionView.register(
            viewType.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(reflecting: viewType)
        )
        collectionViewLayout.sectionHeadersPinToVisibleBounds = options.menuPinToVisibleBounds
        collectionViewLayout.headerReferenceSize = options.menuSize
    }

    final func reloadData() {
        collectionView.reloadData()
    }
}

extension NestListView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource?.numberOfItems(in: listView) ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cellType = cellType else {
            fatalError("must register cellType")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(reflecting: cellType), for: indexPath)
        if let itemModel = dataSource?.listView(listView, itemModelAt: indexPath.item) {
            (cell as? StockListView.CellType)?.bind(itemModel: itemModel)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let viewType = viewType else {
            fatalError("only register elementKindSectionHeader")
        }
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(reflecting: viewType),
            for: indexPath
        )
        return view
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? StockListView.CellType)?.itemDidAppear()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? StockListView.CellType)?.itemDidDisappear()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        (view as? StockListView.ViewType)?.itemDidAppear()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        (view as? StockListView.ViewType)?.itemDidDisappear()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate?.listView(listView, didSelectListAt: indexPath.item)
    }
}
