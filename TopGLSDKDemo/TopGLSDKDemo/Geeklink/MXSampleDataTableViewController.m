#import "MXSampleDataTableViewController.h"

#import "MoreViewController.h"
#import "GlobalVars.h"


#define TestNotification @"testnotify"

NSString *const CellIdentifier = @"GLCell";

@interface MXSampleDataTableViewController (){
    UIButton *testBtn;
    UIButton *timerBtn;
    UILabel *stateL;
    NSString *results;
    UIView *headerView;
    GlobalVars *global;
    
}
//@property (nonatomic,retain) UIButton *testBtn;

@property (nonatomic) uint8_t PlugState;


@end

@implementation MXSampleDataTableViewController
@synthesize PlugState;
//@synthesize testBtn;

- (instancetype) initWithApi:(id<GLApi>)api {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        global = [GlobalVars shareGlobalVars];
        global.api = api;
        global.plug_handle = [api observerPlugHandle];
        global.device_handle = [api observerDeviceHandle];
        global.user_handle = [api observerUserHandle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = [self.api getCurUsername];
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    headerView.userInteractionEnabled = YES;
    testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.frame = CGRectMake(110, 50, 100, 100);
//    [testBtn setAdjustsImageWhenDisabled:YES];
    [testBtn addTarget:self action:@selector(testBtnClick) forControlEvents:UIControlEventTouchUpInside];
    testBtn.backgroundColor = [UIColor grayColor];
    [headerView addSubview:testBtn];
    
    timerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    timerBtn.frame = CGRectMake(250, 80, 50, 50);
    //    [testBtn setAdjustsImageWhenDisabled:YES];
    [timerBtn addTarget:self action:@selector(testUserCmd) forControlEvents:UIControlEventTouchUpInside];
    timerBtn.backgroundColor = [UIColor grayColor];
    [headerView addSubview:timerBtn];

    
    stateL = [[UILabel alloc]initWithFrame:CGRectMake(10, 170, 300, 30)];
    [stateL setTextAlignment:NSTextAlignmentCenter];
    [stateL setText:@"not connect"];
    [headerView addSubview:stateL];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableHeaderView.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateBtnColor) name:TestNotification object:nil];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
}

- (void)testBtnClick
{
    int8_t state;
//    [self updateBtnColor];
    NSLog(@"testBtn ===");
    if (PlugState) {
        state = 0;
    }
    else
    {
        state = 1;
    }
    GLPlugCcInfo *ccInfo = [[GLPlugCcInfo alloc]initWithPlugAction:2 plugState:state plugDelay:0 plugStateAfterDelay:0];
    
    [global.plug_handle plugAction:1 plugAction:ccInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    // todo(piet) what is the proper 'weak-ref' style here
    NSLog(@"viewWillAppear");
    [global.plug_handle init:self];
    [global.device_handle init:self];
//    [self.user_handle init:self];
    NSLog(@"view appear end");
}

- (void)viewWillDisappear:(BOOL)animated {
//    [self.handle stop];
}

- (NSInteger)getTime:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:date];
    
    return ([comps hour]*60 + [comps minute]+1);// for test ,add one more minutes
}

- (void)testPlugTimerAdd
{
    
    NSLog(@"time min:%d",[self getTime:[NSDate date]]);
    GLPlugTimerInfo *timerInfo = [[GLPlugTimerInfo alloc]initWithTimerId:1 timerOrder:1 timerOnoff:1 timerState:0 timerWeek:0xff timerDelayOnoff:0 timerName:@"test" timerTime:[self getTime:[NSDate date]] timerDelayTime:0];
    GLPlugTimerActionInfo *action = [[GLPlugTimerActionInfo alloc]initWithAction:GLPlugTimerActionPlugTimerActionAdd timerInfo:timerInfo];
    [global.plug_handle plugTimerAction:1 timerAction:action];
//    [self.plug_handle getPlugTimerList:1];
    
}

- (void)testUserCmd
{
    MoreViewController *moreVCtl = [[MoreViewController alloc]init];
    [self.navigationController pushViewController:moreVCtl animated:YES];
//    [self.navigationController presentViewController:moreVCtl animated:YES completion:nil];
}

