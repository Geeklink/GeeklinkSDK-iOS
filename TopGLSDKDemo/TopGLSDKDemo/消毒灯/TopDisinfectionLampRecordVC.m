//
//  TopDisinfectionLampRecordVC.m
//  Geeklink
//
//  Created by 杨飞飞 on 2020/5/19.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopDisinfectionLampRecordVC.h"
#import <GeeklinkSDK/SDK.h>
#import "SVProgressHUD.h"
@interface TopDisinfectionLampRecordVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * records;
@end

@implementation TopDisinfectionLampRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [[TopGLDisinfectionLampAPIManager shareManager] getDisinfectionLampRecords:self.mainDeviceInfo.md5 complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            weakSelf.records = resucltInfo.disinfectionRecordList;
            [weakSelf.tableView reloadData];
        }
        
        
        
    }];
    // Do any additional setup after loading the view.
}

- (NSArray *)records {
    if (_records == nil) {
        _records = [NSArray array];
    }
    return _records;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopGLDisinfectionLampRecord * record = self.records[indexPath.section];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:record.time];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];

    
    NSString* timeStr =[dateFormat stringFromDate:date];
    cell.textLabel.text = timeStr;
    NSString * detailText = @"";
    switch (record.recordType) {
       
        case GLDisinfectionRecordTypeOperation: {
            NSString * opStr = [self getOpStrWithRecord:record];
            detailText = [NSString stringWithFormat:@"%@   %@",NSLocalizedString(@"Start Disinfection", @""),opStr];
        }
          
            break;
        case GLDisinfectionRecordTypeEnd:
            detailText = [NSString stringWithFormat:NSLocalizedString(@"End Disinfection, Duration: %d Min", @""), record.duration];
            break;
        case GLDisinfectionRecordTypePause:
            detailText = NSLocalizedString(@"Pause Disinfection       Detected Someone", @"");
            break;
        case GLDisinfectionRecordTypeRestore:
            detailText = NSLocalizedString(@"Recovery Disinfection      Device Automatic", @"");
            break;
        case GLDisinfectionRecordTypeCancel: {
            NSString * opStr = [self getOpStrWithRecord:record];
            detailText = [NSString stringWithFormat:@"%@   %@",NSLocalizedString(@"Cancel Disinfection", @""),opStr];
        }
           
            break;
        case GLDisinfectionRecordTypeChildLock:
            detailText = NSLocalizedString(@"CHILD LOCK", @"" );
            break;
    }
    cell.detailTextLabel.text = detailText;
    return cell;

}
- (NSString *) getOpStrWithRecord:(TopGLDisinfectionLampRecord *)record{
    NSString * opStr = @"";
    switch (record.operationType) {
     
        case GLDisinfectionOperationTypeOperator:
            break;
        case GLDisinfectionOperationTypeTimer:
            opStr = NSLocalizedString(@"Timing Start", @"");
            break;
        case GLDisinfectionOperationTypeApp:
            opStr = record.account;
            break;
        case GLDisinfectionOperationTypeHardware:
            opStr = NSLocalizedString(@"Device Control", @"" );
            break;
    }
    return opStr;

}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.records.count;
}

@end
