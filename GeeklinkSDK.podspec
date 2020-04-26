

Pod::Spec.new do |spec|

   #名称
    spec.name         = "GeeklinkSDK"
    #版本号
    spec.version      = "1.0.0"
    #许可证
    spec.license      = { :type => 'MIT' }
    #项目主页地址
    spec.homepage     = "https://github.com/GeeklinkHome/GeeklinkSDK"
    #作者
    spec.author       = { "GeeklinkSmart" => "674250189@qq.com" }
    #简介
    spec.summary      = "A delightful iOS framework."
    #项目的地址
    spec.source       = { :git => "https://github.com/GeeklinkHome/GeeklinkSDK.git", :tag =>  spec.version}
 
    #支持最小系统版本
    spec.platform     = :ios, "10.0"

    #需要包含的源文件
    spec.source_files = 'GeeklinkSDK/GeeklinkSDK.framework/Headers/*.{h}'

    #你的SDK路径
    spec.vendored_frameworks = 'GeeklinkSDK/GeeklinkSDK.framework'

    #SDK头文件路径
    spec.public_header_files = 'GeeklinkSDK/GeeklinkSDK.framework/Headers/SDK.h'

    spec.frameworks = "UIKit", "Foundation"


end
