#import "ISPanNavigationWebView.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>

static NSTimeInterval const ISPanDuration = 0.3;
static CGFloat const ISParallaxCoefficient = 0.3;

@interface ISPanNavigationWebView () <UIGestureRecognizerDelegate, UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, readonly) NJKWebViewProgress *progressProxy;
@property (nonatomic, readonly) UIScreenEdgePanGestureRecognizer *backGestureRecognizer;
@property (nonatomic, readonly) UIScreenEdgePanGestureRecognizer *forwardGestureRecognizer;
@property (nonatomic, readonly) NSMutableArray *webViews;
@property (nonatomic, readonly) UIWebView *previousWebView;
@property (nonatomic, readonly) UIWebView *nextWebView;
@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, strong) UIWebView *currentWebView;
@property (nonatomic, strong) UIWebView *loadingWebView;

@end

@implementation ISPanNavigationWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (void)commonInitialize
{
    _backGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
    _backGestureRecognizer.edges = UIRectEdgeLeft;
    _backGestureRecognizer.delegate = self;
    [_backGestureRecognizer addTarget:self action:@selector(handleBackGesture:)];
    [self addGestureRecognizer:_backGestureRecognizer];
    
    _forwardGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
    _forwardGestureRecognizer.edges = UIRectEdgeRight;
    _forwardGestureRecognizer.delegate = self;
    [_forwardGestureRecognizer addTarget:self action:@selector(handleForwardGesture:)];
    [self addGestureRecognizer:_forwardGestureRecognizer];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _webViews = [[NSMutableArray alloc] init];
    
    self.currentWebView = [[UIWebView alloc] init];
}

#pragma mark - UIWebView

- (UIScrollView *)scrollView
{
    return self.loadingWebView.scrollView ?: self.currentWebView.scrollView;
}

- (NSURLRequest *)request
{
    return self.loadingWebView.request ?: self.currentWebView.request;
}

- (BOOL)canGoBack
{
    return self.currentIndex > 0;
}

- (BOOL)canGoForward
{
    return self.currentIndex < self.webViews.count - 1;
}

- (void)loadRequest:(NSURLRequest *)request
{
    [self.loadingWebView stopLoading];
    
    if (self.currentWebView.request) {
        self.loadingWebView = [[UIWebView alloc] init];
        self.loadingWebView.delegate = self.progressProxy;
        [self.loadingWebView loadRequest:request];
    } else {
        [self.currentWebView loadRequest:request];
    }
}

- (void)reload
{
    [self.currentWebView reload];
}

- (void)stopLoading
{
    [self.currentWebView stopLoading];
    [self.loadingWebView stopLoading];
}

- (void)goBack
{
    if (self.canGoBack) {
        self.currentWebView = self.webViews[self.currentIndex - 1];
    }
}

- (void)goForward
{
    if (self.canGoForward) {
        self.currentWebView = self.webViews[self.currentIndex + 1];
    }
}

#pragma mark -

- (NSInteger)currentIndex
{
    return [self.webViews indexOfObject:self.currentWebView];
}

- (UIView *)previousWebView
{
    return self.canGoBack ? self.webViews[self.currentIndex - 1] : nil;
}

- (UIView *)nextWebView
{
    return self.canGoForward ? self.webViews[self.currentIndex + 1] : nil;
}

- (void)setCurrentWebView:(UIWebView *)currentWebView
{
    [self setCurrentWebView:currentWebView prune:NO];
}

