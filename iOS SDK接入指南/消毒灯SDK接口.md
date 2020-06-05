#消毒灯SDK接口 (TopGLDisinfectionLampAPIManager)
######1获取设备状态
######- (void)getDisinfectionLampState:(NSString *)md5 complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;
######说明：  获取设备当前状态
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
| 返回结果有效数据 | TopGLDisinfectionLampResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
| TopMainDevStateInfo   | 设备状态对象|
######2控制消毒灯
######- (void)controlDisinfectionLamp:(NSString *)md5 disinfection_time:(NSInteger) disinfection_time account:(NSString *)account complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;
######说明： 控制消毒灯
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
|disinfection_time|消毒时长，0代表结束消毒|
|account|控制的用户账号|
| 返回结果有效数据 | TopGLDisinfectionLampResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
###3获取消毒定时列表
######- (void)getDisinfectionLampTimerInfoList:(NSString *)md5 complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;

######说明：  获取消毒定时列表
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
| 返回结果有效数据 | TopGLDisinfectionLampResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
|disinfectionTimerList |[TopGLDisinfectionLampResultInfo] 消毒定时对象列表|
######4增删改消毒定时
######- (void)setDisinfectionLampTimerInfo:(NSString *)md5 actionFullType:(GLActionFullType)actionFullType disinfectionLampTimerInfo:(TopGLDisinfectionTimerInfo *)disinfectionLampTimerInfo complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;
######说明：  增删改消毒定时
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
|actionFullType |GLActionFullType(操作类型)：  GLActionFullTypeInsert插入；GLActionFullTypeDelete删除 ；GLActionFullTypeUpdate更新|
|disinfectionLampTimerInfo |定时信息对象|
| 返回结果有效数据 | TopGLDisinfectionLampResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
######5查改儿童锁

######- (void)disinfectionLampChildLock:(NSString *)md5 action:(GLActionType) action child_lock:(BOOL)child_lock  complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;
######说明：  获取/修改儿童锁
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
|action |GLActionTypeCheck 获取;  GLActionTypeModify修改；|
|child_lock |童锁: true (开) ；false(关)|
| 返回结果有效数据 | TopGLDisinfectionLampResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
|child_lock |童锁: true (开) ；false(关)|
|action |GLActionTypeCheck 获取;  GLActionTypeModify修改；|
######6获取消毒记录
######- (void)getDisinfectionLampRecords:(NSString *)md5 complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;
######说明：  获取消毒定时列表
|  参数   |  备注 |
| ------------ | ------------ |
| md5 | 主设备的md5 |
| 返回结果有效数据 | TopGLDisinfectionLampResultInfo   |
| md5 | 主设备的md5 |
| state | GLStateTypeOk｜GLStateTypeFailed｜GLStateTypeFullError |
|disinfectionRecordList |[TopDisinfectionLampRecord] 消毒记录对象列表|
