#import "ISHTableViewController.h"

static NSString *const ISHCellReuseIdentifier = @"ISHCellReuseIdentifier";

@implementation ISHTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Estimated Row Height";
    
    self.tableView.estimatedRowHeight = 10.f;
    self.tableView.rowHeight = 100.f;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ISHCellReuseIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:ISHCellReuseIdentifier forIndexPath:indexPath];
}

@end
