//
//  TopDbReadIndex.swift
//  Geeklink
//
//  Created by Lieshutong on 2018/8/30.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import SQLite

class DbBrandInfo: NSObject {
    var brandId: Int64 = 0
    var deviceId: Int64 = 0
    var brandName = ""
    var ebrandName = ""
    var modelNums: Int64 = 0
    var modelList = [Int64]()
}

class DbModelInfo: NSObject {
    var modelId: Int64 = 0
    var formatId = ""
    var keyFile = ""
    var keySquency: Int64 = 0
}

class DbFormatInfo: NSObject {
    var formatId: Int64 = 0
    var deviceId: Int64 = 0
    var formatName = ""
    var formatString = [UInt8]()
    var c3rv = ""
    var matchs = [UInt8]()
    
    var hasTest = false
}

//用来读取码库总表
class TopDbReadIndex {
    
    //MARK: -
    
    //设置单例
    static let shared = TopDbReadIndex()
    //防止被初始化
    private init() {}
    
    //数据库名字
    let dbFileName = "CodeRC20180611"
    
    //MARK: -
    
    //读取一种设备的全部品牌
    func getAllBrandInfo(_ codeType: GLDatabaseType) -> [DbBrandInfo] {
        //初始化列表
        var list = Array<DbBrandInfo>.init()
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM brands WHERE device_id = '%d'", codeType.rawValue)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            //读取数据
            let brandInfo = DbBrandInfo()
            brandInfo.brandId = row[0] as! Int64
            brandInfo.deviceId = row[1] as! Int64
            brandInfo.brandName = row[2] as! String
            brandInfo.ebrandName = row[3] as! String
            brandInfo.modelNums = row[4] as! Int64
            let string = row[5] as! String
            for model in string.components(separatedBy: ",") {
                if model != "" {
                    brandInfo.modelList.append(Int64(model)!)
                }
            }
            //添加到列表
            list.append(brandInfo)
        }
        //返回列表
        return list;
    }
    
    func getModelInfo(_ codeType: GLDatabaseType, modelId: Int64) -> DbModelInfo {
        let modelInfo = DbModelInfo()
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM model WHERE device_id = '%d' AND m_code = '%03d'", codeType.rawValue, modelId)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            modelInfo.modelId = row[0] as! Int64
            modelInfo.formatId = row[5] as! String
            modelInfo.keyFile = row[6] as! String
            modelInfo.keySquency = row[7] as! Int64
            break
        }
        return modelInfo
    }
    
    func getFormatsInfo(_ codeType: GLDatabaseType, formatId: String) -> DbFormatInfo {
        let formatInfo = DbFormatInfo()
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM formats WHERE device_id = '%d' AND fid = '%@'", codeType.rawValue, formatId)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            formatInfo.formatId = row[1] as! Int64
            formatInfo.deviceId = row[2] as! Int64
            formatInfo.formatName = row[3] as! String
            let formatString = row[4] as! String
            for format in formatString.components(separatedBy: ",") {
                if format != "" {
                    var hex: UInt32 = 0
                    Scanner(string: format).scanHexInt32(&hex)
                    formatInfo.formatString.append(UInt8(hex))
                }
            }
            formatInfo.c3rv = row[5] as! String
            let matchsString = row[6] as! String
            for match in matchsString.components(separatedBy: ",") {
                if match != "" {
                    var hex: UInt32 = 0
                    Scanner(string: match).scanHexInt32(&hex)
                    formatInfo.matchs.append(UInt8(hex))
                }
            }
            break
        }
        return formatInfo
    }
    
    func getIndexIn12(_ index: Int) -> Int64 {
        var sid: Int64 = 0;
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM p12 WHERE pid = '%d'", index)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            sid = row[0] as! Int64
            break
        }
        return sid
    }
    
    func getIndexIn15(_ index: Int) -> Int64 {
        var sid: Int64 = 0;
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM p15 WHERE pid = '%d'", index)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            sid = row[0] as! Int64
            break
        }
        return sid
    }
    
    func getIndexIn38(_ index: Int) -> Int64 {
        var sid: Int64 = 0;
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM p38 WHERE pid = '%d'", index)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            sid = row[0] as! Int64
            break
        }
        return sid
    }
    
    func getIndexIn64(_ index: Int) -> Int64 {
        var sid: Int64 = 0;
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM p64 WHERE pid = '%d'", index)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            sid = row[0] as! Int64
            break
        }
        return sid
    }
    
    func getIndexIn3000(_ index: Int) -> Int64 {
        var sid: Int64 = 0;
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM p3000 WHERE pid = '%d'", index)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            sid = row[0] as! Int64
            break
        }
        return sid
    }
    
    func getIndexIn15000(_ index: Int) -> Int64 {
        var sid: Int64 = 0;
        //获得数据库路径
        let path = Bundle.main.path(forResource: dbFileName, ofType: "db")
        //连接数据库
        let db = try? Connection(path!)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM p15000 WHERE pid = '%d'", index)
        //执行SQL语句
        for row in try! (db?.prepare(sql))! {
            sid = row[0] as! Int64
            break
        }
        return sid
    }
}
