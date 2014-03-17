#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "ISHManagedObject.h"

@interface CoreDataScalarAttributeTests : XCTestCase {
    NSManagedObjectContext *context;
}

@end

@implementation CoreDataScalarAttributeTests

- (void)setUp
{
    [super setUp];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelURL = [bundle URLForResource:@"Model" withExtension:@"momd"];

    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectoryURL = [URLs lastObject];
    NSURL *storeURL = [documentDirectoryURL URLByAppendingPathComponent:@"Model.sqlite"];

    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator  = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSError *error = nil;
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.persistentStoreCoordinator = coordinator;
}

- (void)tearDown
{
    [self deleteAllPersistentManagedObjects];
    [super tearDown];
}

#pragma mark -

- (NSArray *)persistentManagedObjects
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ISHManagedObject"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [NSException raise:NSInternalInconsistencyException format:@"fetch error: %@", error];
    }
    return results;
}

- (void)saveContext
{
    NSError *error = nil;
    if (![context save:&error]) {
        [NSException raise:NSInternalInconsistencyException format:@"save error: %@", error];
    }
}

- (void)deleteAllPersistentManagedObjects
{
    for (ISHManagedObject *managedObject in [self persistentManagedObjects]) {
        [context deleteObject:managedObject];
    }
    [self saveContext];
}

#pragma mark -

- (void)testExample
{
    ISHManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ISHManagedObject" inManagedObjectContext:context];
    managedObject.name = @"foo";
    managedObject.index = 123;
    managedObject.flag = YES;

    [self saveContext];

    ISHManagedObject *fetchedObject = [[self persistentManagedObjects] firstObject];
    XCTAssertEqualObjects(managedObject.name, fetchedObject.name);
    XCTAssertEqual(managedObject.index, fetchedObject.index);
    XCTAssertEqual(managedObject.flag, fetchedObject.flag);
}

@end
