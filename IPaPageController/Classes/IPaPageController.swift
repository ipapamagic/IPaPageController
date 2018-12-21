//
//  IPaPageController.swift
//  IPaPageController
//
//  Created by IPa Chen on 2018/10/29.
//

import UIKit

public class IPaPageController: NSObject {
    var totalPageNum = 1
    var currentPage = 0
    var currentLoadingPage = -1
    var datas = [Any]()
    
    open var dataCount:Int {
        get {
            return datas.count
        }
    }
    @objc open func updateData(index:Int, data:[String:Any]) {
        self.datas[index] = data
    }
    @objc open func getData(index:Int) -> Any? {
        return (datas.count <= index) ? nil : datas[index]
    }
    @objc open func reloadAllData() {
        totalPageNum = 1;
        currentPage = 0;
        currentLoadingPage = -1;
        datas.removeAll(keepingCapacity: true)
    }
    @objc open func loadNextPage() {
        if (currentLoadingPage != currentPage + 1) {
            currentLoadingPage = currentPage + 1;
            self.loadData(page: currentLoadingPage, complete: {
                newDatas,totalPage,currentPage in
                self.totalPageNum = totalPage
                if currentPage != self.currentLoadingPage {
                    return
                }
                self.currentPage = self.currentLoadingPage
                self.currentLoadingPage = -1
                var indexList = [IndexPath]()
                let startRow = self.datas.count
                for idx in 0..<newDatas.count {
                    indexList.append(IndexPath(row: startRow + idx, section: 0))
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
