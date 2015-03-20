//
//  HistoryViewController.m
//  wenduji
//
//  Created by LiPeng on 3/19/15.
//
//

#import "HistoryViewController.h"
#import "Record.h"

@interface HistoryViewController ()
@property (nonatomic, strong) NSMutableArray *historyDataArray;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)awakeFromNib
{
    [self setupData];
}

- (void)setupData
{
    self.historyDataArray = [NSMutableArray arrayWithCapacity:10];
    [_historyDataArray addObjectsFromArray:@[
                                  @[
                                      [Record recordWithDate:[NSDate date] temperature:[NSNumber numberWithFloat:36.5]],
                                      [Record recordWithDate:[NSDate date] temperature:[NSNumber numberWithFloat:36.6]],
                                      [Record recordWithDate:[NSDate date] temperature:[NSNumber numberWithFloat:36.7]]
                                  ],
                                  @[
                                      [Record recordWithDate:[NSDate dateWithTimeIntervalSinceNow:3600*24] temperature:[NSNumber numberWithFloat:37.5]],
                                      [Record recordWithDate:[NSDate dateWithTimeIntervalSinceNow:3600*24] temperature:[NSNumber numberWithFloat:37.6]],
                                      [Record recordWithDate:[NSDate dateWithTimeIntervalSinceNow:3600*24] temperature:[NSNumber numberWithFloat:37.7]]
                                    ]
                                  ]];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"recordCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Record *record = _historyDataArray[section][0];
//    return record.date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:record.date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_historyDataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_historyDataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"recordCell"];
    }

    Record *record = _historyDataArray[indexPath.section][indexPath.row];
    cell.textLabel.text = [record.temperature stringValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    cell.detailTextLabel.text = [formatter stringFromDate:record.date];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
