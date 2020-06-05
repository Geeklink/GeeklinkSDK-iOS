#小Pi SDK接口(TopGLSmartPiAPIManager)
##  1获取所有子设备
######  - (void)getSubDeviceListWithMd5:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
###### 说明：  获取所有子设备信息
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
| 返回结果有效数据 | TopGLSmartPiResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
| subDevList  | [TopSubDevInfo]子设备列表，参考子设备对象 |
## 2增删改子设备
###### - (void)setSubDeviceWithMd5:(NSString *)md5 subDevInfo:(TopSubDevInfo *)subDevInfo action:(GLActionFullType)action complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
###### 说明：用于增删改子设备
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主机的md5 |
| action | GLActionFullTypeInsert(增), GLActionFullTypeDelete（删）, GLActionFullTypeUpdate（改） |
| subDevInfo |  添加的时候subId填0，自定义设备fileId填0，添加码库设备需要获取品牌列表，和获取品牌对应我fileId(具体操作可以看demo |
| 返回结果有效数据   |  TopGLSmartPiResultInfo |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed |
| subDevInfo | 对应操作的子设备对象 |
#3 增删改自定义设备的按键
######- (void)setSubDeviceKeyWithMd5:(NSString *)md5 action:(GLActionFullType)action  subDeviceId: (NSInteger)subDeviceId keyId: (NSInteger)keyId
######说明：用于增删自定义子设备的按键。添加和更新是需要在20秒钟内用遥控器对着主设备按下对应的按键。
|  参数   |  备注 |
| ------------ | ------------ |
| md5  | 主机的md5 |
| TopGLSmartPiResultInfo  | 返回结果有效数据 |
| md5 | 主机的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed |
| md5 | 主机的md5 |
| keyId | 成功返回的keyId |
| action | 对应的操作 |
###4取消添加按键操作
######- (void)cancelSetKeyWithMd5:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：添加按键中途主动取消添加
|  参数   |  备注 |
| ------------ | ------------ |
| md5  | 主机的md5 |
| 返回结果有效数据  | TopGLSmartPiResultInfo |
| md5 | 主机的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed |
###5控制子设备
######- (void)controlSubDeviceKeyWithMd5:(NSString *)md5 subDevInfo:(TopSubDevInfo *)subDevInfo acStateInfo:(TopACStateInfo * __nullable)acStateInfo keyId: (NSInteger)keyId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：用于控制对应的子设备
|  参数   |  备注 |
| ------------ | ------------ |
| md5  | 主机的md5 |
| subDevInfo|子设备对象|
|keyId|如果是空调则需要传入对应控制的状态|
| 返回结果有效数据  | TopGLSmartPiResultInfo |
| md5 | 主机的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed |
###6获取主设备状态信息
######- (void)getDeviceStateInfo:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：用于读取主设备状态信息
|  参数   |  备注 |
| ------------ | ------------ |
| md5  | 主机的md5 |
| 返回结果有效数据  | TopGLSmartPiResultInfo |
| md5 | 主机的md5 |
| mainDevStateInfo | TopMainDevStateInfo 主机状态对象 |
###7定时
####7.1 获取简化的定时时间列表
######- (void)getActionTimerListWithMd5:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明： 获取简化的定时时间列表
|  参数   |  备注 |
| ------------ | ------------ |
| md5   | 主机的md5 |
| 返回结果有效数据  | GLStateTypeOk｜GLStateTypeFailed |
| timerSimpleArray | [TopTimerSimpleInfo]简化定时对象列表 |
###7.2修改简单的定时信息
######- (void)setActionTimerInfoWithMd5:(NSString *)md5 action:(GLSingleTimerActionType)action timeInfo:(TopTimeInfo *)timeInfo complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明： 只拥有简单的删除、修改和启动开关操作，插入除外
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| action   | GLSingleTimerActionTypeDelete[删除] GLSingleTimerActionTypeUpdate[更新] GLSingleTimerActionTypeSetOnOff[操作开关] |
|  timerSimpleInfo   |  时间简化对象 |
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk｜GLStateTypeFailed |
| action | 对应的action |
|  md5   |  主机的md5 |
###7.3 获取某个定时的详细情况
######- (void)getTimeInfoDetailWithMd5:(NSString *)md5  timeId:(NSInteger)timeId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：用于获取定时详细信息
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| timeId   | 对应的定时ID |
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk｜GLStateTypeFailed |
| timeInfo  | TopTimeInfo 参考定时对象 |
|  md5   |  主机的md5 |
###7.4插入或者修改定时信息
######- (void)setActionTimerInfoWithMd5: (NSString *)md5 action:(GLSingleTimerActionType)action  timeInfo:(TopTimeInfo *)timeInfo complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明： 用于定时所用信息的修改或者插入新定时
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| action   | GLSingleTimerActionTypeInsert[插入] GLSingleTimerActionTypeDelete[删除] GLSingleTimerActionTypeUpdate[更新] |
| timeInfo  | TopTimeInfo 参考定时对象 |
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| timeInfo | TopTimeInfo 参考定时对象 |
|  md5   |  主机的md5 |
| action | 对应的action |
###8用设备获取按键码
######- (void)getCodeFromDeviceWithMd5:(NSString *)md5 andCodeType:(GLKeyStudyType)type  complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：用于设备获取对应要控制的按键的码，目前studyType 只支持红外和取消
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| GLKeyStudyType   | GLKeyStudyTypeKeyStudyIr（红外码）和GLKeyStudyTypeKeyStudyCancel（取消获取）|
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| md5   |  主机的md5 |
| irCode | 字符串红外码 |
###9让设备发出红外码
#######- (void)controlSubDeviceWithMd5:(NSString *)md5 andIrCode:(NSString *)code complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
#######说明：直接让发学习到的红外码控制设备

|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| irCode | 字符串红外码 |
| GLKeyStudyType   | GLKeyStudyTypeKeyStudyIr（红外码）和GLKeyStudyTypeKeyStudyCancel（取消获取）|
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| md5   |  主机的md5 |
###10码库设备接口
####10.1获取品牌
######- (void)getDBRCBrandWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType)databaseType complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：用于获取码库设备品牌列表
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| databaseType | GLGeeklinkDevType码库设备类型枚举|
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| dbrcBrandList  | [TopDBRCBrand]品牌对象列表 |
| md5   |  主机的md5 |
###10.2获取品牌对应的fileId列表
######- (void)getDBRCBrandFlieIdWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType)databaseType andBrand:(TopDBRCBrand *)brand complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说明：用于获取品牌对应的fileId列表
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| databaseType | GLGeeklinkDevType码库设备类型枚举|
|brand | 对应的TopDBRCBrand 对象 |
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| dbrcBrandFileIdList  | [TopDBRCBrandFileId]品牌FileId对象列表 |
| md5   |  主机的md5 |

###10.3获取码库设备的按键
######-(void)getDBKeyListWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType)databaseType fildId:(NSInteger)fildId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result ;
######说明:用于获取码库设备的所有按键
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| databaseType | GLGeeklinkDevType枚举 |
| fildId    |对应的码库设备的fildId|
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| md5   |  主机的md5 |
|keyList|[NSNumber] 码库设备的按键枚举的NSNumber类型数组|
###10.4测试品牌
######- (void)testDataBaseDeviceWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType) databaseType fildId:(NSInteger)fildId  acStateInfo:(TopACStateInfo * __nullable)acStateInfo keyId: (NSInteger)keyId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
######说要：用于简单测试是否能正确控制对应的品牌设备
|  参数   |  备注 |
| ------------ | ------------ |
|  md5   |  主机的md5 |
| databaseType | GLGeeklinkDevType枚举 |
| keyId | 填对应的码库设备填按键类型枚举 |
| acStateInfo | 如果是马库设备填按键类型|
| fildId    |对应的码库设备的fildId |
| 返回结果有效数据 | TopGLSmartPiResultInfo  |
| state  | GLStateTypeOk GLStateTypeFailed |
| md5   |  主机的md5 |
