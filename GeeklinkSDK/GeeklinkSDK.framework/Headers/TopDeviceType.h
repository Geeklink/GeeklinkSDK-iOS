//
//  TopDeviceType.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/25.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopDeviceType : NSObject
typedef NS_ENUM(NSInteger, TopDeviceMainType)
{
    /**链接网络的主机设备*/
    TopNetworkDevice,
    /*码库分机设备*/
    TopDataBaseDevice,
    /*自习分极设备*/
    TopCunstomDevice,
    
};

typedef NS_ENUM(NSInteger, TopNetworkDeviceType)
{
    /**智能红外遥控主设备*/
    TopNetworkDeviceTypeSmartpi,
   
};


typedef NS_ENUM(NSInteger, TopDataBaseDeviceType)
{
    /**码库空调设备设备*/
    TopDataBaseDeviceAC = 0x01,
    /**码库电视设备*/
    TopDataBaseDeviceTV = 0x02,
    /**码库机顶盒设备*/
    TopDataBaseDeviceSTB = 0x03,
    /**码库IPTV设备*/
    TopDataBaseDeviceIPTV = 0x07,

  
};

@end

NS_ASSUME_NONNULL_END
