#import <UIKit/UIKit.h>

@protocol ISPanNavigationWebViewDelegate;

@interface ISPanNavigationWebView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@property (nonatomic, weak) id <ISPanNavigationWebViewDelegate> delegate;

- (void)loadRequest:(NSURLRequest *)request;
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;

@end

@protocol ISPanNavigationWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(ISPanNavigationWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(ISPanNavigationWebView *)webView;
- (void)webViewDidFinishLoad:(ISPanNavigationWebView *)webView;
- (void)webView:(ISPanNavigationWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)webView:(ISPanNavigationWebView *)webView didUpdateProgress:(float)progress;

@end
