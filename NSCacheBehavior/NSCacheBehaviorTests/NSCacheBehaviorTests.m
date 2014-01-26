#import <XCTest/XCTest.h>

@interface NSCacheBehaviorTests : XCTestCase <NSCacheDelegate> {
    NSCache *cache;
    BOOL evicted;
}

@end

@implementation NSCacheBehaviorTests

- (void)setUp
{
    [super setUp];
    
    cache = [[NSCache alloc] init];
    cache.delegate = self;
    
    evicted = NO;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)object
{
    evicted = YES;
}

#pragma mark -

- (void)test
{
    [cache setObject:@"foo" forKey:@"foo"];
    [cache setObject:@"bar" forKey:@"bar"];
    [cache setObject:@"baz" forKey:@"baz"];
    
    cache.countLimit = 1;
    
    XCTAssertTrue(evicted);
}

@end
