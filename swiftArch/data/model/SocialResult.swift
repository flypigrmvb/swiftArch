//
//  SocialResult.swift
//  swiftArch
//
//  Created by czq on 2018/4/24.
//  Copyright © 2018年 czq. All rights reserved.
//

import UIKit
import HandyJSON
class SocialResult<T>:HandyJSON{
    
    var code:Int?
    var message:String?
    var data:T?
    
    required   init() {}
    
    
   
}
