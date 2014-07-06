#import <UIKit/UIKit.h>
#import "ISPanNavigationWebView.h"

@class NJKWebViewProgressView;

@interface ISWebViewController : UIViewController <ISPanNavigationWebViewDelegate>

@property (nonatomic, weak) IBOutlet ISPanNavigationWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@end
