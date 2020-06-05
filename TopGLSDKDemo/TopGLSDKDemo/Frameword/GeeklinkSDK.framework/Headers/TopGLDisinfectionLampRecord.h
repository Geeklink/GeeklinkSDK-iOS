//
//  TopDisinfectionLampRecord.h
//  project_lib
//
//  Created by 杨飞飞 on 2020/5/18.
//  Copyright © 2020 列树童. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDisinfectionRecordType.h"
#import "GLDisinfectionOperationType.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopGLDisinfectionLampRecord : NSObject
/**Recorded time 记录时间 */
@property (nonatomic, assign) NSInteger time;

/** Start operation(启动操作) GLDisinfectionRecordTypeOperation;
    End of disinfection(消毒结束) GLDisinfectionRecordTypeEnd;
    Disinfection pause(消毒暂停) GLDisinfectionRecordTypePause;
    Resume disinfection(恢复) GLDisinfectionRecordTypeRestore;
    Cancel disinfection取消消毒 GLDisinfectionRecordTypeCancel;
    Child lock prohibits manual operation 童锁禁止手动消毒 GLDisinfectionRecordTypeChildLock */
@property (nonatomic, assign) GLDisinfectionRecordType recordType;

/**It is used for GLDisinfectionRecordTypeEnd（ 消毒结束才有效) */
@property (nonatomic, assign) NSInteger duration;

/** Disinfection Operation Type. It is used for GLDisinfectionRecordTypeCancel GLDisinfectionRecordTypeOperation
 消毒操作类型 (启动和取消当记录才有，其他没有) */

/**Manual operation (手动操作) */
//GLDisinfectionOperationTypeOperator,
/**Timed operation (定时启动) */
//GLDisinfectionOperationTypeTimer,
/**App operation(操作) */
//GLDisinfectionOperationTypeApp,
/**Firmware automatic operation (固件自动操作) */
//GLDisinfectionOperationTypeHardware,
@property (nonatomic, assign) GLDisinfectionOperationType operationType;

/**Operator account. It is used for App operation.
 (操作者账号,当APP操作才有，其他没有)  */
@property (nonatomic, copy, nonnull) NSString * account;

@end

NS_ASSUME_NONNULL_END