- (void)updateBtnColor
{
    NSLog(@"update Btn color,plugState:%d",PlugState);
    if (PlugState) {
        NSLog(@"redcolor");
        testBtn.backgroundColor = [UIColor redColor];
        [testBtn setTitle:@"ON" forState:UIControlStateNormal];
    }
    else
    {
        NSLog(@"graycolor");
        testBtn.backgroundColor = [UIColor grayColor];
        [testBtn setTitle:@"OFF" forState:UIControlStateNormal];
    }
    [headerView setNeedsDisplay];
//    [self.tableView reloadData];
}

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"title" message:message delegate:self cancelButtonTitle:@"sure" otherButtonTitles:@"no",nil];
    [alert show];
}

- (void)onUpdate:(NSString *)result
{
    NSLog(@"onUpdate,result:%@",result);
    [self showAlert:result];
    [stateL setText:result];
    results = result;
//    [self.tableView reloadData];
    
}
- (void)onGetPlugTimerListResponse:(int32_t)plugId timerList:(NSArray *)timerList
{
    NSLog(@"timer list count:%d",timerList.count);
    for (GLPlugTimerInfo *timerInfo in timerList) {
        NSLog(@"timer id:%d",timerInfo.timerId);
        NSLog(@"%@",timerInfo.timerName);
    }
    
}

- (void)onPlugActionResponse:(int32_t)plugId plugCcBack:(GLPlugCcInfo *)plugCcBack
{
    NSLog(@"plug state:%d",[plugCcBack plugState]);
    PlugState = [plugCcBack plugState];
    [self.tableView reloadData];
    [self updateBtnColor];
}

- (void)onPlugTimerActionResponse:(int32_t)plugId ackInfo:(GLPlugTimerActionAckInfo *)ackInfo
{
    NSLog(@"onPlugTimerActionResponse,action:%d,state:%d",ackInfo.action,(int)ackInfo.stateAck);
}

- (void)onFindplugResponse:(NSArray *)plugs
{
    
}

- (void)onPlugCcResponse:(int32_t)plugId plugCcBack:(GLPlugCcInfo *)plugCcBack
{
    NSLog(@"plug state:%d",[plugCcBack plugState]);
    PlugState = [plugCcBack plugState];
    [self.tableView reloadData];
    [self updateBtnColor];
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:TestNotification object:nil];
//    [self performSelector:@selector(updateBtnColor) withObject:nil afterDelay:0.2];
}

- (void)onPlugTimezoneResponse:(int32_t)plugId timezone:(int8_t)timezone
{
    
}


/**在做获取某个设备下的用户列表时的回调函数，通过参数返回操作状态以及该设备下的用户列表。 */
- (void)onGetDevUserlistResponse:(GLDevOperateCommondState)status userlist:(NSArray *)userlist
{
    
}

/**获取某个用户列表下的设备操作的回调函数，通过参数返回状态及该用户下的设备列表 */
- (void)onGetUserDevlistResponse:(GLDevOperateCommondState)status devlist:(NSArray *)devlist
{
    
}

/**在将一个用户和设备进行绑定的操作回调函数，通过参数返回状态，以及相关的绑定操作内容 */
- (void)onBindDevActionResponse:(GLBindDevState)status bindAction:(GLBindDevAction)bindAction
{
    
}

/**管理员操作普通用户回调函数，返回操作状态。 */
- (void)onAdminActionResponse:(GLUserOperateCommonState)status
{
    
}

/**寻找新设备回调函数，返回找到的设备列表 */
- (void)onFindNewDevice:(NSArray *)discoverDevList
{
    NSLog(@"find dev num:%ld",(long)discoverDevList.count);
    for (GLDevInfo *dev_info in discoverDevList) {
        NSLog(@"dev id:%d,type:%ld,name:%@",dev_info.devId,(long)dev_info.devType,dev_info.devName);
    }
    
    
}

/**时区操作回调函数，返回时区数据 */
- (void)onDevTimezoneAction:(GLTimezoneActionInfo *)actInfo
{
    
}

/**发现、绑定开关操作回调函数 */
- (void)onDiscoverBindSwitchAction:(GLDiscoverBindInfo *)actionInfo
{
    
}

/**设备名字操作回调函数 */
- (void)onDevnameActionResponse:(GLGlNameActionInfo *)nameActionInfo
{
    
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//      [self updateBtnColor];
//    [stateL setText:results];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
//    NSLog(@"results:%@",results);
//    [cell.textLabel setText:results];
    return cell;
}

@end