- (void)setCurrentWebView:(UIWebView *)currentWebView prune:(BOOL)prune
{
    [self.webViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (prune) {
        for (UIWebView *webView in [self.webViews copy]) {
            if ([self.webViews indexOfObject:webView] > self.currentIndex) {
                [self.webViews removeObject:webView];
            }
        }
    }
    
    currentWebView.frame = self.bounds;
    currentWebView.scrollView.contentInset = self.currentWebView.scrollView.contentInset;
    currentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    currentWebView.delegate = self.progressProxy;
    currentWebView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    currentWebView.layer.shadowOpacity = 1.f;
    
    if (![self.webViews containsObject:currentWebView]) {
        [self.webViews addObject:currentWebView];
    }
    
    _currentWebView = currentWebView;
    
    self.previousWebView.frame = self.bounds;
    self.currentWebView.frame = self.bounds;
    self.nextWebView.frame = CGRectOffset(self.bounds, self.bounds.size.width, 0.f);
    
    [self addSubview:self.previousWebView];
    [self addSubview:self.currentWebView];
    [self addSubview:self.nextWebView];
}

#pragma mark - back gesture

- (void)handleBackGesture:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    CGSize size = self.bounds.size;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGFloat x = [recognizer translationInView:self].x;
            self.currentWebView.layer.shadowOpacity = 1.f - ABS(x / size.width);
            self.currentWebView.frame = CGRectMake(x, 0.f, size.width, size.height);
            self.previousWebView.frame = CGRectMake((x - size.width) * ISParallaxCoefficient, 0.f, self.bounds.size.width, self.bounds.size.height);
            self.currentWebView.scrollView.scrollEnabled = NO;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            [self finishBackGesture:recognizer completed:[recognizer velocityInView:self].x > 0.f];
            break;
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            [self finishBackGesture:recognizer completed:NO];
            break;
    }
}

- (void)finishBackGesture:(UIScreenEdgePanGestureRecognizer *)recognizer completed:(BOOL)completed
{
    self.currentWebView.scrollView.scrollEnabled = YES;
    
    CGFloat x = completed ? self.bounds.size.width : 0.f;
    CGFloat distance = ABS([recognizer translationInView:self].x - x);
    NSTimeInterval duration = MIN(distance / ABS([recognizer velocityInView:self].x), ISPanDuration);
    [UIView animateWithDuration:duration animations:^{
        self.currentWebView.frame = CGRectMake(x, 0.f, self.bounds.size.width, self.bounds.size.height);
        self.previousWebView.frame = CGRectMake((x - self.bounds.size.width) * ISParallaxCoefficient, 0.f, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        if (completed) {
            [self goBack];
        }
    }];
}

#pragma mark - forward gesture

- (void)handleForwardGesture:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    CGSize size = self.bounds.size;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGFloat x = [recognizer translationInView:self].x;
            self.nextWebView.layer.shadowOpacity = 1.f - ABS(x / size.width);
            self.nextWebView.frame = CGRectMake(size.width + x, 0.f, size.width, size.height);
            self.currentWebView.frame = CGRectMake(x * ISParallaxCoefficient, 0.f, self.bounds.size.width, self.bounds.size.height);
            self.currentWebView.scrollView.scrollEnabled = NO;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            [self finishForwardGesture:recognizer completed:[recognizer velocityInView:self].x < 0.f];
            break;
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            [self finishForwardGesture:recognizer completed:NO];
            break;
    }
}

- (void)finishForwardGesture:(UIScreenEdgePanGestureRecognizer *)recognizer completed:(BOOL)completed
{
    self.currentWebView.scrollView.scrollEnabled = YES;
    
    CGFloat x = completed ? 0.f : self.bounds.size.width;
    CGFloat distance = ABS([recognizer translationInView:self].x - x);
    NSTimeInterval duration = MIN(distance / ABS([recognizer velocityInView:self].x), ISPanDuration);
    [UIView animateWithDuration:duration animations:^{
        self.nextWebView.frame = CGRectMake(x, 0.f, self.bounds.size.width, self.bounds.size.height);
        self.currentWebView.frame = CGRectMake(completed ? -self.bounds.size.width * ISParallaxCoefficient : 0.f, 0.f, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        if (completed) {
            [self goForward];
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        if (![self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType]) {
            return NO;
        }
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self loadRequest:request];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    if (progress >= 0.5 && self.loadingWebView) {
        [self setCurrentWebView:self.loadingWebView prune:YES];
        self.loadingWebView = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(webView:didUpdateProgress:)]) {
        [self.delegate webView:self didUpdateProgress:progress];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return gestureRecognizer == self.backGestureRecognizer || gestureRecognizer == self.forwardGestureRecognizer;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.backGestureRecognizer) {
        return self.canGoBack;
    }
    
    if (gestureRecognizer == self.forwardGestureRecognizer) {
        return self.canGoForward;
    }
    
    return NO;
}

@end
