//
//  TestSwift.swift
//  XXLog_Example
//
//  Created by Stellar on 2021/11/26.
//  Copyright © 2021 lixinxing. All rights reserved.
//

import UIKit
import XXLog

class TestSwift: NSObject {
    @objc func test() {
        LOG_WARNING("模块名", "我是日志内容--使用swift打印")
    }
}
