//
//  HistoryViewController.m
//  Safetrax
//
//  Created by Kumaran on 26/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "HistoryViewController.h"
#import "MFSideMenu.h"
#import "TripCollection.h"
#import "TripModel.h"
#import "SOSMainViewController.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface HistoryViewController ()
@end
extern NSArray *tripList;
@implementation HistoryViewController
@synthesize historyTable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.historyTable reloadData];
}
- (void)viewDidLoad {
    self.view.frame = [[UIScreen mainScreen] bounds];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    self.historyTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.historyTable];
    self.historyTable.delegate = self;
    self.historyTable.dataSource =self;
    [super viewDidLoad];
    [self startFetchingHistory];
    // Do any additional setup after loading the view from its nib.
}
-(void)startFetchingHistory
{
    _responseData = nil;
    _responseData = [[NSMutableData alloc] init];
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *userid=[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd--HH:mm:ss"];
    NSString *schedule_date = [dateFormatter stringFromDate:currDate];
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password",userid,@"userid",schedule_date,@"schedule_date", nil];
    MongoRequest *requestWraper =[[MongoRequest alloc]initWithTrips];
    [requestWraper setPostParams:newDatasetInfo];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}
#pragma mark Tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        if([tripsSection2History count] >0)
          return 2;
        else if([tripsSection1History count] >0)
          return 1;
        else
          return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return [tripsSection1History count];
    else if(section == 1)
        return [tripsSection2History count];
    else
        return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString;
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    dateString = [uniqueHistory objectAtIndex:section];
    [dateFormatters setDateFormat:@"YYYY/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatters dateFromString:dateString];
    NSString * deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    dateFormatters = [NSDateFormatter new];
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguage];
    [dateFormatters setDateFormat:@"EEEE, dd MMM, yyyy"];
    [dateFormatters setLocale:locale];
    dateString = [dateFormatters stringFromDate:dateFromString];
    return dateString;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *Cell = [self.historyTable dequeueReusableCellWithIdentifier:@"cell"];
    NSString *dateString ;
    if(Cell == nil)
    {
        Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.section==0) {
        Cell.textLabel.text = [[tripsSection1History objectAtIndex:indexPath.row] substringToIndex:[[tripsSection1History objectAtIndex:indexPath.row] length]-2];
        dateString = [[tripsSection1History objectAtIndex:indexPath.row] substringFromIndex: [[tripsSection1History objectAtIndex:indexPath.row] length] - 2];
    }
    else
    {
        Cell.textLabel.text = [[tripsSection2History objectAtIndex:indexPath.row] substringToIndex:[[tripsSection2History objectAtIndex:indexPath.row] length]-2];
        dateString = [[tripsSection2History objectAtIndex:indexPath.row] substringFromIndex: [[tripsSection2History objectAtIndex:indexPath.row] length] - 2];
    }
    NSInteger time =[dateString integerValue];
    if(time >=5 && time <18)
    {
        Cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"_0013_sun.png"]];
    }
    else
    {
        Cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"_0014_moon.png"]];
    }
    [Cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
    Cell.textLabel.numberOfLines = 5;
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowNumber = 0;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    rowNumber += indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
    tripSummary = [[tripSummaryViewController alloc] initWithNibName:@"tripSummaryViewController"  bundle:Nil tripArray:tripList selectedIndex:(int)rowNumber withHome:self];
    tripSummary.modalPresentationStyle = UIModalPresentationFormSheet;
    tripSummary.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:tripSummary animated:YES completion:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        return 100.0;
    else
        return UITableViewAutomaticDimension;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Menu Event
- (void)menuStateEventOccurred:(NSNotification *)notification {
    //When menu is closed, make the blurred view dynamic again
    MFSideMenuStateEvent event = [[notification userInfo][@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose){
        infoView.dynamic = YES;
    }
}
-(IBAction)openMenu:(id)sender{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    infoView.dynamic = NO;
}
-(IBAction)sos:(id)sender {
    SOSMainViewController *sosController;
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }
    [self presentViewController:sosController animated:YES completion:nil];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
}
-(void)onFailure
{
   NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
   NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    NSString* newStr = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"trip %@",newStr);
    id obj = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    if([obj isKindOfClass:[NSDictionary class]]){
        if([obj objectForKey:@"error"]){
            NSLog(@"error at finding history trips");
        }
    }
    else
        
    {
        [self addTrip];
   }
}
-(void)addTrip
{
    TripCollection *tripcollection  = [TripCollection buildFromdata:_responseData];
    [tripcollection saveTripArray];
    tripDropHistory =[tripcollection getDrop];
    tripPickupHistory =[tripcollection getPickup];
    [tripcollection sortTrip];
    tripList =[[tripcollection getTripList] mutableCopy];
    NSMutableArray * values = [[NSMutableArray alloc]initWithArray:[tripPickupHistory allKeys]];
    [values addObjectsFromArray:[tripDropHistory allKeys]];
    uniqueHistory = [NSMutableArray array];
    for (id obj in values) {
        if (![uniqueHistory containsObject:obj]) {
            [uniqueHistory addObject:obj];
        }
    }
    uniqueHistory = [uniqueHistory sortedArrayUsingSelector: @selector(compare:)];
    tripsSection1History =[[NSMutableArray alloc]init];
    tripsSection2History =[[NSMutableArray alloc]init];
    NSString *pickupValue;
    NSString *dropValue ;
    NSString *key;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *dateFromString = [[NSDate alloc] init];
    NSDate *lastDate = [[NSDate alloc] init];
    NSString *lastDateString = [uniqueHistory lastObject];;
    lastDate = [dateFormatter dateFromString:lastDateString];
    if([uniqueHistory count] >0){
        key =[uniqueHistory objectAtIndex:0];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        pickupValue =[tripPickupHistory objectForKey:key];
        dropValue =[tripDropHistory objectForKey:key];
        NSLog(@"pickup %@-key--%@",dropValue,key);
        if(pickupValue)
            [tripsSection1History addObject:pickupValue];
        if(dropValue)
            [tripsSection1History addObject:dropValue];
    }
    if([uniqueHistory count] >1){
        key =[uniqueHistory objectAtIndex:1];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        NSString *date = [key substringWithRange:NSMakeRange(0, 10)];
        pickupValue =[tripPickupHistory objectForKey:key];
        dropValue =[tripDropHistory objectForKey:key];
        if([date isEqualToString:[[uniqueHistory objectAtIndex:0] substringWithRange:NSMakeRange(0, 10)]])
        {
            if(pickupValue)
                [tripsSection1History addObject:pickupValue];
            if(dropValue)
                [tripsSection1History addObject:dropValue];
        }
        else{
            if(pickupValue)
                [tripsSection2History addObject:pickupValue];
            if(dropValue)
                [tripsSection2History addObject:dropValue];
        }
    }
    [self.historyTable reloadData];
}
@end
