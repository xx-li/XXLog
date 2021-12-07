#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 用于生成mars.xcframework的脚本
# 1. 下载mars的git仓库
# 2. 使用build_ios.py脚本编译出os文件(arm64)，simulator文件(x86)，mars.framework。
# 3. 修改build_ios.py脚本，simulator改为arm64，os文件改为arm64
# 4. 使用build_ios.py脚本编译出os文件(x86)，simulator文件(arm64)，mars.framework。
# 5. lipo合并不同架构的simulator文件。
# 6. 复制两份mars.framework，分别用os文件(arm64)和simulator文件（arm64+x86）替换里面的mars文件
# 7. 将两份mars.framework合并成xcframework文件。

import os
import re

tempDir = 'temp'
build_script_dir = os.path.join(tempDir, 'mars/')
build_script_path = os.path.join(build_script_dir, 'build_ios.py')


build_intel_simulator_str = '-DIOS_PLATFORM=SIMULATOR -DIOS_ARCH="x86_64" -DENABLE_ARC=0 -DENABLE_BITCODE=1 -DENABLE_VISIBILITY=1'
build_intel_os_str = '-DIOS_PLATFORM=OS -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=1 -DENABLE_VISIBILITY=1'

build_m1_simulator_str = '-DIOS_PLATFORM=SIMULATOR64 -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=1 -DENABLE_VISIBILITY=1'
build_m1_os_str = '-DIOS_PLATFORM=OS -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=1 -DENABLE_VISIBILITY=1'

build_simulator_pattern = '-DIOS_PLATFORM=SIMULATOR.* -DENABLE_VISIBILITY=1' 
build_os_pattern = '-DIOS_PLATFORM=OS.* -DENABLE_VISIBILITY=1'

def clean():
    os.system('rm -rf temp && mkdir temp')

def download_mars():
    url = 'git@github.com:Tencent/mars.git ./temp'
    print("start download mars with:" + url)
    cmd = 'git clone ' + url
    os.system(cmd)

def build_intel_framework():
    print('开始编译intel机型上的framework。os文件(arm64)，simulator文件(x86)')
    # 1. 修改脚本支持bitcode和编译出正确类型
    script_file = 'build_ios.py'

    # 避免需要输入
    replace_pattern(
        script_file, 
        "num = raw_input.*'\)", 
        "num = '2'")

    replace_pattern(
        script_file, 
        build_simulator_pattern, 
        build_intel_simulator_str)

    replace_pattern(
        script_file,
        build_os_pattern, 
        build_intel_os_str)
    print('修改脚本完成')
    # 2. 打包framework
    print('编译出os文件(arm64)，simulator文件(x86)，mars.framework')
    
    os.system('python build_ios.py')
    # 3. 将打包好的文件放入temp/intel目录下
    os.system('mkdir ../../intel')
    os.system('cp ./cmake_build/iOS/Darwin.out/os ../../intel/os')
    os.system('cp ./cmake_build/iOS/Darwin.out/simulator ../../intel/simulator')
    os.system('cp -rf ./cmake_build/iOS/Darwin.out/mars.framework ../../intel/mars.framework')
    print('编译intel机型上的framework完成')

def build_m1_framework():
    print('开始编译M1机型上的framework。os文件(x86)，simulator文件(arm64)')
    # 1. 修改脚本支持bitcode和编译出正确类型
    script_file = 'build_ios.py'
    replace_pattern(
        script_file, 
        build_simulator_pattern, 
        build_m1_simulator_str)

    replace_pattern(
        script_file,
        build_os_pattern, 
        build_m1_os_str)
    print('修改脚本完成')
    # 2. 打包framework
    print('编译出os文件(x86)，simulator文件(arm64)，mars.framework')
    
    os.system('python build_ios.py')
    # 3. 将打包好的文件放入temp目录下
    os.system('mkdir ../../m1')
    os.system('cp ./cmake_build/iOS/Darwin.out/os ../../m1/os')
    os.system('cp ./cmake_build/iOS/Darwin.out/simulator ../../m1/simulator')
    os.system('cp -rf ./cmake_build/iOS/Darwin.out/mars.framework ../../m1/mars.framework')
    print('编译m1机型上的framework完成')

# 合并framework
def lipo_framework():
    print('创建framework')
    # 创建针对模拟器的arm64 & x86 framework
    os.system('mkdir simulator')
    os.system('lipo -create intel/simulator m1/simulator -output simulator/mars')
    os.system('cp -r intel/mars.framework simulator/mars.framework')
    os.system('rm simulator/mars.framework/mars')
    os.system('cp simulator/mars simulator/mars.framework/mars')

    # 创建针对真机的arm64 framework
    os.system('mkdir os')
    os.system('lipo -create intel/os -output os/mars')
    os.system('cp -r m1/mars.framework os/mars.framework')
    os.system('rm os/mars.framework/mars')
    os.system('cp os/mars os/mars.framework/mars')

def creat_xcframework():
    print("创建xcframework")
    os.system('xcodebuild -create-xcframework -framework simulator/mars.framework -framework os/mars.framework -output mars.xcframework')

# ----- Tool ------
# 传入文件(file),将旧内容(old_content)替换为新内容(new_content)

def replace_pattern(file, pattern, new_content):
    f = open(file,'r')
    filedata = f.read()
    f.close()
    newdata = re.sub(re.compile(pattern), new_content, filedata)
    f = open(file,'w')
    f.write(newdata)
    f.close()

def replace(file, old_content, new_content):
    f = open(file,'r')
    filedata = f.read()
    f.close()
    newdata = filedata.replace(old_content, new_content)

    f = open(file,'w')
    f.write(newdata)
    f.close()

def main():
    clean()
    download_mars()
    # 进入build_ios.py脚本所在目录（避免脚本执行报错）
    os.chdir(build_script_dir)
    build_intel_framework()
    build_m1_framework()

    # 进入temp目录
    os.chdir('../../')
    os.system('pwd')
    lipo_framework()
    creat_xcframework()
    

if __name__ == '__main__':
    main()
