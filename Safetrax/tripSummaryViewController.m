//
//  tripSummaryViewController.m
//  Safetrax
//
//  Created by Kumaran on 06/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//
#import "tripSummaryViewController.h"
#import "TripModel.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "RestClientTask.h"
#import "GCMRequest.h"
#import "AppDelegate.h"
#import "SOSMainViewController.h"
#import "HomeViewController.h"
#import "tripIDModel.h"
#import "StoppagesViewController.h"
#import "AFNetworking.h"
#import "AFURLSessionManager.h"
#import "SomeViewController.h"
#import <MBProgressHUD.h>
#import "SessionValidator.h"

NSMutableArray *flattenArray ;
NSMutableArray *coPassenger ;
NSMutableArray *ChildrenList;
@interface tripSummaryViewController ()
{
    tripIDModel *tripModelClass;
    NSMutableArray *myArray;
    UITableViewCell *cell;
    UIActivityIndicatorView *activityIndicator;
    UIButton *button;
    NSMutableArray *employeesArray;
    NSMutableArray *stopsArray;
    NSMutableArray *indexPathArrayForImages;
    NSMutableArray *finalStopsArray;
}

@end
@implementation NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end
@implementation tripSummaryViewController
@synthesize DriverName,VehicleName,startPoint,startTime,endPoint,endTime,summaryTable,boardedCab,timeTaken,phNumber,scrollview,waitingButton,boardedButton,tripLabel,reachedButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tripArray:(NSArray*)trips selectedIndex:(int)Index withHome:(HomeViewController*)homeobject {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedIndex =Index;
        home =homeobject;
        tripArray =trips;
        model = [tripArray objectAtIndex:selectedIndex];
    }
    return self;
}
-(void)getTripsArray:(NSArray *)trips selectedIndex:(int)Index withHome:(HomeViewController *)homeobject;
{
    selectedIndex =Index;
    home =homeobject;
    tripArray =trips;
    model = [tripArray objectAtIndex:selectedIndex];
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
-(void)viewWillAppear:(BOOL)animated{
    //
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _round1.layer.cornerRadius = 4;
        _round1.layer.masksToBounds = YES;
        _round2.layer.cornerRadius = 4;
        _round2.layer.masksToBounds = YES;
    });
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:model.scheduledTime];
    NSLog(@"%@",tripDate);
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSLog(@"time %@----%@",tripDate,dateFromString);
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    NSLog(@"difference %f",secondsBetween);
    //        if((secondsBetween < 1800))
    //        {
    //
    //        }
    //        else{
    //            waitingButton.enabled = FALSE;
    //            boardedButton.enabled = FALSE;
    //            reachedButton.enabled = FALSE;
    //            boardedButton.selected = TRUE;
    //
    //}
    
    NSDateFormatter *dateFormatter123 = [[NSDateFormatter alloc]init];
    [dateFormatter123 setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    //    for (NSArray *tempArray in [[NSUserDefaults standardUserDefaults] objectForKey:@"allTrips"])
    //    {
    //        myArray = [[NSMutableArray alloc]initWithArray:tempArray copyItems:YES];
    //    }
    
    if([model.empstatus isEqualToString:@"reached"]){
        boardedButton.selected = TRUE;
        boardedButton.enabled = FALSE;
        waitingButton.enabled = FALSE;
        [reachedButton setBackgroundImage:[UIImage imageNamed:@"_0012_office_active.png"] forState:UIControlStateNormal];
        UIButton *button=(UIButton *)[self.view viewWithTag:503];
        button.selected =YES;
        _tripConfirmationsButton.hidden = YES;
    }
    else{
        if([model.empstatus isEqualToString:@"incab"])
        {
            boardedButton.selected  = TRUE;
            waitingButton.enabled = FALSE;
            reachedButton.enabled = TRUE;
        }
        else if([model.empstatus isEqualToString:@"waiting_cab"])
        {
            waitingButton.selected = TRUE;
            reachedButton.enabled = FALSE;
        }
        else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"reached"] isEqualToString:@"YES"])
        {
            waitingButton.selected = FALSE;
            boardedButton.enabled = FALSE;
            reachedButton.enabled = TRUE;
            reachedButton.selected = TRUE;
            _tripConfirmationsButton.hidden = YES;
        }
        else
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
                
            }else{
                waitingButton.enabled = FALSE;
                boardedButton.enabled = FALSE;
                reachedButton.enabled = FALSE;
                boardedButton.selected = TRUE;
            }
        }
        NSLog(@"%@",model.empstatus);
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"employeePin"]){
        _pinImageView.hidden = NO;
        _pinLabel.hidden = NO;
    }else{
        _pinImageView.hidden = YES;
        _pinLabel.hidden = YES;
    }

    
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    
    _pinLabel.text = model.employeePin;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosEnabled"]){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OneTripIsInActive"]){
                _sosMainButton.hidden = NO;
            }else{
                _sosMainButton.hidden = YES;
            }
        }else{
            _sosMainButton.hidden = NO;
        }
    }else{
        _sosMainButton.hidden = YES;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"tripConfirmationsButtons"]){
        reachedButton.hidden = NO;
        waitingButton.hidden = NO;
        boardedButton.hidden = NO;
        _reachedLabel.hidden = NO;
        _boardedLabel.hidden = NO;
        _waitingLabel.hidden = NO;
        _tripConfirmationsButton.hidden = NO;
    }else{
        reachedButton.hidden = YES;
        waitingButton.hidden = YES;
        boardedButton.hidden = YES;
        _reachedLabel.hidden = YES;
        _boardedLabel.hidden = YES;
        _waitingLabel.hidden = YES;
        _tripConfirmationsButton.hidden = YES;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
    double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
    NSTimeInterval seconds = expireTime / 1000;
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSDate *date = [NSDate date];
    NSComparisonResult result = [date compare:expireDate];
    
    if(result == NSOrderedDescending || result == NSOrderedSame)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
            for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
            [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate dismiss_delegate:nil];
            [self.view removeFromSuperview];
        }else{
            SessionValidator *validator = [[SessionValidator alloc]init];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                NSLog(@"%@",result);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"no refresh");
    }
    
    
    NSNumber *callEnabledBool = [[NSUserDefaults standardUserDefaults] objectForKey:@"callEnabled"];
    if (callEnabledBool.boolValue == YES){
        
        _callButton.hidden = NO;
        _callLabel.hidden = NO;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
            _callButton.enabled = YES;
        }else{
            _callButton.enabled = NO;
        }
        
    }else{
        _callButton.hidden = YES;
        _callLabel.hidden = YES;
    }
    
    summaryTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, summaryTable.bounds.size.width, 18.0f)];
    
    CGRect frmaeTableView = summaryTable.frame;
    summaryTable.frame = CGRectMake(0, frmaeTableView.origin.y, self.view.frame.size.width, frmaeTableView.size.height);
    employeesArray = [[NSMutableArray alloc]init];
    stopsArray = [[NSMutableArray alloc]init];
    indexPathArrayForImages = [[NSMutableArray alloc]init];
    finalStopsArray = [[NSMutableArray alloc]init];
    
    if (model.entryTime || ![[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"] || [model.empstatus isEqualToString:@"incab"] || [model.empstatus isEqualToString:@"reached"]){
        _etaLabel.text = @"ETA";
        button.hidden = YES;
        startTime.text = @"--";
    }else{
        if ([model.tripType isEqualToString:@"Drop"]){
            startTime.text = @"--";
            button.hidden = YES;
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshForETA:nil];
                });
            });
        }
    }
    
    
    
    //    if ([model.tripType isEqualToString:@"Pickup"]){
    //
    //    }
    
    for (NSDictionary *dict in model.employeeInfoAray){
        [employeesArray addObject:[dict valueForKey:@"_employeeId"]];
        if ([dict valueForKey:@"boarded"]){
            [indexPathArrayForImages addObject:[dict valueForKey:@"userId"]];
        }
    }
    
    _totalTripIDSarray = [[NSMutableArray alloc]init];
    self.summaryTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.summaryTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [super viewDidLoad];
    scrollview.contentSize =CGSizeMake(320, 950);
    self.summaryTable.delegate = self;
    self.summaryTable.dataSource =self;
    DriverName.text = model.driverName;
    VehicleName.text = model.cabNumber;
    endTime.text= [NSString stringWithFormat:@"%@ %@",@"Arrival Time",[model.tripEndTime substringWithRange:NSMakeRange(12, 5)]];
    CGRect textRect = [model.pickup boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 18.0 ]}
                                                 context:nil];
    
    
    textRect.size.height =textRect.size.height+10;
    CGRect newFrame = startPoint.frame;
    newFrame.size.height = textRect.size.height;
    
    startPoint.frame = newFrame;
    [startPoint addConstraint:[NSLayoutConstraint constraintWithItem:startPoint
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute: NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:startPoint.frame.size.height]];
    NSLog(@"hi-->%f",startPoint.frame.size.height);
    startPoint.text=model.pickup;
    
    textRect = [model.drop boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 18.0 ]}
                                        context:nil];
    
    textRect.size.height =textRect.size.height+10;
    newFrame = endPoint.frame;
    newFrame.size.height = textRect.size.height;
    NSLog(@"hie-->%f",endPoint.frame.size.height);
    endPoint.frame = newFrame;
    [endPoint addConstraint:[NSLayoutConstraint constraintWithItem:endPoint
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:endPoint.frame.size.height]];
    endPoint.text=model.drop;
    phNumber.text =model.driverPhone;
    wayPoints =model.cabWaypoints;
    tripLabel.text = [NSString stringWithFormat:@"%@ at %@",model.tripType,[model.scheduledTime substringWithRange:NSMakeRange(12, 5)]];
    timeTaken.text =[model.scheduledTime substringWithRange:NSMakeRange(12, 5)];;
    NSDictionary* waypointdict;
    NSString *EmployeeDetails;
    EmployeeTripDetails = [[NSMutableArray alloc] init];
    NSString *scheduleTime;
    NSArray *colleague;
    NSMutableArray *allEmployees = [[NSMutableArray alloc] init];
    DropWayPointCoveredEmployees = [[NSMutableArray alloc]init];
    pickupWayPointCoveredEmployees = [[NSMutableArray alloc]init];
    DataDictionary = [[NSMutableDictionary alloc] init];
    for(int i=0;i<[wayPoints count];i++)
    {
        
        waypointdict =[model.cabWaypoints objectAtIndex:i];
        scheduleTime = waypointdict[@"scheduledTime"];
        colleague =waypointdict[@"employeesAssigned"];
        [allEmployees addObject:waypointdict[@"employeesAssigned"]];
        if (waypointdict[@"employeesInCab"]){
            [pickupWayPointCoveredEmployees addObject:waypointdict[@"employeesInCab"]];
        }
        if (waypointdict[@"employeesReached"]){
            [DropWayPointCoveredEmployees addObject:waypointdict[@"employeesReached"]];
        }
#if Parent
        ChildrenList =[[NSMutableArray alloc] init];
        NSArray *extras =  [[NSUserDefaults standardUserDefaults] arrayForKey:@"extras"];
        NSLog(@"extras %@",extras);
        [ChildrenList addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
        for(NSDictionary *dictionary in extras)
        {
            [ChildrenList addObject:[dictionary objectForKey:@"empid"]];
        }
        
        NSMutableSet* set1 = [NSMutableSet setWithArray:ChildrenList];
        NSMutableSet* set2 = [NSMutableSet setWithArray:colleague];
        [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
        
        NSArray* result = [set1 allObjects];
        NSLog(@"result %@",result);
        EmployeeDetails = [NSString stringWithFormat:@"%@ %@",waypointdict[@"waypointName"],[scheduleTime substringWithRange:NSMakeRange(12, 5)]];
        if([result count] > 0)
        {  [EmployeeTripDetails addObject:EmployeeDetails];
            [DataDictionary setObject:result forKey:EmployeeDetails];
        }
        
#else
        EmployeeDetails = [NSString stringWithFormat:@"%@ %@",waypointdict[@"waypointName"],[scheduleTime substringWithRange:NSMakeRange(12, 5)]];
        [EmployeeTripDetails addObject:EmployeeDetails];
        [DataDictionary setObject:colleague forKey:EmployeeDetails];
#endif
    }
    
    
    subarray = [NSMutableArray new];
    currentExpandedIndex = -1;
    for (int i = 0; i < [EmployeeTripDetails count]; i++) {
        [subarray addObject:[self subItems:i]];
    }
    flattenArray = [[NSMutableArray alloc] init];
    
    pickedEmployees = [[NSMutableArray alloc]init];
    dropeedEmployees = [[NSMutableArray alloc]init];
    
    for(NSArray *array in allEmployees)
    {
        [flattenArray addObjectsFromArray: array];
    }
    for (NSArray *array in pickupWayPointCoveredEmployees){
        [pickedEmployees addObjectsFromArray:array];
    }
    for (NSArray *array in DropWayPointCoveredEmployees){
        [dropeedEmployees addObjectsFromArray:array];
    }
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    [flattenArray removeObject: @""];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:flattenArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *new = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *ids =[NSString stringWithFormat:@"{\"empid\":{\"$in\":%@}}",new];
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *jsonStr= [NSString stringWithFormat:@"%@\n%@", newStr2, ids];
    NSLog(@"%@",jsonStr);
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"query" withMethod:@"POST" andColumnName:@"empinfo"];
    [requestWraper setPostParamFromString:jsonStr];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    _responseData = [[NSMutableData alloc] init];
    //    [RestClient execute];
}
- (NSArray *)subItems:(int)index {
    NSMutableArray *items = [NSMutableArray array];
    NSString *tripString =[EmployeeTripDetails objectAtIndex:index];
    items =[DataDictionary objectForKey:tripString];
    NSLog(@"items %@",items);
    return items;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return model.stopsNames.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"%@   -   %@",[model.stopsNames objectAtIndex:section],[model.stopTimes objectAtIndex:section]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return model.stopsNames.count;
    NSDictionary *tempDict;
    NSArray *finalIdsArray;
    for (NSDictionary *subDict in model.stoppagesArray){
        if ([[subDict valueForKey:@"name"] isEqualToString:[model.stopsNames objectAtIndex:section]]){
            NSUInteger indexpath = [model.stoppagesArray indexOfObject:subDict];
            tempDict = [model.stoppagesArray objectAtIndex:indexpath];
        }
    }
    NSArray *idArrayForPickUp = [tempDict valueForKey:@"_pickup"];
    NSArray *idsArrayForDrop = [tempDict valueForKey:@"_drop"];
    if (!idsArrayForDrop || !idsArrayForDrop.count){
        finalIdsArray = idArrayForPickUp;
    }
    else{
        finalIdsArray = idsArrayForDrop;
    }
    NSMutableArray *finalNamesArray = [[NSMutableArray alloc]init];
    NSMutableArray *finalIdsArrayForUsers = [[NSMutableArray alloc]init];
    for (int i=0;i<finalIdsArray.count;i++){
        for(NSDictionary *dict in model.employeeInfoAray){
            if ([[dict valueForKey:@"_employeeId"] isEqualToString:[finalIdsArray objectAtIndex:i]]){
                [finalNamesArray addObject:[dict valueForKey:@"fullName"]];
                [finalIdsArrayForUsers addObject:[dict valueForKey:@"userId"]];
            }
        }
    }
    return finalNamesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *tempDict;
    NSArray *finalIdsArray;
    for (NSDictionary *subDict in model.stoppagesArray){
        if ([[subDict valueForKey:@"name"] isEqualToString:[model.stopsNames objectAtIndex:indexPath.section]]){
            NSUInteger indexpath = [model.stoppagesArray indexOfObject:subDict];
            tempDict = [model.stoppagesArray objectAtIndex:indexpath];
        }
    }
    NSArray *idArrayForPickUp = [tempDict valueForKey:@"_pickup"];
    NSArray *idsArrayForDrop = [tempDict valueForKey:@"_drop"];
    if (!idsArrayForDrop || !idsArrayForDrop.count){
        finalIdsArray = idArrayForPickUp;
    }
    else{
        finalIdsArray = idsArrayForDrop;
    }
    NSMutableArray *finalNamesArray = [[NSMutableArray alloc]init];
    NSMutableArray *finalIdsArrayForUsers = [[NSMutableArray alloc]init];
    for (int i=0;i<finalIdsArray.count;i++){
        for(NSDictionary *dict in model.employeeInfoAray){
            if ([[dict valueForKey:@"_employeeId"] isEqualToString:[finalIdsArray objectAtIndex:i]]){
                [finalNamesArray addObject:[dict valueForKey:@"fullName"]];
                [finalIdsArrayForUsers addObject:[dict valueForKey:@"userId"]];
            }
        }
    }
    
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = [finalNamesArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [finalIdsArrayForUsers objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    
    if ([model.tripType isEqualToString:@"Pickup"]){
        if (indexPath.section == model.stopsNames.count-1){
            cell.accessoryView = nil;
        }
        else if ([indexPathArrayForImages containsObject:cell.detailTextLabel.text]){
            cell.accessoryView = [[UIImageView alloc]initWithImage:[self image:[UIImage imageNamed:@"boarded.png"] scaledToSize:CGSizeMake(30, 30)]];
        }else{
            cell.accessoryView = [[UIImageView alloc]initWithImage:[self image:[UIImage imageNamed:@"notboarded.png"] scaledToSize:CGSizeMake(30, 30)]];
        }
    }else{
        cell.accessoryView = nil;
    }
      return cell;
}
#pragma mark - Table view delegate
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
//        return nil;
//    }
//    return indexPath;
//}
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return NO;
}
- (void)expandItemAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSArray *currentSubItems = [subarray objectAtIndex:index];
    int insertPos = index + 1;
    for (int i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.summaryTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.summaryTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
- (void)collapseSubItemsAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = index + 1; i <= index + [[subarray objectAtIndex:index] count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.summaryTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(IBAction)showMap:(id)sender
{
#if Parent
    mapView = [[MapViewController alloc] initWithNibName:@"MapViewParent"  bundle:Nil model:model];
#else
    
    mapView = [[MapViewController alloc] initWithNibName:@"MapViewController"  bundle:Nil model:model withHome:home];
#endif
    mapView.modalPresentationStyle = UIModalPresentationFormSheet;
    mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:mapView animated:YES completion:nil];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
    id info_array= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([info_array isKindOfClass:[NSDictionary class]]){
        if([info_array objectForKey:@"error_code"])
        {
            NSNumber *error=[info_array objectForKey:@"error_code"];
            if(error.integerValue == -1){
                waitingButton.selected = FALSE;
                boardedButton.selected = FALSE;
                reachedButton.selected = FALSE;
                UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Not A Valid Current Trip! Please Refresh Trips!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [calert show];
            }
        }
    }
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
    coPassenger =[[NSMutableArray alloc] init];
    NSArray *info_array= [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    for (NSDictionary *info in info_array) {
        for(int i=0;i<[flattenArray count];i++)
        {
            if([info[@"empid"]isEqualToString:flattenArray[i]]){
                NSString *strName =info[@"name"];
                [coPassenger addObject:[NSString stringWithFormat:@"Name: %@\nEmp Id: %@",strName,flattenArray[i]]];
            }
        }
    }
    [self.summaryTable reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(IBAction)sos:(id)sender{
    SOSMainViewController *sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:model];
    [self presentViewController:sosController animated:YES completion:nil];
}
-(IBAction)Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)call:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *phNo = model.driverPhone;
            NSLog(@"%@",phNo);
            NSNumber *callmaskEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"callMaskEnabled"];
            if (callmaskEnabled.boolValue == NO){
                NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
                if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                    if ([phNo isEqualToString:@""] || phNo.length == 0 || phNo == (id)[NSNull null] || [phNo isEqual:nil]){
                        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call Facility Is Not Available!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [calert show];
                    }else{
                        [[UIApplication sharedApplication] openURL:phoneUrl];
                    }
                } else
                {
                    UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call Facility Is Not Available!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [calert show];
                }
                
            }else{
                NSLog(@"number");
                NSString *callMaskNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"callMaskNumber"];
                NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",callMaskNumber]];
                if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                    if ([callMaskNumber isEqualToString:@""] || phNo.length == 0 || phNo == (id)[NSNull null] || [phNo isEqual:nil]){
                        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call Facility Is Not Available!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [calert show];
                    }else{
                        [[UIApplication sharedApplication] openURL:phoneUrl];
                    }
                } else
                {
                    UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call Facility Is Not Available!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [calert show];
                }
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}
-(IBAction)waiting:(id)sender
{

    NSDateFormatter *dateFormatter123 = [[NSDateFormatter alloc]init];
    [dateFormatter123 setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    if ([[NSDate date] compare:[dateFormatter123 dateFromString:model.scheduledTime]] == NSOrderedAscending){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You can send waiting only after boarding time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        UIButton *button1 = (UIButton *)sender;
        button1.tag =601;
        if(button1.selected == FALSE)
        {
            if(![model.empstatus isEqualToString:@"incab"]){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @""
                                      message: @"Are You Waiting For The Cab At The Boarding Point?"
                                      delegate: self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Yes", nil];
                alert.tag =1001;
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"You Have Already Boarded Cab!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                alert.tag =1999;
                [alert show];
            }
        }
    }
}

-(IBAction)boarded:(id)sender
{
    UIButton *button1 = (UIButton *)sender;
    button1.tag =502;
    if(button1.selected == FALSE)
    {
        //        if (model.entryTime){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Did You Board The Cab?"
                              delegate: self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Yes", nil];
        alert.tag =1002;
        [alert show];
        //        }else{
        //            UIAlertView *alert = [[UIAlertView alloc]
        //                                  initWithTitle: @""
        //                                  message: @"Vehicle not arrived at your pick up point"
        //                                  delegate: nil
        //                                  cancelButtonTitle:@"Ok"
        //                                  otherButtonTitles:nil, nil];
        //            alert.tag =1002;
        //            [alert show];
        //        }
    }
}
-(void)mockModel:(NSString *)mockModelData
{
    model = [[TripModel alloc] init];
    model.tripType = @"pickup";
    model.empstatus = mockModelData;
}
-(IBAction)reached:(id)sender
{
    NSString *message;
    UIButton *button2 = (UIButton *)sender;
    button2.tag =503;
    if(button2.selected == FALSE)
    {
        //        if (model.exitTime){
        
        if([model.empstatus isEqualToString:@"incab"]){
            if([model.tripType isEqualToString:@"Drop"])
            {
                message = @"Did You Reach Home Safely?";
            }
            else
            {
                message = @"Did You Reach Office Safely?";
            }
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @""
                                  message:message
                                  delegate: self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Yes",nil];
            alert.tag =1003;
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Please Confirm Boarding Before Reaching"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            //            alert.tag =1999;
            [alert show];
            
        }

    }
}

//  http://72.52.65.142:8083/markconfirmation?mode=app
//{"type":"reached","tripId":"57d1388b1a12954d8fe5a873","employeeId":"57ac12141a129508681310cf"}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2222){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (buttonIndex == 1) {
        if(alertView.tag == 1001)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
            double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
            NSTimeInterval seconds = expireTime / 1000;
            NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
            
            NSDate *date = [NSDate date];
            NSComparisonResult result = [date compare:expireDate];
            
            if(result == NSOrderedDescending || result == NSOrderedSame)
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                    for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
                    }
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                    [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate dismiss_delegate:nil];
                    [self.view removeFromSuperview];
                }else{
                    SessionValidator *validator = [[SessionValidator alloc]init];
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                        NSLog(@"%@",result);
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }
            }
            else if(result == NSOrderedAscending)
            {
                NSLog(@"no refresh");
            }
            
            long double today = [[NSDate date] timeIntervalSince1970];
            NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
            long double mine = [str1 doubleValue]*1000;
            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
            NSString *tripId = model.tripid;
            NSLog(@"%@",tripId);
            NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
            NSLog(@"%@",employeeId);
            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
            NSString *headerString;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
            }else{
                headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
            }
            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
            //            NSDictionary *firstDict = @{@"_id":@{@"$oid":tripId},@"employees._employeeId":employeeId};
            //            NSDictionary *secondDict = @{@"$set":@{@"employees.$.waiting":@{@"time":todayTime,@"mode":@"ios-app"}}};
            //            NSArray *finalArry = [NSArray arrayWithObjects:firstDict,secondDict, nil];
            
            NSDictionary *bodyDict = @{@"type":@"waiting",@"tripId":tripId,@"employeeId":employeeId};
            //            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:columnName];
            //            [requestWraper setAuthString:finalAuthString];
            //            [requestWraper setBodyFromArray:finalArry];
            //            [requestWraper print];
            //            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
            //            [RestClient setDelegate:self];
            //            BOOL isDone = [RestClient execute];
            
            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
            NSString *url;
            if([Port isEqualToString:@"-1"])
            {
                url =[NSString stringWithFormat:@"%@://%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
            }
            else
            {
                url =[NSString stringWithFormat:@"%@://%@:%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
            }
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURL *URL = [NSURL URLWithString:url];
            NSLog(@"%@",URL);
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"POST"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error];
            [request setHTTPBody:jsonData];
            NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
            NSLog(@"%@",finalAuthString);
            NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                } else {
                    NSLog(@"%@ %@", response, responseObject);
                    model.empstatus = @"waiting_cab";
                    [home refresh];
                    boardedButton.enabled = TRUE;
                    reachedButton.enabled = FALSE;
                    UIButton *button3=(UIButton *)[self.view viewWithTag:601];
                    button3.selected =YES;
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                    {
                        NSLog(@"start tracking home");
                        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                        [appDelegate updateLocation];
                    }
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            [dataTask resume];
            
            //            if(isDone){
            //                model.empstatus = @"waiting_cab";
            //                [home refresh];
            //                boardedButton.enabled = TRUE;
            //                reachedButton.enabled = FALSE;
            //                UIButton *button=(UIButton *)[self.view viewWithTag:601];
            //                button.selected =YES;
            //                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
            //                    {
            //                    NSLog(@"start tracking home");
            //                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            //                    [appDelegate updateLocation];
            //                    }
            //            }
        }
        else if(alertView.tag == 1002)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
                    [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
                    double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
                    NSTimeInterval seconds = expireTime / 1000;
                    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                    
                    NSDate *date = [NSDate date];
                    NSComparisonResult result = [date compare:expireDate];
                    
                    if(result == NSOrderedDescending || result == NSOrderedSame)
                    {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                            for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
                            }
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                            [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
                            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
                            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            [appDelegate dismiss_delegate:nil];
                            [self.view removeFromSuperview];
                        }else{
                            SessionValidator *validator = [[SessionValidator alloc]init];
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                                NSLog(@"%@",result);
                                dispatch_semaphore_signal(semaphore);
                            }];
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        }
                    }
                    else if(result == NSOrderedAscending)
                    {
                        NSLog(@"no refresh");
                    }
                    
                    long double today = [[NSDate date] timeIntervalSince1970];
                    NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
                    long double mine = [str1 doubleValue]*1000;
                    NSString *tripId = model.tripid;
                    NSLog(@"%@",tripId);
                    NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                    NSLog(@"%@",employeeId);
                    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
                    NSString *headerString;
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
                    }else{
                        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
                    }
                    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
                    //            NSDictionary *firstDict = @{@"_id":@{@"$oid":tripId},@"employees._employeeId":employeeId};
                    //            NSDictionary *secondDict = @{@"$set":@{@"employees.$.waiting":@{@"time":todayTime,@"mode":@"ios-app"}}};
                    //            NSArray *finalArry = [NSArray arrayWithObjects:firstDict,secondDict, nil];
                    
                    NSDictionary *bodyDict = @{@"type":@"boarded",@"tripId":tripId,@"employeeId":employeeId};
                    //            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:columnName];
                    //            [requestWraper setAuthString:finalAuthString];
                    //            [requestWraper setBodyFromArray:finalArry];
                    //            [requestWraper print];
                    //            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
                    //            [RestClient setDelegate:self];
                    //            BOOL isDone = [RestClient execute];
                    
                    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                    NSString *url;
                    if([Port isEqualToString:@"-1"])
                    {
                        url =[NSString stringWithFormat:@"%@://%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                    }
                    else
                    {
                        url =[NSString stringWithFormat:@"%@://%@:%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
                    }
                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                    
                    NSURL *URL = [NSURL URLWithString:url];
                    NSLog(@"%@",URL);
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
                    [request setHTTPMethod:@"POST"];
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error];
                    [request setHTTPBody:jsonData];
                    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
                    NSLog(@"%@",finalAuthString);
                    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        
                        NSLog(@"%@",responseObject);
                        if (error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                            if ((long)[httpResponse statusCode] == 409){
                                UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You already boarded cab with RFID swipe" delegate:nil cancelButtonTitle:@"Ok! Thanks" otherButtonTitles:nil, nil];
                                [aler show];
                                model.empstatus = @"incab";
                                [home refresh];
                                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                                waitingButton.enabled = FALSE;
                                reachedButton.enabled =TRUE;
                                UIButton *button=(UIButton *)[self.view viewWithTag:502];
                                button.selected =YES;
                                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                                {
                                    NSLog(@"start tracking home");
                                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                    [appDelegate updateLocation];
                                }
                            }
                            
                        } else {
                            NSLog(@"%@ %@", response, responseObject);
                            model.empstatus = @"incab";
                            [home refresh];
                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                            waitingButton.enabled = FALSE;
                            reachedButton.enabled =TRUE;
                            UIButton *button=(UIButton *)[self.view viewWithTag:502];
                            button.selected =YES;
                            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                            {
                                NSLog(@"start tracking home");
                                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                [appDelegate updateLocation];
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            button.hidden = YES;
                            startTime.text = @"--";
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    }];
                    [dataTask resume];
                });
            });
        }
        else if(alertView.tag == 1003)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
                    [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
                    double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
                    NSTimeInterval seconds = expireTime / 1000;
                    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                    
                    NSDate *date = [NSDate date];
                    NSComparisonResult result = [date compare:expireDate];
                    
                    if(result == NSOrderedDescending || result == NSOrderedSame)
                    {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                            for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
                            }
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                            [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
                            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
                            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            [appDelegate dismiss_delegate:nil];
                            [self.view removeFromSuperview];
                        }else{
                            SessionValidator *validator = [[SessionValidator alloc]init];
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                                NSLog(@"%@",result);
                                dispatch_semaphore_signal(semaphore);
                            }];
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        }
                    }
                    else if(result == NSOrderedAscending)
                    {
                        NSLog(@"no refresh");
                    }
                    
                    NSString *tripId = model.tripid;
                    NSLog(@"%@",tripId);
                    NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                    NSLog(@"%@",employeeId);
                    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
                    NSString *headerString;
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
                    }else{
                        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
                    }
                    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
                    
                    NSDictionary *bodyDict = @{@"type":@"reached",@"tripId":tripId,@"employeeId":employeeId};
                    
                    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                    NSString *url;
                    if([Port isEqualToString:@"-1"])
                    {
                        url =[NSString stringWithFormat:@"%@://%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                    }
                    else
                    {
                        url =[NSString stringWithFormat:@"%@://%@:%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
                    }
                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                    
                    NSURL *URL = [NSURL URLWithString:url];
                    NSLog(@"%@",URL);
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
                    [request setHTTPMethod:@"POST"];
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error];
                    [request setHTTPBody:jsonData];
                    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
                    NSLog(@"%@",finalAuthString);
                    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        if (error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                            if ((long)[httpResponse statusCode] == 409){
                                _tripConfirmationsButton.hidden = YES;
                                UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You already reached destination with RFID swipe" delegate:nil cancelButtonTitle:@"Ok! Thanks" otherButtonTitles:nil, nil];
                                [aler show];
                                [home refresh];
                                boardedButton.selected = TRUE;
                                boardedButton.enabled = FALSE;
                                waitingButton.enabled = FALSE;
                                tripModelClass = [[tripIDModel alloc]init];
                                [tripModelClass addIdToMutableArray:model.tripid];
                                
                                NSLog(@"%@",tripModelClass.tripIdArray);
                                [_totalTripIDSarray addObject:tripModelClass.tripIdArray];
                                [[NSUserDefaults standardUserDefaults] setObject:_totalTripIDSarray forKey:@"allTrips"];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                                UIButton *button=(UIButton *)[self.view viewWithTag:503];
                                button.selected =YES;
                                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                [appDelegate stopUpdateLocation];
                            }
                        }
                        else {
                            _tripConfirmationsButton.hidden = YES;
                            NSLog(@"%@",response);
                            [home refresh];
                            boardedButton.selected = TRUE;
                            boardedButton.enabled = FALSE;
                            waitingButton.enabled = FALSE;
                            tripModelClass = [[tripIDModel alloc]init];
                            [tripModelClass addIdToMutableArray:model.tripid];
                            
                            NSLog(@"%@",tripModelClass.tripIdArray);
                            [_totalTripIDSarray addObject:tripModelClass.tripIdArray];
                            [[NSUserDefaults standardUserDefaults] setObject:_totalTripIDSarray forKey:@"allTrips"];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                            UIButton *button=(UIButton *)[self.view viewWithTag:503];
                            button.selected =YES;
                            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            [appDelegate stopUpdateLocation];
                            
                            NSDictionary *info = @{@"tripId":model.tripid};
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                        }
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }];
                    [dataTask resume];
                    
                });
            });
        }else if (alertView.tag == 1004){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
            double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
            NSTimeInterval seconds = expireTime / 1000;
            NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
            
            NSDate *date = [NSDate date];
            NSComparisonResult result = [date compare:expireDate];
            
            if(result == NSOrderedDescending || result == NSOrderedSame)
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                    for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
                    }
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                    [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate dismiss_delegate:nil];
                    [self.view removeFromSuperview];
                }else{
                    SessionValidator *validator = [[SessionValidator alloc]init];
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                        NSLog(@"%@",result);
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }
            }
            else if(result == NSOrderedAscending)
            {
                NSLog(@"no refresh");
            }
            
            NSString *tripId = model.tripid;
            NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
            NSString *headerString;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
            }else{
                headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
            }
            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
            
            NSDictionary *bodyDict = @{@"type":@"noShow",@"tripId":tripId,@"employeeId":employeeId};
            
            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
            NSString *url;
            if([Port isEqualToString:@"-1"])
            {
                url =[NSString stringWithFormat:@"%@://%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
            }
            else
            {
                url =[NSString stringWithFormat:@"%@://%@:%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
            }
            
            NSURL *URL = [NSURL URLWithString:url];
            NSLog(@"%@",URL);
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"POST"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error];
            [request setHTTPBody:jsonData];
            NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
            NSLog(@"%@",finalAuthString);
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response , id jsonObject , NSError *error){
                if (error){
                    NSLog(@"%@",response);
                }else{
                    NSLog(@"%@",jsonObject);
                    NSLog(@"%@",response);
                    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)response;
                    if (httpresponse.statusCode == 200){
                        NSMutableArray *newArray = [[NSMutableArray alloc]init];
                        [newArray addObject:model.tripid];
                        NSArray *oldArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"notAvailTrips"];
                        [newArray addObjectsFromArray:oldArray];
                        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"notAvailTrips"];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are no longer avail for this trip" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        alert.tag = 2222;
                        
                    }else{
                        
                    }
                }
            }];
            [dataTask resume];
            
        }
        if (alertView.tag == 2002){
            if (buttonIndex == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    SomeViewController *some = [[SomeViewController alloc]init];
                    [self presentViewController:some animated:YES completion:nil];
                });
            }
        }
        
    }
    
    else {
        NSLog(@"user pressed Cancel");
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response %@",response);
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary *forDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",forDict);
}
- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(IBAction)refreshForETA:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
        double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
        NSTimeInterval seconds = expireTime / 1000;
        NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        NSDate *date = [NSDate date];
        NSComparisonResult result = [date compare:expireDate];
        
        if(result == NSOrderedDescending || result == NSOrderedSame)
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
                }
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate dismiss_delegate:nil];
                [self.view removeFromSuperview];
            }else{
                SessionValidator *validator = [[SessionValidator alloc]init];
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                    NSLog(@"%@",result);
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
        else if(result == NSOrderedAscending)
        {
            NSLog(@"no refresh");
        }
        
        NSString *idToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
        NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
        NSLog(@"%@",tokenString);
        long double today = [[[NSDate date] dateByAddingTimeInterval:-5*60*60] timeIntervalSince1970];
        long double yesterday = [[[NSDate date] dateByAddingTimeInterval: 48*60*60] timeIntervalSince1970];
        NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
        NSString *str2 = [NSString stringWithFormat:@"%.Lf",yesterday];
        long double mine = [str1 doubleValue]*1000;
        long double mine2 = [str2 doubleValue]*1000;
        NSString *headerString;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
            headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
        }else{
            headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
        }
        NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
        NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
        NSDecimalNumber *beforeDayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine2]];
        NSDictionary *running1 = @{@"runningStatus":@{@"$exists":[NSNumber numberWithBool:false]}};
        NSDictionary *running2 = @{@"runningStatus":@{@"$ne":@"completed"}};
        NSMutableArray *addingArray = [[NSMutableArray alloc]initWithObjects:running1,running2, nil];
        NSDictionary *postDictionary = @{@"$or":addingArray,@"employees._employeeId":idToken,@"startTime":@{@"$gte":todayTime,@"$lte":beforeDayTime}};
        
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        NSString *url;
        if([Port isEqualToString:@"-1"])
        {
            url =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],@"query",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"trips"];
        }
        else
        {
            url =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],@"query",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"trips"];
        }
        NSURL *URL =[NSURL URLWithString:url];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL];
        [request setHTTPMethod:@"POST"];
        NSError *error;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:&error]];
        [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if (data != nil){
            id jsonResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"%@",jsonResult);
            if ([jsonResult isKindOfClass:[NSArray class]]){
                NSArray *array = jsonResult;
                NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                for (NSDictionary *dict in array){
                    if ([model.tripid isEqualToString:[[dict valueForKey:@"_id"] valueForKey:@"$oid"]]){
                        for (NSDictionary *dict2 in [dict valueForKey:@"employees"]){
                            if ([[dict2 valueForKey:@"_employeeId"] isEqualToString:employeeId]){
                                if ([dict2 valueForKey:@"boarded"] || [dict2 valueForKey:@"reached"])
                                {
                                    button.hidden = YES;
                                    startTime.text = @"--";
                                    
                                }else{
                                    button.hidden = NO;
                                    NSString *tripId = model.tripid;
                                    NSLog(@"%@",tripId);
                                    NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                                    NSLog(@"%@",employeeId);
                                    
                                    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                                    NSString *url;
                                    if([Port isEqualToString:@"-1"])
                                    {
                                        url =[NSString stringWithFormat:@"%@://%@/eta?employeeId=%@&tripId=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],employeeId,tripId];
                                        
                                    }
                                    else
                                    {
                                        url =[NSString stringWithFormat:@"%@://%@:%@/eta?employeeId=%@&tripId=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],employeeId,tripId];
                                    }
                                    
                                    NSURL *URL = [NSURL URLWithString:url];
                                    NSLog(@"%@",URL);
                                    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
                                    NSString *headerString;
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                                        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
                                    }else{
                                        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
                                    }
                                    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
                                    NSLog(@"%@",finalAuthString);
                                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                                    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                                    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
                                    [request setHTTPMethod:@"POST"];
                                    
                                    NSDictionary *bodyDict = @{};
                                    NSError *error;
                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error]
                                    ;
                                    
                                    [request setHTTPBody:jsonData];
                                    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                                    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]);
                                    
                                    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        int time;
                                        if ([json isKindOfClass:[NSDictionary class]]){
                                            if ([json valueForKey:@"time"]){
                                                time = [[json valueForKey:@"time"] intValue];
                                                int minutes = (time / 60) % 60;
                                                startTime.text = [NSString stringWithFormat:@"%@ %i%@",@"ETA",minutes,@"mins"];
                                            }else{
                                                startTime.text = @"--";
                                            }
                                        }else{
                                            startTime.text = @"--";
                                        }
                                    });
                                    
                                }
                            }else{
                                
                            }
                        }
                    }else{
                        
                    }
                }
            }else{
                
            }
        }else{
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}
-(void)getSyncTripsFromFCM:(NSArray *)result;
{
    NSLog(@"%@",result);
    NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
    
    for (NSDictionary *dict in result)
    {
        if ([model.tripid isEqualToString:[[dict valueForKey:@"_id"] valueForKey:@"$oid"]]){
            if ([[dict valueForKey:@"tripLabel"] isEqualToString:@"login"]){
                
                NSArray *stops = [dict valueForKey:@"stoppages"];
                for (NSDictionary *tempDict in stops)
                {
                    NSArray *idsArrayForPickup = [tempDict valueForKey:@"_pickup"];
                    
                    if (idsArrayForPickup.count != 0){
                        if ([idsArrayForPickup containsObject:employeeId])
                        {
                            if ([dict valueForKey:@"entryTime"]){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _etaLabel.text = @"ETA";
                                    button.hidden = YES;
                                    startTime.text = @"--";
                                });
                            }else{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _etaLabel.text = @"ETA";
                                    button.hidden = NO;
                                });
                            }
                        }
                    }
                    
                }
                
            }else{
                
            }
            
        }else{
            
        }
    }
}
-(void)tripCompletedNotification:(NSNotification *)sender{
    NSDictionary *myDictionary = (NSDictionary *)sender.object;
    NSLog(@"%@",myDictionary);
    if ([sender.name isEqualToString:@"tripCompleted"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tripFeedbackForm"]){
                SomeViewController *some1 = [[SomeViewController alloc]init];
                [some1 getTripId:[myDictionary valueForKey:@"tripId"]];
                [self presentViewController:some1 animated:YES completion:nil];
            }else{
                
            }
        });
        
    }
    
}
-(void)pushNotification:(NSTimer *)sender{
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"] containsObject:[sender.userInfo valueForKey:@"tripId"]]){
    }else{
        NSArray *userdefaultsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"];
        userdefaultsArray = [NSArray arrayWithObject:[sender.userInfo valueForKey:@"tripId"]];
        [[NSUserDefaults standardUserDefaults] setObject:userdefaultsArray forKey:@"ratingCompletedTrips"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tripCompleted" object:sender.userInfo];
    }
}
-(IBAction)tripConfirmationsButton:(id)sender;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Update your trip status" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    if([model.empstatus isEqualToString:@"reached"]){
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
            _sosMainButton.hidden = YES;
        }else{
            _sosMainButton.hidden = NO;
        }
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"You have already reached destination" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
    }
    else{
        if([model.empstatus isEqualToString:@"incab"])
        {
            [actionSheet addButtonWithTitle:@"I have reached"];
            [actionSheet showInView:self.view];
            
        }
        else if([model.empstatus isEqualToString:@"waiting_cab"])
        {
            [actionSheet addButtonWithTitle:@"I am waiting"];
            [actionSheet addButtonWithTitle:@"I have boarded"];
            [actionSheet addButtonWithTitle:@"I am not avail for this trip"];
            [actionSheet showInView:self.view];
            
        }
        else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"reached"] isEqualToString:@"YES"])
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
                _sosMainButton.hidden = YES;
            }else{
                _sosMainButton.hidden = NO;
            }
            UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"You have already reached destination" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertview show];
        }
        else
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
                [actionSheet addButtonWithTitle:@"I am waiting"];
                [actionSheet addButtonWithTitle:@"I have boarded"];
                [actionSheet addButtonWithTitle:@"I am not avail for this trip"];
                [actionSheet showInView:self.view];
                
            }else{
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
                    _sosMainButton.hidden = YES;
                }else{
                    _sosMainButton.hidden = NO;
                }
                UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"You can give your confirmations when trip is in active state" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertview show];
            }
        }
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 8_3) __TVOS_PROHIBITED;
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I am waiting"]){
        
        UIAlertView *waitingAlert = [[UIAlertView alloc] initWithTitle:@"Are You Waiting For The Cab At The Boarding Point?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [waitingAlert show];
        waitingAlert.tag = 1001;
        
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I have boarded"]){
        
        UIAlertView *boardingAlert = [[UIAlertView alloc] initWithTitle:@"Did You Board The Cab?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [boardingAlert show];
        boardingAlert.tag = 1002;
        
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I have reached"]){
        
        NSString *message;
        
        if([model.tripType isEqualToString:@"Drop"])
        {
            message = @"Did You Reach Home Safely?";
        }
        else
        {
            message = @"Did You Reach Office Safely?";
        }
        
        UIAlertView *reachingAlert = [[UIAlertView alloc] initWithTitle:message message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [reachingAlert show];
        reachingAlert.tag = 1003;
        
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I am not avail for this trip"]){
        
        UIAlertView *availAlert = [[UIAlertView alloc] initWithTitle:@"Really you are not avail for this trip?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [availAlert show];
        availAlert.tag = 1004;
        
    }
}

@end


