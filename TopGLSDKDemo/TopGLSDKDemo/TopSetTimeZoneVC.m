//
//  TopSetTimeZoneVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/4/7.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopSetTimeZoneVC.h"
#import <GeeklinkSDK/SDK.h>
typedef enum{
    KLT,//  +14:00 基里巴斯线岛时间
    NZDT,//           +13:00    新西兰夏令时
    IDLE,//           +12:00    国际日期变更线,东边
    NZST,//           +12:00    新西兰标准时间
    NZT,//           +12:00    新西兰时间
    AESST,//       +11:00    澳大利亚东部夏时制
    ACSST,//       +10:30    中澳大利亚标准时间
    CADT,//       +10:30    中澳大利亚夏时制
    SADT,//       +10:30    南澳大利亚夏时制
    EAST,//       +10:00    东澳大利亚标准时间
    GST,//       +10:00    关岛标准时间
    LIGT,//       +10:00    澳大利亚墨尔本时间
    CAST,//     +9:30    中澳大利亚标准时间
    SAST,//         +9:30    南澳大利亚标准时间
    AWSST,//         +9:00    澳大利亚西部标准夏令时
    JST,//         +9:00    日本标准时间
    KST,//         +9:00    韩国标准时间
    AWST,//         +8:00    澳大利亚西部标准时间
    CCT,//         +8:00    中国沿海时间(北京时间)
    WST,//  +08:00 西澳大利亚标准时间
    ALMST,//   +07:00 阿拉木图夏令时
    CXT,//   +07:00 澳大利亚圣诞岛时间
    MMT,//   +06:30 缅甸时间
    ALMT,//   +06:00 哈萨克斯坦阿拉木图时间
    IST2,//   +05:30 印度标准时间
    IOT,//   +05:00 英属印度洋领地时间
    MVT,//   +05:00 马尔代夫时间
    TFT,//   +05:00 法属凯尔盖朗岛时间
    AFT,//   +04:30 阿富汗时间
    MUT,//   +04:00 毛里求斯时间
    RET,//   +04:00 法属留尼汪岛时间
    SCT,//   +04:00 塞舌尔马埃岛时间
    IT,//         +3:30    伊朗时间
    BT,//         +3:00    巴格达时间
    EETDST,//         +3:00    东欧夏时制(俄罗斯莫斯科时区)
    CETDST,//         +2:00    中欧夏时制
    EET,//         +2:00    东欧
    FWT,//         +2:00    法国冬时制
    IST,//         +2:00    以色列标准时间
    MEST,//         +2:00    中欧夏时制
    METDST,//         +2:00    中欧白昼时间
    SST,//         +2:00    瑞典夏时制
    BST,//         +1:00    英国夏时制
    CET,//         +1:00    中欧时间
    DNT,//     +01:00 丹麦正规时间
    FST,//         +1:00    法国夏时制
    MET,//         +1:00    中欧时间
    MEWT,//         +1:00    中欧冬时制
    MEZ,//         +1:00    中欧时区
    NOR,//         +1:00    挪威标准时间
    SWT,//         +1:00    瑞典冬时制
    WETDST,//         +1:00    西欧光照利用时间（夏时制）
    GMT,//         0:00        格林威治标准时间
    WET,//         0:00        西欧
    UTC,//         0:00        协调世界时
    WAT,//         -1:00        西非时间
    FNST,//    -01:00 巴西费尔南多·迪诺罗尼亚岛夏令时
    FNT,//    -02:00 巴西费尔南多·迪诺罗尼亚岛时间
    BRST,//   -02:00 巴西利亚夏令时
    NDT,//         -2:30        纽芬兰（新大陆）白昼时间
    ADT,//         -3:00        大西洋白昼时间
    BRT,//   -03:00 巴西利亚时间
    NFT,//         -3:30        纽芬兰（新大陆）标准时间
    AST,//         -4:00        大西洋标准时间（加拿大）
    ACST,//     -04:00 大西洋阿雷格里港 夏令时
    EDT,//         -4:00    （美国)东部夏令时
    ACT,//   -05:00 大西洋阿雷格里港标准时间
    CDT,//         -5:00    （美国)中部夏令时
    EST,//         -5:00    （美国)东部标准时间
    CST,//         -6:00    （美国)中部标准时间
    MDT,//         -6:00        （美国)山地夏令时
    MST,//         -7:00        （美国)山地标准时间
    PDT,//         -7:00    （美国)太平洋夏令时
    PST,//         -8:00    （美国)太平洋标准时间
    YDT,//         -8:00        育空地区夏令时
    HDT,//         -9:00        夏威夷/阿拉斯加白昼时间
    YST,//         -9:00        育空地区标准时
    AHST,//       -10:00    夏威夷-阿拉斯加标准时间
    CAT,//       -10:00    中阿拉斯加时间
    NT,//       -11:00    州时间（诺姆时间）
    IDLW//   -12:00    国际日期变更线，西边
}TopGetTimeZoneTypeEnum;//74


