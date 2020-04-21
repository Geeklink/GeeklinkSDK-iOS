//
//  TopDCRCKeyType.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/25.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TopDBSTBKeyType)
{
    TopDBSTBKeyTypeSTB1 = 0,
    TopDBSTBKeyTypeSTB2,
    TopDBSTBKeyTypeSTB3,
    TopDBSTBKeyTypeSTB4,
    TopDBSTBKeyTypeSTB5,
    TopDBSTBKeyTypeSTB6,
    TopDBSTBKeyTypeSTB7,
    TopDBSTBKeyTypeSTB8,
    TopDBSTBKeyTypeSTB9,
    TopDBSTBKeyTypeSTB0,
    TopDBSTBKeyTypeSTBLIST,
    TopDBSTBKeyTypeSTBLAST,
    TopDBSTBKeyTypeSTBWAIT,
    TopDBSTBKeyTypeSTBCHPLUS,
    TopDBSTBKeyTypeSTBCHMINUS,
    TopDBSTBKeyTypeSTBSOUNDPLUS,
    TopDBSTBKeyTypeSTBSOUNDMINUS,
    TopDBSTBKeyTypeSTBUP,
    TopDBSTBKeyTypeSTBDOWN,
    TopDBSTBKeyTypeSTBLEFT,
    TopDBSTBKeyTypeSTBRIGHT,
    TopDBSTBKeyTypeSTBOK,
    TopDBSTBKeyTypeSTBEXIT,
    TopDBSTBKeyTypeSTBMENU,
    TopDBSTBKeyTypeSTBRED,
    TopDBSTBKeyTypeSTBGREEN,
    TopDBSTBKeyTypeSTBYELLOW,
    TopDBSTBKeyTypeSTBBLUE,
    TopDBSTBKeyTypeSTBRETURN,
    TopDBSTBKeyTypeSTBUPPAGE,
    TopDBSTBKeyTypeSTBDOWNPAGE,
    TopDBSTBKeyTypeSTBSOUND,
    TopDBSTBKeyTypeSTBMESSAGE,
    TopDBSTBKeyTypeSTBMUTE,
    TopDBSTBKeyTypeSTBLOVE,
    TopDBSTBKeyTypeSTBGUIDES,
    TopDBSTBKeyTypeSTBTV,
    TopDBSTBKeyTypeSTBBROADCAST,
    TopDBSTBKeyTypeSTBNEWS,
    TopDBSTBKeyTypeSTBSTOCK,
    TopDBSTBKeyTypeSTBDEMAND,
    TopDBSTBKeyTypeSTBMAIL,
    TopDBSTBKeyTypeSTBGAMES,
    TopDBSTBKeyTypeSTBLIST2,
    TopDBSTBKeyTypeSTBLAST2,
    TopDBSTBKeyTypeSTBSET,
    TopDBSTBKeyTypeSTBMAINPAGE,
    TopDBSTBKeyTypeSTBRECORD,
    TopDBSTBKeyTypeSTBSTOPRECORD,
    TopDBSTBKeyTypeSTBA,
    TopDBSTBKeyTypeSTBB,
    TopDBSTBKeyTypeSTBC,
    TopDBSTBKeyTypeSTBD,
    TopDBSTBKeyTypeSTBE,
    TopDBSTBKeyTypeSTBF,
    TopDBSTBKeyTypeSTBREWIND,
    TopDBSTBKeyTypeSTBFAST,
    TopDBSTBKeyTypeSTBPLAY,
    TopDBSTBKeyTypeSTBKEEP1,
    TopDBSTBKeyTypeSTBKEEP2,
    TopDBSTBKeyTypeSTBKEEP3,
    TopDBSTBKeyTypeSTBKEEP4,
    TopDBSTBKeyTypeSTBKEEP5,
    TopDBSTBKeyTypeSTBKEEP6,
    TopDBSTBKeyTypeCount,
};

/**
 *码库电视按键枚举
 *TV_BACK 返回键，新码库才有，旧码库会获取不到码
 *TV_HOME 主页键，新码库才有，旧码库会获取不到码
 */
typedef NS_ENUM(NSInteger, TopDBTVKeyType)
{
    TopDBTVKeyTypePOWER,
    TopDBTVKeyTypeLIYIN,
    TopDBTVKeyTypeBANYIN,
    TopDBTVKeyTypeZHISHI,
    TopDBTVKeyTypeSLEEP,
    TopDBTVKeyType1,
    TopDBTVKeyType2,
    TopDBTVKeyType3,
    TopDBTVKeyType4,
    TopDBTVKeyType5,
    TopDBTVKeyType6,
    TopDBTVKeyType7,
    TopDBTVKeyType8,
    TopDBTVKeyType9,
    TopDBTVKeyType10,
    TopDBTVKeyType0,
    TopDBTVKeyTypeJIAOTI,
    TopDBTVKeyTypeJIAOHUAN,
    TopDBTVKeyTypeHUAZHONGHUA,
    TopDBTVKeyTypeNORMAL,
    TopDBTVKeyTypeXUANTAI,
    TopDBTVKeyTypePICTURE,
    TopDBTVKeyTypeCHMINUS1,
    TopDBTVKeyTypeCHPLUS1,
    TopDBTVKeyTypeSOUND,
    TopDBTVKeyTypeUP,
    TopDBTVKeyTypeDOWN,
    TopDBTVKeyTypeLEFT,
    TopDBTVKeyTypeRIGHT,
    TopDBTVKeyTypeMENU,
    TopDBTVKeyTypePINGXIAN,
    TopDBTVKeyTypeAVTV,
    TopDBTVKeyTypeDONE,
    TopDBTVKeyTypeSOUNDPLUS,
    TopDBTVKeyTypeSOUNDMINES,
    TopDBTVKeyTypeCHPLUS,
    TopDBTVKeyTypeCHMINUS,
    TopDBTVKeyTypeMUTE,
    TopDBTVKeyTypeBACK,
    TopDBTVKeyTypeHOME,
    TopDBTVKeyTypeCount,
};

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, TopDBIPTVKeyType)
{
    TopDBIPTVKeyTypePOWER,
    TopDBIPTVKeyTypeUP,
    TopDBIPTVKeyTypeDOWN,
    TopDBIPTVKeyTypeLEFT,
    TopDBIPTVKeyTypeRIGHT,
    TopDBIPTVKeyTypeOK,
    TopDBIPTVKeyTypeMENU,
    TopDBIPTVKeyTypeHOME,
    TopDBIPTVKeyTypeBACK,
    TopDBIPTVKeyTypeVOLPLUSE,
    TopDBIPTVKeyTypeVOLMINUS,
    TopDBIPTVKeyTypeSTEEING,
    TopDBIPTVKeyTypeCount,
};
typedef NS_ENUM(NSInteger, TopDBACKeyType)
{
    TopDBACKeyTypePower,
    TopDBACKeyTypeTemp,
    TopDBACKeyTypeSpeed,
    TopDBACKeyTypeDir,
    TopDBACKeyTypeMode,
    TopDBACKeyTypecount,
 
};




@interface TopDCRCKeyType : NSObject

@end

NS_ASSUME_NONNULL_END
