//
//  IPaPageController.swift
//  IPaPageController
//
//  Created by IPa Chen on 2018/10/29.
//

import UIKit

open class IPaPageController: NSObject {
    @objc public class PageInfo:NSObject {
        public var currentPage:Int = 0
        public var totalPage:Int = 1
        public var newData:[Any] = [Any]()
        public var extraIndexPaths:[IndexPath]? = nil
        public init(currentPage:Int,totalPage:Int,newData:[Any],extraIndexPaths:[IndexPath]? = nil) {
            self.currentPage = currentPage
            self.totalPage = totalPage
            self.newData = newData
            self.extraIndexPaths = extraIndexPaths
        }
    }
    var _totalPageNum:Int = 1
    var _currentPage:Int = 0
    //section for page data located on
    open var pageDataSection:Int {
        get {
            return 0
        }
    }
    public var totalPageNum:Int {
        get {
            return _totalPageNum
        }
    }
    public var currentPage:Int {
        get {
            return _currentPage
        }
    }
    var currentLoadingPage = -1
    var datas = [Any]()
    
    open var dataCount:Int {
        get {
            return datas.count
        }
    }
    @objc open func updateData(at index:Int, data:[String:Any]) {
        self.datas[index] = data
    }
    @objc open func removeData(at index:Int) {
        self.datas.remove(at: index)
    }
    @objc open func data(at index:Int) -> Any? {
        return (datas.count <= index) ? nil : datas[index]
    }
    @objc open func reloadAllData() {
        _totalPageNum = 1;
        _currentPage = 0;
        currentLoadingPage = -1;
        datas.removeAll(keepingCapacity: true)
    }
    open func indexPaths(for dataIndex:Int)->[IndexPath]
    {
        return [IndexPath(row: dataIndex, section: self.pageDataSection)]
    }
    @objc open func loadNextPage(_ complete:(()->())? = nil) {
        if (currentLoadingPage != currentPage + 1) {
            currentLoadingPage = currentPage + 1;
            self.loadData(page: currentLoadingPage, complete: {
                pageInfo in
                self._totalPageNum = pageInfo.totalPage
                if pageInfo.currentPage != self.currentLoadingPage {
                    return
                }
                self._currentPage = self.currentLoadingPage
                self.currentLoadingPage = -1
                var indexList = [IndexPath]()
                let startRow = self.datas.count
                
                for idx in 0..<pageInfo.newData.count {
                    indexList += self.indexPaths(for: startRow + idx)
                }
                self.datas = self.datas + pageInfo.newData
                if let extraIndexPaths = pageInfo.extraIndexPaths {
                    indexList += extraIndexPaths
                }
                
                
                DispatchQueue.main.async {
                    self.updateUI(indexList)
                    complete?()
                }
            })
            
        }
    }
    //complete(datas, total page, current page)
    func loadData(page:Int, complete:@escaping (PageInfo)->())
    {
        
    }
    open func updateUI(_ newIndexList:[IndexPath]) {
        
    }
    
}
