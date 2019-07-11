//
//  IPaPageController.swift
//  IPaPageController
//
//  Created by IPa Chen on 2018/10/29.
//

import UIKit

open class IPaPageController: NSObject {
    var _totalPageNum:Int = 1
    var _currentPage:Int = 0
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
        return [IndexPath(row: dataIndex, section: 0)]
    }
    @objc open func loadNextPage() {
        if (currentLoadingPage != currentPage + 1) {
            currentLoadingPage = currentPage + 1;
            self.loadData(page: currentLoadingPage, complete: {
                newDatas,totalPage,currentPage in
                self._totalPageNum = totalPage
                if currentPage != self.currentLoadingPage {
                    return
                }
                self._currentPage = self.currentLoadingPage
                self.currentLoadingPage = -1
                var indexList = [IndexPath]()
                let startRow = self.datas.count
                for idx in 0..<newDatas.count {
                    indexList += self.indexPaths(for: startRow + idx)
                }
                self.datas = self.datas + newDatas
                
                
                
                DispatchQueue.main.async {
                    self.updateUI(startRow: startRow, newDataCount: newDatas.count,newIndexList: indexList)
                }
            })
            
        }
    }
    func loadData(page:Int, complete:@escaping ([Any],Int,Int)->())
    {
        
    }
    func updateUI(startRow:Int,newDataCount:Int,newIndexList:[IndexPath]) {
        
    }
    
}
