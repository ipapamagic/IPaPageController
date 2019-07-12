//
//  IPaCollectionViewPageController.swift
//  IPaPageController
//
//  Created by IPa Chen on 2018/10/29.
//

import UIKit
@objc public protocol IPaCollectionViewPageControllerDelegate {
    func collectionView(for pageController:IPaCollectionViewPageController) -> UICollectionView
    func createLoadingCell(for pageController:IPaCollectionViewPageController, indexPath:IndexPath) -> UICollectionViewCell
    func createDataCell(for pageController:IPaCollectionViewPageController, indexPath:IndexPath) -> UICollectionViewCell

    func loadData(for pageController:IPaCollectionViewPageController,  page:Int, complete:@escaping ([Any],Int,Int)->())
    func configureCell(for pageController:IPaCollectionViewPageController,cell:UICollectionViewCell,indexPath:IndexPath,data:Any)
    func configureLoadingCell(for pageController:IPaCollectionViewPageController,cell:UICollectionViewCell,indexPath:IndexPath)
    
}

public class IPaCollectionViewPageController: IPaPageController {
    var hasLoadingCell = false
    @objc open var delegate:IPaCollectionViewPageControllerDelegate!
    @objc open override func reloadAllData() {
        super.reloadAllData()
        let collectionView = delegate.collectionView(for: self)
        collectionView.reloadData()
    }
    override func loadData(page:Int, complete:@escaping ([Any],Int,Int)->())
    {
        delegate.loadData(for:self, page: currentLoadingPage, complete:complete)
    }
    override open func updateUI(startRow:Int,newDataCount:Int,newIndexList:[IndexPath]) {
        let collectionView = delegate.collectionView(for: self)
        collectionView.reloadData()
        
    }
    @objc open func isLoadingCell(_ indexPath:IndexPath) -> Bool {
        return Bool(indexPath.item == datas.count && currentPage != totalPageNum)
    }
    @objc open func isNoDataCell(_ indexPath:IndexPath) -> Bool {
        return Bool(indexPath.item == 0 && datas.count == 0 && currentPage == totalPageNum && totalPageNum == 1)
    }
}

extension IPaCollectionViewPageController: UICollectionViewDataSource {
    //MARK: UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if currentPage == totalPageNum {
            return datas.count
        }
        hasLoadingCell = true
        return datas.count + 1
    }
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell:UICollectionViewCell
        if isLoadingCell(indexPath) {
            cell = delegate.createLoadingCell(for:self, indexPath: indexPath)
            self.loadNextPage()
            delegate.configureLoadingCell(for:self, cell: cell, indexPath: indexPath)
        }
        else {
            cell = delegate.createDataCell(for:self, indexPath: indexPath)
            delegate.configureCell(for:self, cell: cell, indexPath: indexPath, data: datas[indexPath.row])
        }
        return cell
    }
    
}
