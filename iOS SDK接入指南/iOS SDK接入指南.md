# 1.SDK接入
#### 第一步
###### 方式一:
导入GeeklinkSDK.framework。
###### 方式二:
在Podfile文件中加上：pod 'GeeklinkSDK'
#### 第二步
在Build Phases中Embed Framework加入GeeklinkSDK.framework。
![](http://api.geeklink.com.cn/OpenSdk/public/editor/images/962F4F5D-59D1-43ED-A304-285DDEE50C84.png)

# 2.返回枚举说明（GLStateType）
|  枚举   |  说明 |
| ------------ | ------------ |
|  GLStateTypeFailed   |失败  |
|GLStateTypeTokenError|设备token错误|
|GLStateTypeFullError|数据已满|
|GLStateTypeTimeoutError|超时|
|GLStateTypeRepeatError|重复添加错误|
|GLStateTypeInternetError|网络错误|
|GLStateTypeMd5Error|md5错误|
|GLStateTypeNoConnectError|主机离线错误|
|GLStateTypeNoKeyError|没有按键错误|
|GLStateTypeFileIdError|码库设备fileI错误|

# 3.设备类型枚举说明TopDeviceType
### 设主类型TopDeviceType
|  枚举   |  备注 |
| ------------ | ------------ |
| TopNetworkDevice | 连网设备，分类型subType对应TopNetworkDeviceType |
| TopDataBaseDevice | 码库设备：分类型subType对应TopDataBaseDeviceType |
| TopCunstomDevice | 自定义设备：分类型自己定义 |
### 连网设备分类型TopNetworkDeviceType
|  枚举   |  备注 |
| ------------ | ------------ |
| TopNetworkDeviceTypeSmartpi | 小pi设备 |
| TopNetworkDeviceTypeDisinfectionLamp |消毒灯 |
### 码库设备分类型TopDataBaseDeviceType
|  枚举   |  备注 |
| ------------ | ------------ |
| TopDataBaseDeviceTV | 码库电视设备 |
| TopDataBaseDeviceSTB |码库机顶盒设备 |
| TopDataBaseDeviceIPTV |码库IPTV设备 |
| TopDataBaseDeviceAC |码库空调设备 |


# 4.公用接口TopGLAPIManager
##  4.1 初始化接口单例
###### + (instancetype)initManagerWithAppId:(NSString *)appID andSecret: (NSString *)secret;
###### 接口说明：初始化才可以进行使用接口说明：初始化才可以进行使用
|  参数   |  备注 |
| ------------ | ------------ |
| appID  | 申请到的AppId |
| secret  | 密钥 |
## 4.2 通信接口的打开和关闭
##### 目的：省电
###### - (void)networkContinue;
###### 说明： 继续和设备通信，App进入前台时调用
###### - (void)stopNetwork;
######  说明：App进入后台时调用
## 4.3配网接口
###### - (void)configerWifiWithApBssid:(NSString *) apBssid andApSsid:(NSString *) apSsid andPassword: (NSString *) password configerResult:(void(^)(TopGLAPIResult * configerDevResult))configerResult;
###### 说明：用于配置主设备网络。配置新设备网络（不支持5GWi-Fi）
###### - (void)stopConfigureWifi;
###### 说明：停止配网
|  参数   |  备注 |
| ------------ | ------------ |
| apBssid  | 路由器的Wi-Fi apBssid |
| apSsid  | 路由器的Wi-Fi的apSsid |
|password|路由器的Wi-Fi 的密码|
|返回对象有效参数|TopGLAPIResult |
|state|GLStateTypeOk｜GLStateTypeFailed  |
|mainType|设备主类型，参考主类型说明  |
|subType|设备分类型，参考分类型说明  |
|token|设备的token |
|md5|设备的md5  |
## 4.4链接主设备
###### - (void)linKAllMainDevice:(NSArray *) mainDeviceList
###### 说明：用于和用户配网成功的主设备进行链接
|  参数   |  备注 |
| ------------ | ------------ |
|mainDeviceList|[TopMainDevice]主设备对象列表|
## 4.5删除主设备
######  - (void)deleteMainDevice:(NSString *)md5  complete:(void(^)(TopGLAPIResult * resucltInfo))result;
###### # 说明：用于删除主设备，删除后如果需要重新添加设备，需要把设备恢复出厂再进行配网。
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
|返回对象有效参数|TopGLAPIResult |
| md5 | 主设备的md5 |
| state |GLStateTypeOk｜GLStateTypeFailed |
##  4.6设备升级

###### - (void)upgradeDeviceWithMd5:(NSString *)md5 complete:(void(^)(TopGLAPIResult * resucltInfo))result;
###### 说明 ：用于设备升级，设备升级大概需要1分钟，请勿断电。
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
|返回对象有效参数|TopGLAPIResult |
| md5 | 主设备的md5 |
| state |GLStateTypeOk｜GLStateTypeFaile 回复成功代表设备接收到升级信息，此时设备升级大概需要一分钟|
##  4.7时区设置/获取
###### - (void)deviceTimezoneWithMd5:(NSString *)md5 action:(GLTimezoneAction)action timezone:(NSInteger)timezone complete:(void(^)(TopGLAPIResult * resucltInfo))result;

###### 说明 ：用于设备时区设置/获取。
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
| timezone  | 时区 x 60*(例如东八区(480) = 8 x 60 ) |
|返回对象有效参数|TopGLAPIResult |
| md5 | 主设备的md5 |
| state |GLStateTypeOk｜GLStateTypeFaile |
| timezone  | 时区 x 60*(例如东八区(480) = 8 x 60 ) |
# 5.代理方法TopGLAPIManagerDelegate
## 5.1设备状态改变调用的代理方法
###### - (void)deviceStateChange:(TopGLAPIResult *)resultInfo;
|  TopGLAPIResult有效参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
|subId|0代表主机，其他对应对应分机的subId|
|stateValue|如果是分机(subId!=0)则有效，根据分机类型在TopSubDevInfo里边解析|
|mainDevStateInfo|如果是主设备(subId ==0)则有效|
# 6附件
| 接入设备   |  产考文档 |
| ------------ | ------------ |
| 小pi设备 | 《小Pi SDK接口》 |
| 消毒灯设备 | 《消毒灯 SDK接口》 |