@interface TopSetTimeZoneVC ()<UITableViewDelegate, UITableViewDataSource> {
    NSTimer *timer;
    NSDate *nowDate;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *secformatter;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * tz_list;

@end

@implementation TopSetTimeZoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    nowDate = [NSDate new];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSTimeZone *GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:GTMzone];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTimeChange) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}

- (void)checkTimeChange {
    
    nowDate = [NSDate new];
    
 
    [self.tableView reloadData];
}



- (NSArray *)tz_list {
    if (_tz_list == nil) {
        _tz_list =  [self getAllTimeZoneName];
    }
    return  _tz_list;
}


- (NSArray *)getAllTimeZoneName {
    
    NSMutableArray *nameArr = [NSMutableArray new];
    
    for (int i=0; i<83; i++) {
        switch (i) {
            case KLT:
                [nameArr addObject:NSLocalizedStringFromTable(@"KLT", @"Timezone", nil)];
                break;
            case NZDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"NZDT", @"Timezone", nil)];
                break;
            case IDLE:
                [nameArr addObject:NSLocalizedStringFromTable(@"IDLE", @"Timezone", nil)];
                break;
            case NZST:
                [nameArr addObject:NSLocalizedStringFromTable(@"NZST", @"Timezone", nil)];
                break;
            case NZT:
                [nameArr addObject:NSLocalizedStringFromTable(@"NZT", @"Timezone", nil)];
                break;
            case AESST:
                [nameArr addObject:NSLocalizedStringFromTable(@"AESST", @"Timezone", nil)];
                break;
            case ACSST:
                [nameArr addObject:NSLocalizedStringFromTable(@"ACSST", @"Timezone", nil)];
                break;
            case CADT:
                [nameArr addObject:NSLocalizedStringFromTable(@"CADT", @"Timezone", nil)];
                break;
            case SADT:
                [nameArr addObject:NSLocalizedStringFromTable(@"SADT", @"Timezone", nil)];
                break;
            case EAST:
                [nameArr addObject:NSLocalizedStringFromTable(@"EAST", @"Timezone", nil)];
                break;
            case GST:
                [nameArr addObject:NSLocalizedStringFromTable(@"GST", @"Timezone", nil)];
                break;
            case LIGT:
                [nameArr addObject:NSLocalizedStringFromTable(@"LIGT", @"Timezone", nil)];
                break;
            case CAST:
                [nameArr addObject:NSLocalizedStringFromTable(@"CAST", @"Timezone", nil)];
                break;
            case SAST:
                [nameArr addObject:NSLocalizedStringFromTable(@"SAST", @"Timezone", nil)];
                break;
            case AWSST:
                [nameArr addObject:NSLocalizedStringFromTable(@"AWSST", @"Timezone", nil)];
                break;
            case JST:
                [nameArr addObject:NSLocalizedStringFromTable(@"JST", @"Timezone", nil)];
                break;
            case KST:
                [nameArr addObject:NSLocalizedStringFromTable(@"KST", @"Timezone", nil)];
                break;
            case AWST:
                [nameArr addObject:NSLocalizedStringFromTable(@"AWST", @"Timezone", nil)];
                break;
            case CCT:
                [nameArr addObject:NSLocalizedStringFromTable(@"CCT", @"Timezone", nil)];
                break;
            case WST:
                [nameArr addObject:NSLocalizedStringFromTable(@"WST", @"Timezone", nil)];
                break;
            case ALMST:
                [nameArr addObject:NSLocalizedStringFromTable(@"ALMST", @"Timezone", nil)];
                break;
            case CXT:
                [nameArr addObject:NSLocalizedStringFromTable(@"CXT", @"Timezone", nil)];
                break;
            case MMT:
                [nameArr addObject:NSLocalizedStringFromTable(@"MMT", @"Timezone", nil)];
                break;
            case ALMT:
                [nameArr addObject:NSLocalizedStringFromTable(@"ALMT", @"Timezone", nil)];
                break;
            case IST2:
                [nameArr addObject:NSLocalizedStringFromTable(@"IST2", @"Timezone", nil)];
                break;
            case IOT:
                [nameArr addObject:NSLocalizedStringFromTable(@"IOT", @"Timezone", nil)];
                break;
            case MVT:
                [nameArr addObject:NSLocalizedStringFromTable(@"MVT", @"Timezone", nil)];
                break;
            case TFT:
                [nameArr addObject:NSLocalizedStringFromTable(@"TFT", @"Timezone", nil)];
                break;
            case AFT:
                [nameArr addObject:NSLocalizedStringFromTable(@"AFT", @"Timezone", nil)];
                break;
            case MUT:
                [nameArr addObject:NSLocalizedStringFromTable(@"MUT", @"Timezone", nil)];
                break;
            case RET:
                [nameArr addObject:NSLocalizedStringFromTable(@"RET", @"Timezone", nil)];
                break;
            case SCT:
                [nameArr addObject:NSLocalizedStringFromTable(@"SCT", @"Timezone", nil)];
                break;
            case IT:
                [nameArr addObject:NSLocalizedStringFromTable(@"IT", @"Timezone", nil)];
                break;
            case BT:
                [nameArr addObject:NSLocalizedStringFromTable(@"BT", @"Timezone", nil)];
                break;
            case EETDST:
                [nameArr addObject:NSLocalizedStringFromTable(@"EETDST", @"Timezone", nil)];
                break;
            case CETDST:
                [nameArr addObject:NSLocalizedStringFromTable(@"CETDST", @"Timezone", nil)];
                break;
            case EET:
                [nameArr addObject:NSLocalizedStringFromTable(@"EET", @"Timezone", nil)];
                break;
            case FWT:
                [nameArr addObject:NSLocalizedStringFromTable(@"FWT", @"Timezone", nil)];
                break;
            case IST:
                [nameArr addObject:NSLocalizedStringFromTable(@"IST", @"Timezone", nil)];
                break;
            case MEST:
                [nameArr addObject:NSLocalizedStringFromTable(@"MEST", @"Timezone", nil)];
                break;
            case METDST:
                [nameArr addObject:NSLocalizedStringFromTable(@"METDST", @"Timezone", nil)];
                break;
            case SST:
                [nameArr addObject:NSLocalizedStringFromTable(@"SST", @"Timezone", nil)];
                break;
            case BST:
                [nameArr addObject:NSLocalizedStringFromTable(@"BST", @"Timezone", nil)];
                break;
            case CET:
                [nameArr addObject:NSLocalizedStringFromTable(@"CET", @"Timezone", nil)];
                break;
            case DNT:
                [nameArr addObject:NSLocalizedStringFromTable(@"DNT", @"Timezone", nil)];
                break;
            case FST:
                [nameArr addObject:NSLocalizedStringFromTable(@"FST", @"Timezone", nil)];
                break;
            case MET:
                [nameArr addObject:NSLocalizedStringFromTable(@"MET", @"Timezone", nil)];
                break;
            case MEWT:
                [nameArr addObject:NSLocalizedStringFromTable(@"MEWT", @"Timezone", nil)];
                break;
            case MEZ:
                [nameArr addObject:NSLocalizedStringFromTable(@"MEZ", @"Timezone", nil)];
                break;
            case NOR:
                [nameArr addObject:NSLocalizedStringFromTable(@"NOR", @"Timezone", nil)];
                break;
            case SWT:
                [nameArr addObject:NSLocalizedStringFromTable(@"SWT", @"Timezone", nil)];
                break;
            case WETDST:
                [nameArr addObject:NSLocalizedStringFromTable(@"WETDST", @"Timezone", nil)];
                break;
            case GMT:
                [nameArr addObject:NSLocalizedStringFromTable(@"GMT", @"Timezone", nil)];
                break;
            case WET:
                [nameArr addObject:NSLocalizedStringFromTable(@"WET", @"Timezone", nil)];
                break;
            case UTC:
                [nameArr addObject:NSLocalizedStringFromTable(@"UTC", @"Timezone", nil)];
                break;
            case WAT:
                [nameArr addObject:NSLocalizedStringFromTable(@"WAT", @"Timezone", nil)];
                break;
            case FNST:
                [nameArr addObject:NSLocalizedStringFromTable(@"FNST", @"Timezone", nil)];
                break;
            case FNT:
                [nameArr addObject:NSLocalizedStringFromTable(@"FNT", @"Timezone", nil)];
                break;
            case BRST:
                [nameArr addObject:NSLocalizedStringFromTable(@"BRST", @"Timezone", nil)];
                break;
            case NDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"NDT", @"Timezone", nil)];
                break;
            case ADT:
                [nameArr addObject:NSLocalizedStringFromTable(@"ADT", @"Timezone", nil)];
                break;
            case BRT:
                [nameArr addObject:NSLocalizedStringFromTable(@"BRT", @"Timezone", nil)];
                break;
            case NFT:
                [nameArr addObject:NSLocalizedStringFromTable(@"NFT", @"Timezone", nil)];
                break;
            case AST:
                [nameArr addObject:NSLocalizedStringFromTable(@"AST", @"Timezone", nil)];
                break;
            case ACST:
                [nameArr addObject:NSLocalizedStringFromTable(@"ACST", @"Timezone", nil)];
                break;
            case EDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"EDT", @"Timezone", nil)];
                break;
            case ACT:
                [nameArr addObject:NSLocalizedStringFromTable(@"ACT", @"Timezone", nil)];
                break;
            case CDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"CDT", @"Timezone", nil)];
                break;
            case EST:
                [nameArr addObject:NSLocalizedStringFromTable(@"EST", @"Timezone", nil)];
                break;
            case CST:
                [nameArr addObject:NSLocalizedStringFromTable(@"CST", @"Timezone", nil)];
                break;
            case MDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"MDT", @"Timezone", nil)];
                break;
            case MST:
                [nameArr addObject:NSLocalizedStringFromTable(@"MST", @"Timezone", nil)];
                break;
            case PDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"PDT", @"Timezone", nil)];
                break;
            case PST:
                [nameArr addObject:NSLocalizedStringFromTable(@"PST", @"Timezone", nil)];
                break;
            case YDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"YDT", @"Timezone", nil)];
                break;
            case HDT:
                [nameArr addObject:NSLocalizedStringFromTable(@"HDT", @"Timezone", nil)];
                break;
            case YST:
                [nameArr addObject:NSLocalizedStringFromTable(@"YST", @"Timezone", nil)];
                break;
            case AHST:
                [nameArr addObject:NSLocalizedStringFromTable(@"AHST", @"Timezone", nil)];
                break;
            case CAT:
                [nameArr addObject:NSLocalizedStringFromTable(@"CAT", @"Timezone", nil)];
                break;
            case NT:
                [nameArr addObject:NSLocalizedStringFromTable(@"NT", @"Timezone", nil)];
                break;
            case IDLW:
                [nameArr addObject:NSLocalizedStringFromTable(@"IDLW", @"Timezone", nil)];
                break;
                
            default:
                break;
        }
    }
    
    NSArray *arr = [[NSArray alloc] initWithArray:nameArr];
    return arr;
}

