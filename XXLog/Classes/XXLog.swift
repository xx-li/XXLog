//
//  XXLog.swift
//  XXLogDemo
//
//  Created by Stellar on 2021/11/24.
//

import Foundation

///  对OC XLog日志打印的封装
public func print(level: XXLogLevel,
                  tag: String,
                  fileName: String,
                  line: UInt,
                  funcName: String,
                  items: Any...)
{
    if XXLogHelper.shouldLog(level)
    {
        XXLogHelper.log(with: level,
                      moduleName: tag,
                      fileName: fileName,
                      lineNumber: Int32(line),
                      funcName: funcName,
                      message: "\(items)")
    }
}


public func LOG_ERROR(_ moduleName: String,
                      _ items: Any...,
                      fileName: String = #file,
                      line: UInt = #line,
                      funcName: String = #function)
{
    print(level: .error,
          tag: moduleName,
          fileName: fileName,
          line: line,
          funcName: funcName,
          items: items)
}

public func LOG_WARNING(_ moduleName: String,
                        _ items: Any...,
                        fileName: String = #file,
                        line: UInt = #line,
                        funcName: String = #function)
{
    print(level: .warn,
          tag: moduleName,
          fileName: fileName,
          line: line, funcName: funcName,
          items: items)
}

public func LOG_INFO(_ moduleName: String,
                     _ items: Any...,
                     fileName: String = #file,
                     line: UInt = #line,
                     funcName: String = #function)
{
    print(level: .info,
          tag: moduleName,
          fileName: fileName,
          line: line,
          funcName: funcName,
          items: items)
}

public func LOG_DEBUG(_ moduleName: String,
                      _ items: Any...,
                      fileName: String = #file,
                      line: UInt = #line,
                      funcName: String = #function)
{
    print(level: .debug,
          tag: moduleName,
          fileName: fileName,
          line: line,
          funcName: funcName,
          items: items)
}
