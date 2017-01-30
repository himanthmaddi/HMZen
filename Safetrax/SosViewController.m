//
//  SosViewController.m
//  Safetrax
//
//  Created by Kumaran on 02/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "SosViewController.h"
#import "AppDelegate.h"
NSIndexPath *oldPath;
static BOOL firstSelect = TRUE;
@interface SosViewController ()
{
    NSArray *finalArray;
    NSArray *phoneArray;
}
@end
@implementation SosViewController
@synthesize phoneNum,empId,bloodGroup,currentLocation,name,scrollView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model withDataDictionary:(NSMutableDictionary *)data {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tripModel = model;
        DataDictionary = data;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"tripmodel %@",tripModel);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOS Message"
                                                    message:@"SOS Message Sent Successfully!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}
- (void)viewDidLoad
{
    if(tripModel)
      [self loadTable];
    [super viewDidLoad];
    self.SOStable.delegate = self;
    self.SOStable.dataSource =self;
    self.SOStable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    empId.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    name.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
    phoneNum.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"phonenum"];
}
-(void)loadTable
{
    NSLog(@"loadtable");
    tableTitles = [[NSMutableArray alloc] init];
    [tableTitles removeAllObjects];
    [tableTitles addObject:@"Driver's Info"];
    [tableTitles addObject:@"Co Passengers"];
    [tableTitles addObject:@"Emergency Info"];
    currentExpandedIndex = -1;
    NSString *Name=[NSString stringWithFormat:@"Name:%@",tripModel.driverName];
    NSString *Vehicle=[NSString stringWithFormat:@"Vehicle:%@",tripModel.driverLicence];
    NSString *Phone=[NSString stringWithFormat:@"Phone:+91%@",tripModel.driverPhone];
    NSArray *SOSDetails =[[NSArray alloc] initWithObjects:Name,Vehicle,Phone,nil];
    [DataDictionary setObject:SOSDetails forKey:@"Driver's Info"];
    subarray = [NSMutableArray new];
    currentExpandedIndex = -1;
    for (int i = 0; i < [tableTitles count]; i++) {
        if([self subItems:i]){
            [subarray addObject:[self subItems:i]];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)safe:(id)sender
{
    UIButton *button=(UIButton *)sender;
    button.selected =YES;
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:@""
                            message:@"Are You Safe?"
                            delegate:self
                            cancelButtonTitle:@"No"
                            otherButtonTitles:@"Yes",nil];
    [myAlert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (buttonIndex == 0){
//        double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
//        double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
//        
//        NSLog(@"%f%f",[[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"],[[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"]);
//        long double today = [[NSDate date] timeIntervalSince1970];
//        NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
//        long double mine = [str1 doubleValue]*1000;
//        NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
//        NSString *colName;
//        colName = @"sosmessages";
//        NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
//        NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
//        NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
//        NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
//        NSDictionary *finalDictionary;
//        NSArray *coordinatesArray;
//        coordinatesArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:longitude],[NSNumber numberWithDouble:latitude], nil];
//        finalDictionary= @{@"employeeId":employeeId,@"message":@"Not safe sending SOS again and again",@"mode":@"ios_app",@"time":todayTime,@"coordinates":coordinatesArray,@"address":[[NSUserDefaults standardUserDefaults] valueForKey:@"address"]};
//        NSLog(@"sending connection");
//
//        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
//        NSString *url;
//        if([Port isEqualToString:@"-1"])
//        {
//            url =[NSString stringWithFormat:@"%@://%@/triggersosapp?mode=ios-app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
//        }
//        else
//        {
//            url =[NSString stringWithFormat:@"%@://%@:%@/triggersosapp?mode=ios-app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
//        }
//        NSURL *URL =[NSURL URLWithString:url];
//        NSMutableURLRequest *NSRequest = [[NSMutableURLRequest alloc]initWithURL:URL];
//        [NSRequest setHTTPMethod:@"POST"];
//        NSError *error;
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalDictionary options:kNilOptions error:&error];
//        [NSRequest setHTTPBody:jsonData];
//        [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [NSRequest setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
//        NSURLConnection *connection = [NSURLConnection connectionWithRequest:NSRequest delegate:self];
//        [connection start];
    }
}
- (NSArray *)subItems:(int)index
{
    NSMutableArray *items = [NSMutableArray array];
    NSString *tripString =[tableTitles objectAtIndex:index];
    items =[DataDictionary objectForKey:tripString];
    NSLog(@"item %@--%@",items,[tableTitles objectAtIndex:index]);
    return items;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableTitles count] + ((currentExpandedIndex > -1) ? [[subarray objectAtIndex:currentExpandedIndex] count] : 0);
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
        return nil;
    }
    return indexPath;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ParentCellIdentifier = @"ParentCell";
    static NSString *ChildCellIdentifier = @"ChildCell";
    BOOL isChild =
    currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + [[subarray objectAtIndex:currentExpandedIndex] count];
    UITableViewCell *cell;
    if (isChild) {
      }
    else {
        
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ParentCellIdentifier];
    }
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.subviews];
    for (UIView *subview in subviews)
    {
        if([subview isKindOfClass:[UIButton class]])
        [subview removeFromSuperview];
    }
     if (isChild) {
        NSLog(@"child");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *cellText=[[subarray objectAtIndex:currentExpandedIndex] objectAtIndex:indexPath.row - currentExpandedIndex - 1];
         cell.detailTextLabel.text = cellText;
         cell.detailTextLabel.numberOfLines = 0;
        if(currentExpandedIndex >0){
            if([cellText isEqualToString:@""]){
            
            }
        else{
        UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        callButton.frame = CGRectMake(250.0f, 5.0f, 30, 30);
        [callButton setTitle:cell.detailTextLabel.text forState:UIControlStateNormal];
        [callButton setImage:[UIImage imageNamed:@"_0021_call.png"] forState:UIControlStateNormal];
        [callButton addTarget:self
                       action:@selector(call:)
                  forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:callButton];
        }
      }
    }
    else {
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex) ? indexPath.row - [[subarray objectAtIndex:currentExpandedIndex] count] : indexPath.row;
        cell.textLabel.text = [tableTitles objectAtIndex:topIndex];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:13];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
        [cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
        cell.textLabel.textColor=[UIColor colorWithRed:0/255.0 green:159/255.0 blue:134/255.0 alpha:1];
    }
     return cell;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChild = currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + [[subarray objectAtIndex:currentExpandedIndex] count];
    if (isChild) {
        return;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParentCell"];
    [self.SOStable beginUpdates];
    if (currentExpandedIndex == indexPath.row) {
        NSLog(@"current index");
        [self collapseSubItemsAtIndex:currentExpandedIndex];
        currentExpandedIndex = -1;
       }
    else {
        BOOL shouldCollapse = currentExpandedIndex > -1;
        if (shouldCollapse) {
            NSLog(@"should collapse %ld--%ld",(long)oldPath.row,indexPath.row);
            [self collapseSubItemsAtIndex:currentExpandedIndex];
        }
        currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - [[subarray objectAtIndex:currentExpandedIndex] count] : indexPath.row;
        [self expandItemAtIndex:currentExpandedIndex];
    }
    [self.SOStable endUpdates];
    oldPath = indexPath;
}
- (void)expandItemAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    finalArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"copassengers"];
    [subarray removeObjectAtIndex:1];
    [subarray insertObject:finalArray atIndex:1];
    NSLog(@"subarray %@",subarray);
    NSArray *currentSubItems = [subarray objectAtIndex:index];
    NSLog(@"subarray %d-- %@",index,currentSubItems);
    int insertPos = index + 1;
    for (int i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.SOStable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.SOStable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)collapseSubItemsAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = index + 1; i <= index + [[subarray objectAtIndex:index] count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.SOStable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}
-(void)call:(id )sender
{
    int index;
    phoneArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"copassengerPhoneArray"];
    
    UIButton *callButton = (UIButton *)sender;
    NSString *cellText = callButton.titleLabel.text;
    if ([finalArray containsObject:cellText]){
        index = [finalArray indexOfObject:cellText];
        NSLog(@"%i",index);
    }
    NSArray *empDetails = [cellText componentsSeparatedByString:@"\n"];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[phoneArray objectAtIndex:index]]];
   if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
       UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}
-(void)message:(id )sender
{
}
@end
