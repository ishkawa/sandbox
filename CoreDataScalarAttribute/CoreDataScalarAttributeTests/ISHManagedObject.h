#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ISHManagedObject : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic) int64_t index;
@property (nonatomic) BOOL flag;

@end
