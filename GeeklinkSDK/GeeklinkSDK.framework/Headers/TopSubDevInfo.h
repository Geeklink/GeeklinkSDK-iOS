//
//  TopSubDevInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/20.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

//设备分类型，如果主类型是TopDeviceMainTypeDatabese才有效

#import "GLCarrierType.h"

#import "TopDeviceType.h"
#import "TopACStateInfo.h"
//码库机顶盒按键类型
NS_ASSUME_NONNULL_BEGIN

@interface TopSubDevInfo : NSObject
/**mainType Device's main type (主类型)*/
@property (nonatomic , assign) TopDeviceMainType mainType;
/** If is database device  (码库设备分类型,非码库设备不用管，马库设备的key在TopDBTCKeyType)*/
@property (nonatomic , assign) TopDataBaseDeviceType databaseType;

/**Device' s subId  子设备的Id*/
@property (nonatomic , assign) NSInteger subId;
/**Host device's md5 （ 主机的md5）*/
@property (nonatomic , copy) NSString * md5;
/**Infrared frequency band type（红外频段类型）*/
@property (nonatomic , assign) GLCarrierType carrierType;
/**Database device's fileId （马库设备fileId）*/
@property (nonatomic, assign) NSInteger fileId;
/**Custom device's key list（ 自定义设备的按键id列表）[NSNumber]*/
@property (nonatomic , strong) NSArray *  keyIdList;

@property (nonatomic , strong) NSString * stateValue;

- (TopACStateInfo *)getACStateInfoWithStateValue:(NSString *)stateValue;
- (NSString *)getStateValueWithACState:(TopACStateInfo *) acStateInfo;
@end

NS_ASSUME_NONNULL_END
