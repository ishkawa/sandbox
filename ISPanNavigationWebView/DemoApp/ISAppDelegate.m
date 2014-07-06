#import "ISAppDelegate.h"
#import <ISPanNavigationWebView/ISPanNavigationWebView.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

@implementation ISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"This is %@ demo.", [ISPanNavigationWebView class]);
    NSLog(@"using %@.", [NJKWebViewProgressView class]);
    return YES;
}

@end
