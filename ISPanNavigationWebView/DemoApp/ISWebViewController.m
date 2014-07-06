#import "ISWebViewController.h"
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

@implementation ISWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    self.progressView = [[NJKWebViewProgressView alloc] init];
    self.progressView.frame = CGRectMake(0.f,
                                         CGRectGetHeight(navigationBar.frame) - 1.f,
                                         CGRectGetWidth(navigationBar.frame),
                                         2.f);
    [navigationBar addSubview:self.progressView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSURL *URL = [NSURL URLWithString:@"http://blog.github.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}

#pragma mark - ISPanNavigationWebViewDelegate

- (void)webView:(ISPanNavigationWebView *)webView didUpdateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
}

@end
