//
//  PaingTalbeDemoViewController.swift
//  swiftArch
//
//  Created by czq on 2018/5/16.
//  Copyright © 2018年 czq. All rights reserved.
//

import UIKit

class PaingTalbeDemoViewController: PagingViewController {

    var socailAppService:SocialAppService=DataManager.shareInstance.socailAppService
    
    private var datasource=Array<NSObject>()
    private var pagingList=Array<GameModel>()
 
   //可以不需要重写该方法
    override func initView() {
        super.initView()
        self.title="真实的分页请求(还支持section)"
    }
    
    
    override func initTableView() {
        super.initTableView()
        self.tableView?.estimatedRowHeight = 80//这个值不影响行高 最好接近你想要的值 
        self.tableView?.estimatedSectionHeaderHeight = 40
    }
    
    //如果使用默认的列表Stateview可以不需要重写该方法(用于自定义 empty error loadingview)
    //也可再次自定义 上下拉的 head 和foot
    override func setTalbeStateView() {
        let emptyView=UserStyleTableEmptyView()
        emptyView.button.onTap {[weak self] in       //我的tableview已经在empty和error上加入了点击会触发下beginRefresh
                                    //但是你依然可以在emptyView上添加你想要的View比如按钮, 点击之后的事件 和我的点击重新加载不冲突
            self?.view.makeToast("去添加")
        }
        self.tableView?.setEmptyiew(view: emptyView)
    }
    override func registerCellModel() {
        super.registerCellModel()
        self.tableView?.registerCellNib(nib: R.nib.gameCell(), modelClass: GameModel.self)
    }
    override func registerSectionHeaderModel() {
        super.registerSectionHeaderModel()
        self.tableView?.registerHeaderClass(headerClass: GameDateHeader.self, modelClass: GameDateModel.self)
    }
    
    //自定义分页策略 需要用户去写
    override func getPagingStrategy() -> PagingStrategy {
        let strategy:PagingStrategy=NormalPagingStrategy(startPageNum: 0, pageSize: 20)
        return strategy
    }
    override func onLoadData(pagingStrategy: PagingStrategy) {
         
        let strategy:NormalPagingStrategy=pagingStrategy as! NormalPagingStrategy;
        let pageInfo:NormalPageInfo=strategy.getPageInfo() as! NormalPageInfo
        self.socailAppService.getGame(pageNum: pageInfo.pageNum, pageSize: pageInfo.pageSize, success: { [weak self] (gameListModel) in
            if let strongSelf = self {
                if(pageInfo.isFirstPage()){
                    strongSelf.pagingList=(gameListModel?.listData)!
                    strongSelf.datasource=(gameListModel?.listData)!
                                                                        //如果要使用sectionHeader功能
    //                self.datasource.insert(EmptyHeaderModel(), at: 0)//第一行一定是SectionModel
                                                                        //因为我是靠sectionmodel的个数做section截断
                                                                        //如果和业务相悖,就插入emptyheadermodel占位
                                                                        //这个model对应的headerview是是个高度为1 完全透明的一个header
                                                                        //如果你确定你的一整个datasource是不可能存在sectionmodel即不使用section功能
                                                                        //那你可以不需要插EmptyHeaderModel
                    
                    strongSelf.datasource.insert(GameDateModel(date:"今天"), at: 0)
                }else{
                    strongSelf.pagingList+=(gameListModel?.listData)!
                    strongSelf.datasource.append(GameDateModel(date:"2011-11-\(Int(arc4random()%30)+1)"))
                    strongSelf.datasource = strongSelf.datasource + (gameListModel?.listData)!
                }
                //调用者必须维护两个列表
                //1.和分页相关的列表
                //2.总数据源的列表
                strongSelf.loadSuccess(resultData: gameListModel!, dataSource: strongSelf.datasource, pagingList: strongSelf.pagingList)
            }
        }) {[weak self] (code, msg) in
            self?.loadFail()
        }
        
    }
    override func registerEventforSectionHeader(header: UIView, model: NSObject) {
        
        if let item:GameDateModel = model as? GameDateModel {
            header.addTapGesture { [weak self] (tap) in
                self?.view.makeToast("header被点击\(String(describing: item.date))")
            }
        }
        
    }
    
    override func registerEventforCell(cell: UITableViewCell, model: NSObject) {
        if let item:GameModel = model as? GameModel {
            
            cell.addTapGesture {[weak self] (tap) in
                self?.view.makeToast("cell被点击\(String(describing: item.title))")
            }
        }
    } 

   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let _ = self.getRealDataSourceModel(indexPath: indexPath) as? GameModel {
            return true
        }
        
        return false
        
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        self.datasource.remove(at: self.getDataSourceRowIndex(indexPath: indexPath))
        self.reloadDataSource(dataSource: self.datasource)
        
        
    }
    
}
