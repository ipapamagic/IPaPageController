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
    
    @objc optional func createNoDataCell(for pageController:IPaTableViewPageController,indexPath:IndexPath) -> UITableViewCell
    
    func loadData(for pageController:IPaTableViewPageController,  page:Int, complete:@escaping ([Any],Int,Int)->())
    func configureCell(for pageController:IPaTableViewPageController,cell:UITableViewCell,indexPath:IndexPath,data:Any)
    func configureLoadingCell(for pageController:IPaTableViewPageController,cell:UITableViewCell,indexPath:IndexPath)
    
    //only called when noLoadingCellAtBegining is true
    @objc optional func onReloading(for pageController:IPaTableViewPageController)
    @objc optional func onReloadingCompleted(for pageController:IPaTableViewPageController)
    
}
@objc public class IPaTableViewPageViewController :UIViewController,UITableViewDelegate,UITableViewDataSource ,IPaTableViewPageControllerDelegate {
    @IBOutlet open var contentTableView:UITableView!
    open lazy var pageController:IPaTableViewPageController = {
        let pageController = IPaTableViewPageController()
        pageController.delegate = self
        return pageController
    }()
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.pageController.noLoadingCellAtBegining = true
           // Do any additional setup after loading the view.
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action:#selector(self.onNeedRefresh(_:)), for: .valueChanged)
        self.contentTableView.refreshControl = refreshControl
        
        
        
    }
    @objc func onNeedRefresh(_ sender:UIRefreshControl) {
        self.pageController.reloadAllData()
        sender.endRefreshing()
    }
    
    open func numberOfSections(in tableView: UITableView) ->
         Int {
        return pageController.numberOfSections(in: tableView)
    }
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageController.tableView(tableView, numberOfRowsInSection: section)
    }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return pageController.tableView(tableView, cellForRowAt: indexPath)
    }
    open func onReloading(for pageController: IPaTableViewPageController) {
        if let refreshControl = self.contentTableView.refreshControl {
            refreshControl.beginRefreshing()
        }
    }
    open func onReloadingCompleted(for pageController: IPaTableViewPageController) {
        if let refreshControl = self.contentTableView.refreshControl {
             refreshControl.endRefreshing()
        }
    }
    open func tableView(for pageController: IPaTableViewPageController) -> UITableView {
        return contentTableView
    }
 
    open func createLoadingCell(for pageController: IPaTableViewPageController, indexPath: IndexPath) -> UITableViewCell {
        fatalError("need override in sub class")
    }
     
    open func configureLoadingCell(for pageController: IPaTableViewPageController, cell: UITableViewCell, indexPath: IndexPath) {
        fatalError("need override in sub class")
    }
    open func createDataCell(for pageController: IPaTableViewPageController, indexPath: IndexPath) -> UITableViewCell {
        fatalError("need override in sub class")
    }
    
    open func configureCell(for pageController: IPaTableViewPageController, cell: UITableViewCell, indexPath: IndexPath, data: Any) {
        fatalError("need override in sub class")
    }
    
    open func loadData(for pageController: IPaTableViewPageController, page: Int, complete: @escaping ([Any], Int, Int) -> ()) {
        fatalError("need override in sub class")
    }
    
    
}
open class IPaTableViewPageController: IPaPageController {
    
    open var insertAnimation = true
    open var noLoadingCellAtBegining = false
    open var enableNoDataCell = false
    open var isNoData:Bool {
        get {
            return currentPage == totalPageNum && self.dataCount == 0
        }
    }
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
    open func data(for indexPath:IndexPath) -> Any {
        return datas[indexPath.row]
    }
    open func indexPathForLoadingCell() -> IndexPath {
        return IndexPath(row: 0, section: 1)
    }
    open func indexPathForNoDataCell() -> IndexPath {
        return IndexPath(row: 0, section: 2)
    }
    open func sectionNumber(for dataCount:Int)->Int {
        return 1
    }
    override open func updateUI(startRow:Int,newDataCount:Int,newIndexList:[IndexPath]) {
        let tableView = self.delegate.tableView(for:self)
        tableView.layer.removeAllAnimations()
//        UIView.setAnimationsEnabled(false)
        let contentOffset = tableView.contentOffset
        if self.insertAnimation {
            tableView.beginUpdates()
            if newIndexList.count > 0 {
                tableView.insertRows(at: newIndexList, with: .automatic)
            }
            if self.currentPage == self.totalPageNum {
                
                if self.enableNoDataCell && self.datas.count == 0 && self.currentPage == 1 && self.totalPageNum == 1 {
                    //create no data cell
                    tableView.insertRows(at: [indexPathForNoDataCell()], with: .automatic)
                    
                }
                if !(currentPage == 1 && self.noLoadingCellAtBegining) {
                    
                    //remove loading cell
                    tableView.deleteRows(at: [indexPathForLoadingCell()], with: .automatic)
                    
                }
                
            }
            else {
                
                if currentPage == 1 && self.noLoadingCellAtBegining {
                    tableView.insertRows(at: [indexPathForLoadingCell()], with: .automatic)
                }
            }
            
            tableView.endUpdates() //need to call after insert new rows
        }
        else {
            
            tableView.reloadData()
        }
//        UIView.setAnimationsEnabled(true)
        tableView .setContentOffset(contentOffset, animated: false)
        let loadingCellIndexPath = indexPathForLoadingCell()
        if let indexPaths = tableView.indexPathsForVisibleRows ,indexPaths.contains(loadingCellIndexPath) {
            loadNextPage() 
        }
        
    }
    
    @objc open func isLoadingCell(_ indexPath:IndexPath) -> Bool {
        return (indexPathForLoadingCell() == indexPath)
    }
    @objc open func isNoDataCell(_ indexPath:IndexPath) -> Bool {
        return (indexPathForNoDataCell() == indexPath)
    }
    // MARK:Table view data source
    @objc open func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNumber(for: datas.count) + 2
    }
    @objc open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == indexPathForLoadingCell().section {
            if noLoadingCellAtBegining && currentPage == 0{
                self.delegate.onReloading?(for: self)
                self.loadNextPage({
                    self.delegate.onReloadingCompleted?(for: self)
                })
                return 0
            }
            return (totalPageNum > currentPage) ? 1 : 0
        }
        else if section == indexPathForNoDataCell().section {
            return (self.enableNoDataCell && self.datas.count == 0 && self.currentPage == 1 && self.totalPageNum == 1) ? 1 : 0
        }
        else {
            return datas.count
        }
    }
    @objc open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if isNoDataCell(indexPath) {
            cell = delegate.createNoDataCell!(for: self, indexPath: indexPath)
        }
        else if isLoadingCell(indexPath) {
            cell = delegate.createLoadingCell(for:self, indexPath: indexPath)
            self.loadNextPage()
            delegate.configureLoadingCell(for:self, cell: cell, indexPath: indexPath)
        }
        else {
            cell = delegate.createDataCell(for:self, indexPath: indexPath)
            delegate.configureCell(for:self, cell: cell, indexPath: indexPath, data: data(for: indexPath))
            
        }
        return cell
    }
    
    

}
