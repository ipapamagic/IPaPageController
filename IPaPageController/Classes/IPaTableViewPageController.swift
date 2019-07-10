//
//  IPaTableViewPageController.swift
//  IPaPageController
//
//  Created by IPa Chen on 2018/10/29.
//

import UIKit
@objc public protocol IPaTableViewPageControllerDelegate {
    func tableView(for pageController:IPaTableViewPageController) -> UITableView
    func createLoadingCell(for pageController:IPaTableViewPageController, indexPath:IndexPath) -> UITableViewCell
    func createDataCell(for pageController:IPaTableViewPageController, indexPath:IndexPath) -> UITableViewCell
    
    @objc optional func createNoDataCell(for pageController:IPaTableViewPageController) -> UITableViewCell
    
    func loadData(for pageController:IPaTableViewPageController,  page:Int, complete:@escaping ([Any],Int,Int)->())
    func configureCell(for pageController:IPaTableViewPageController,cell:UITableViewCell,indexPath:IndexPath,data:Any)
    func configureLoadingCell(for pageController:IPaTableViewPageController,cell:UITableViewCell,indexPath:IndexPath)
    
    @objc optional func isLoadingCell(for pageController:IPaTableViewPageController, indexPath:IndexPath) -> Bool
}

public class IPaTableViewPageController: IPaPageController {
    var hasLoadingCell = false
    var hasNoDataCell = false
    open var insertAnimation = true
    open var noLoadingCellAtBegining = false
    open var enableNoDataCell = false
    @objc open var delegate:IPaTableViewPageControllerDelegate!
    @objc open override func reloadAllData() {
        super.reloadAllData()
        let tableView = delegate.tableView(for:self)
        tableView.reloadData()
    }
    override func loadData(page:Int, complete:@escaping ([Any],Int,Int)->())
    {
        delegate.loadData(for:self, page: currentLoadingPage, complete:complete)
    }
    override func updateUI(startRow:Int,newDataCount:Int,newIndexList:[IndexPath]) {
        let tableView = self.delegate.tableView(for:self)
        var indexList = newIndexList
        if self.insertAnimation {
            tableView.beginUpdates()
            if self.currentPage == self.totalPageNum {
                if self.currentPage == 0 && self.hasNoDataCell {
                    tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    self.hasNoDataCell = false
                }
                else if self.hasLoadingCell {
                    tableView.deleteRows(at: [IndexPath(row: startRow, section: 0)], with: .none)
                }
            }
            else if !self.hasLoadingCell {
                //add back loading cell
                indexList.append(IndexPath(row: startRow + newDataCount, section: 0))
            }
            
            
            if indexList.count > 0 {
                tableView.insertRows(at: indexList, with: .automatic)
            }
            if self.currentPage != self.totalPageNum {
                tableView.endUpdates() //need to call before reloadRows
                
            }
            else {
                if self.enableNoDataCell && self.datas.count == 0 && self.currentPage == 1 && self.totalPageNum == 1 {
                    tableView.insertRows(at: [IndexPath(row:0,section:0)], with: .automatic)
                    self.hasNoDataCell = true
                }
                
                tableView.endUpdates() //need to call after insert new rows
            }
        }
        else {
            if self.currentPage == self.totalPageNum {
                if self.currentPage == 0 && self.hasNoDataCell {
                    
                    self.hasNoDataCell = false
                }
                
                if self.enableNoDataCell && self.datas.count == 0 && self.currentPage == 1 && self.totalPageNum == 1 {
                    
                    self.hasNoDataCell = true
                }
            }
            tableView.reloadData()
        }
    }
    @objc open func isLoadingCell(_ indexPath:IndexPath) -> Bool {
        if let isLoadingCell = delegate.isLoadingCell {
            return isLoadingCell(self,indexPath)
        }
        return Bool(indexPath.row == datas.count && currentPage != totalPageNum)
    }
    @objc open func isNoDataCell(_ indexPath:IndexPath) -> Bool {
        return Bool(indexPath.row == 0 && datas.count == 0 && currentPage == totalPageNum && totalPageNum == 1)
    }
    // MARK:Table view data source
    @objc open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    @objc open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hasLoadingCell = false
        if currentPage == 0 && noLoadingCellAtBegining {
            return 0
        }
        if currentPage == totalPageNum {
            if (datas.count == 0 && enableNoDataCell) {
                return 1
            }
            return datas.count
        }
        hasLoadingCell = true
        return datas.count + 1
    }
    @objc open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if isNoDataCell(indexPath) ,let createNoDataCell = delegate.createNoDataCell{
            cell = createNoDataCell(self)
        }
        else if isLoadingCell(indexPath) {
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
