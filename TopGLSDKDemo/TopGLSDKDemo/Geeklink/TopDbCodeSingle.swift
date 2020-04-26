//
//  TopDbReadSingle.swift
//  Geeklink
//
//  Created by Lieshutong on 2018/8/30.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import SQLite

//用来读取单个码库
class TopDbReadSingle {
    
    static let shared = TopDbReadSingle()
    private init() {}
    
    func getOneCode(_ codeType: GLDatabaseType, fileId: Int, realId: Int64) -> [UInt8] {
        //获得文件名
        var fileName = ""
        switch codeType {
        case .TV:
            fileName = String(format: "%03ld_tv.db", fileId)
        case .STB:
            fileName = String(format: "%03ld_stb.db", fileId)
        case .IPTV:
            fileName = String(format: "%03ld_iptv.db", fileId)
        default:
            break
        }
        //获得数据库路径
        let path = Bundle.main.path(forResource: fileName, ofType: "db")!
        //连接数据库
        let db = try? Connection(path)
        //设置SQL语句
        let sql = String(format: "SELECT * FROM code WHERE id = '%d'", realId)
        //执行SQL语句
        var code = [UInt8]()
        for row in try! (db?.prepare(sql))! {
            let codeString = row[0] as! String
            for byte in codeString.components(separatedBy: ",") {
                if byte != "" {
                    var hex: UInt32 = 0
                    Scanner(string: byte).scanHexInt32(&hex)
                    code.append(UInt8(hex))
                }
            }
            break
        }
        return code
    }
}
