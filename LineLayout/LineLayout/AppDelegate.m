

#import "AppDelegate.h"

#import "ViewController.h"
#import "LineLayout.h"
#import "LineLayout.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LineLayout* lineLayout = [[LineLayout alloc] init];
    self.viewController = [[ViewController alloc] initWithCollectionViewLayout:lineLayout];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
