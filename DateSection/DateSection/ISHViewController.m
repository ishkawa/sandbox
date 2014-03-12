#import "ISHViewController.h"
#import "ISHItem.h"

static NSString *const ISHCellReuseIdentifier = @"ISHCellReuseIdentifier";
static NSTimeInterval const ISHItemsInterval = 3600.0;

@implementation ISHViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentDirectoryURL = [URLs lastObject];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DateSection" withExtension:@"momd"];
        NSURL *storeURL = [documentDirectoryURL URLByAppendingPathComponent:@"DateSection.sqlite"];
        
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *coordinator  = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSError *error = nil;
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        context.persistentStoreCoordinator = coordinator;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ISHItem"];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"date"
                                                                                   cacheName:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Date Section";
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ISHCellReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self insertItems];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [NSException raise:NSInternalInconsistencyException format:@"%@", error];
    }
    
    [self.tableView reloadData];
}

#pragma mark -

- (void)insertItems
{
    NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
    for (NSInteger index = 0; index < 100; index++) {
        ISHItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"ISHItem"
                                                      inManagedObjectContext:context];
        item.date = [NSDate dateWithTimeIntervalSinceNow:index * ISHItemsInterval];
        item.identifier = @(index);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ISHItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ISHCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [item.identifier stringValue];
    
    return [[UITableViewCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

@end
