#import <UIKit/UIKit.h>
#import "gen/GLApi.h"

@interface MXSampleDataTableViewController : UITableViewController <GLGlPlugHandleObserver,GLGlDeviceHandleObserver>
- (instancetype) initWithApi:(id <GLApi>) api;

@end
