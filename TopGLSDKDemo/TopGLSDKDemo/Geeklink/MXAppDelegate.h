#import <UIKit/UIKit.h>
#import "gen/GLApi.h"

@interface MXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id <GLApi> api;


@end
