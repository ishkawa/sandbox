#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ISHItem : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSDate *date;

@end
