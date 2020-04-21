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
/**mainType 主类型*/
@property (nonatomic , assign) TopDeviceMainType mainType;
/**码库设备分类型,非码库设备不用管，马库设备的key在TopDBTCKeyType*/
@property (nonatomic , assign) TopDataBaseDeviceType databaseType;

/**子设备的Id 主类型*/
@property (nonatomic , assign) NSInteger subId;
/**md5 主机*/
@property (nonatomic , copy) NSString * md5;
/**红外频段类型*/
@property (nonatomic , assign) GLCarrierType carrierType;
/**马库设备fileId*/
@property (nonatomic, assign) NSInteger fileId;
/**md5 按键id列表，[NSNumber]*/
@property (nonatomic , strong) NSArray *  keyIdList;

@property (nonatomic , strong) NSString * stateValue;

- (TopACStateInfo *)getACStateInfoWithStateValue:(NSString *)stateValue;
- (NSString *)getStateValueWithACState:(TopACStateInfo *) acStateInfo;
@end

NS_ASSUME_NONNULL_END