- (float)getAllTimeZoneTimeDiff:(int)Time {
    switch (Time) {
        case KLT:
            return 14;
            break;
        case NZDT:
            return 13;
            break;
        case IDLE:
            return 12;
            break;
        case NZST:
            return 12;
            break;
        case NZT:
            return 12;
            break;
        case AESST:
            return 11;
            break;
        case ACSST:
            return 10.5;
            break;
        case CADT:
            return 10.5;
            break;
        case SADT:
            return 10.5;
            break;
        case EAST:
            return 10;
            break;
        case GST:
            return 10;
            break;
        case LIGT:
            return 10;
            break;
        case CAST:
            return 9.5;
            break;
        case SAST:
            return 9.5;
            break;
        case AWSST:
            return 9;
            break;
        case JST:
            return 9;
            break;
        case KST:
            return 9;
            break;
        case AWST:
            return 8;
            break;
        case CCT:
            return 8;
            break;
        case WST:
            return 8;
            break;
        case ALMST:
            return 7;
            break;
        case CXT:
            return 7;
            break;
        case MMT:
            return 6.5;
            break;
        case ALMT:
            return 6;
            break;
        case IST2:
            return 5.5;
            break;
        case IOT:
            return 5;
            break;
        case MVT:
            return 5;
            break;
        case TFT:
            return 5;
            break;
        case AFT:
            return 4.5;
            break;
        case MUT:
            return 4;
            break;
        case RET:
            return 4;
            break;
        case SCT:
            return 4;
            break;
        case IT:
            return 3.5;
            break;
        case BT:
            return 3;
            break;
        case EETDST:
            return 3;
            break;
        case CETDST:
            return 2;
            break;
        case EET:
            return 2;
            break;
        case FWT:
            return 2;
            break;
        case IST:
            return 2;
            break;
        case MEST:
            return 2;
            break;
        case METDST:
            return 2;
            break;
        case SST:
            return 2;
            break;
        case BST:
            return 1;
            break;
        case CET:
            return 1;
            break;
        case DNT:
            return 1;
            break;
        case FST:
            return 1;
            break;
        case MET:
            return 1;
            break;
        case MEWT:
            return 1;
            break;
        case MEZ:
            return 1;
            break;
        case NOR:
            return 1;
            break;
        case SWT:
            return 1;
            break;
        case WETDST:
            return 1;
            break;
        case GMT:
            return 0;
            break;
        case WET:
            return 0;
            break;
        case UTC:
            return 0;
            break;
        case WAT:
            return -1;
            break;
        case FNST:
            return -1;
            break;
        case FNT:
            return -2;
            break;
        case BRST:
            return -2;
            break;
        case NDT:
            return -2.5;
            break;
        case ADT:
            return -3;
            break;
        case BRT:
            return -3;
            break;
        case NFT:
            return -3.5;
            break;
        case AST:
            return -4;
            break;
        case ACST:
            return -4;
            break;
        case EDT:
            return -4;
            break;
        case ACT:
            return -5;
            break;
        case CDT:
            return -5;
            break;
        case EST:
            return -5;
            break;
        case CST:
            return -6;
            break;
        case MDT:
            return -6;
            break;
        case MST:
            return -7;
            break;
        case PDT:
            return -7;
            break;
        case PST:
            return -8;
            break;
        case YDT:
            return -8;
            break;
        case HDT:
            return -9;
            break;
        case YST:
            return -9;
            break;
        case AHST:
            return -10;
            break;
        case CAT:
            return -10;
            break;
        case NT:
            return -11;
            break;
        case IDLW:
            return -12;
            break;
            
        default:
            break;
    }
    return 0;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    float diff = [self getAllTimeZoneTimeDiff:(int)indexPath.row];
    NSDate *newdate = [[NSDate date] initWithTimeInterval:diff *60 * 60 sinceDate:nowDate];
   
   
    cell.textLabel.text = [dateFormatter stringFromDate:newdate];
    NSString * text = [self.tz_list objectAtIndex:indexPath.row];
  
    if (diff-(int)diff == 0) {
        
        if (diff >= 0 )
            text = [NSString stringWithFormat:@"%@ (GMT +%d:00)",text, (int)diff];
        else
            text = [NSString stringWithFormat:@"%@ (GMT %d:00)", text,(int)diff];
        
    } else {
        
        if (diff >= 0 )
            text = [NSString stringWithFormat:@"%@ (GMT +%d:30)",text ,(int)diff];
        else
            text = [NSString stringWithFormat:@"%@ (GMT %d:30)", text,(int)diff];
    }
    
    cell.detailTextLabel.text = text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tz_list.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [[TopGLAPIManager shareManager] deviceTimezoneWithMd5:self.mainDeviceInfo.md5 action:GLTimezoneActionTimezoneActionSet timezone:[self getAllTimeZoneTimeDiff:(int)indexPath.row] * 60 complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk ) {
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
}



@end
