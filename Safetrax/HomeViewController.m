//
//  HomeViewController.m
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "HomeViewController.h"
#import "SomeViewController.h"
#import "MFSideMenu.h"
#import "SOSMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GCMRequest.h"
#import "RestClientTask.h"
#import "EmpSchedule.h"
#import "TripCollection.h"
#import "TripModel.h"
#import "AppDelegate.h"
#import "validateLogin.h"
#import "SessionValidator.h"
#if Parent
//import feedback class
#else
#import "CheckFeedbackViewController.h"
#import "FeedbackViewController.h"
#endif
#import <QuartzCore/QuartzCore.h>
#import <FIRInstanceID.h>
#import "MBProgressHUD.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
EmpSchedule *schedule;
BOOL refreshInProgress = FALSE;
NSMutableArray *tripList;
BOOL no_trips = FALSE;
@interface HomeViewController ()
{
    NSDate *cuurentDate;
    UITableViewCell *Cell;
    NSMutableArray *localNotifications;
    UIActivityIndicatorView *activityIndicator;
    MBProgressHUD *hud;
    NSMutableArray *startTimesArray;
}
@end
@implementation HomeViewController
@synthesize tripTable,mainSegment,loginTime,logoutTime,scheduleImage,currentDate,loginLable,logoutLabel,noScheduleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
    startTimesArray = [[NSMutableArray alloc]init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"fcmtokenpushed"]){
        
    }else{
        [self pushDeviceTokenWithFCM];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"login"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    localNotifications = [[NSMutableArray alloc]init];
    [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
    double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
    NSTimeInterval seconds = expireTime / 1000;
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSLog(@"%@",[dateFormat stringFromDate:expireDate]);
    
    NSDate *date = [NSDate date];
    NSComparisonResult result = [date compare:expireDate];
    if(result == NSOrderedDescending)
    {
        self.view.backgroundColor = [UIColor clearColor];
        [self.view removeFromSuperview];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate dismiss_delegate:nil];
        [self.view removeFromSuperview];
    }
    else if(result == NSOrderedAscending)
    {
    }
    else
    {
        //        SessionValidator *validator = [[SessionValidator alloc]init];
        //        [validator validateAccessToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFeedback:) name:@"addFeedback" object:nil];
    // CheckFeedbackViewController *CheckFeedback = [[CheckFeedbackViewController alloc] init];
    //[CheckFeedback setDelegate:self];
    //[CheckFeedback downloadConfig];
    [TripCollection initArray];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:134.0/255.0 alpha:1];
    [refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tripTable addSubview:refreshControl];
    self.view.frame = [[UIScreen mainScreen] bounds];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"incab"] isEqualToString:@"YES"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
    {
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate updateLocation];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
    _responseData = [[NSMutableData alloc] init];
    validateLogin *validate = [[validateLogin alloc] init];
    [validate setDelegate:self];
    self.tripTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tripTable.delegate = self;
    self.tripTable.dataSource =self;
    self.tripTable.hidden = YES;
    [super viewDidLoad];
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    //constant = [[Constants alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    [dateFormatter setDateFormat:@"EEEE, dd MMM, yyyy"];
    NSDate *currDate = [NSDate date];
    NSLog(@"date-- %@",currDate);
    currentDate.text  = [dateFormatter stringFromDate:currDate];
    [currentDate setHidden:NO];
    [logoutTime setHidden:NO];
    [loginTime setHidden:NO];
    [scheduleImage setHidden:NO];
    [noScheduleView setHidden:YES];
    NSString *showFeedback = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowFeedbackForm"];
    if([showFeedback isEqualToString:@"YES"])
    {
        NSLog(@"yes for feedback");
        [self performSelector:@selector(ShowFeedback) withObject:nil afterDelay:1.0];
        
    }
}
- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    NSString *showFeedback = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowFeedbackForm"];
    if([showFeedback isEqualToString:@"YES"])
    {
        NSLog(@"yes for feedback");
        [self performSelector:@selector(ShowFeedback) withObject:nil afterDelay:1.0];
        
    }
    
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
}
-(void)addFeedback:(NSNotification *) notification
{
    NSLog(@"addfeedback");
    [self ShowFeedback];
}
-(void)refresh
{
    NSLog(@"refresh");
    if(!refreshInProgress){
        [TripCollection initArray];
        refreshInProgress = TRUE;
        [self didFinishvalidation];
        [self tripsForRating];
    }
    [refreshControl endRefreshing];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)ShowFeedback
{
    
    
#if Parent
    //parent app actions
#else
    NSString *feedbackRequired = [[NSUserDefaults standardUserDefaults] objectForKey:@"feedbackRequired"];
    NSLog(@"showfeedback %d",[feedbackRequired boolValue]);
    if([feedbackRequired boolValue] ==1){
        FeedbackViewController *feedback = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
        [self presentViewController:feedback animated:YES completion:nil];
    }
#endif
}
-(void)didFinishvalidation
{
    NSString *idToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
    _responseData = nil;
    _responseData = [[NSMutableData alloc] init];
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    NSLog(@"%@",tokenString);
    long double today = [[[NSDate date] dateByAddingTimeInterval:-5*60*60] timeIntervalSince1970];
    long double yesterday = [[[NSDate date] dateByAddingTimeInterval: 48*60*60] timeIntervalSince1970];
    NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
    NSString *str2 = [NSString stringWithFormat:@"%.Lf",yesterday];
    long double mine = [str1 doubleValue]*1000;
    long double mine2 = [str2 doubleValue]*1000;
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
    NSDecimalNumber *beforeDayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine2]];
    BOOL falsef = false;
    NSDictionary *running1 = @{@"runningStatus":@{@"$exists":[NSNumber numberWithBool:false]}};
    NSDictionary *running2 = @{@"runningStatus":@{@"$ne":@"completed"}};
    NSMutableArray *addingArray = [[NSMutableArray alloc]initWithObjects:running1,running2, nil];
    NSDictionary *postDictionary = @{@"$or":addingArray,@"employees._employeeId":idToken,@"startTime":@{@"$gte":todayTime,@"$lte":beforeDayTime}};
    NSLog(@"%@",postDictionary);
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"query" withMethod:@"POST" andColumnName:@"trips"];
    [requestWraper setBody:postDictionary];
    [requestWraper setAuthString:finalAuthString];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    _responseData = [[NSMutableData alloc] init];
    [RestClient execute];
}
#pragma mark Menu Event
- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[notification userInfo][@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose){
        infoView.dynamic = YES;
    }
}
-(void)viewWillAppear:(BOOL)animated {
    //    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    activityIndicator.transform = CGAffineTransformMakeScale(3.5, 3.5);
    //    activityIndicator.color = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f];
    //    activityIndicator.center = self.view.center;
    //
    //    [self.view addSubview:activityIndicator];
    //    [activityIndicator startAnimating];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tripsForRating];
        });
    });
    
    NSString *showFeedback = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowFeedbackForm"];
    if([showFeedback isEqualToString:@"YES"])
    {
        NSLog(@"yes for feedback");
        [self performSelector:@selector(ShowFeedback) withObject:nil afterDelay:1.0];
        
    }
    if([mainSegment selectedSegmentIndex] == 0){
        schedule =[[EmpSchedule alloc] init:self];
    }
    if([mainSegment selectedSegmentIndex] == 1)
    {
        NSLog(@"viewwillload");
        [self.tripTable reloadData];
        [self refresh];
    }
    [super viewWillAppear:NO];
}
#pragma mark Sub States
-(void)attendance
{
    //  [infoView setFrame:CGRectMake(0, [constant adjust:(425)], 320, 145)];
    attending = [[UIButton alloc]initWithFrame:CGRectMake(80, 400, 44, 44)];
    [attending.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
    attending.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [attending setTitle:@"ATTENDING" forState:UIControlStateNormal];
    [attending addTarget:self action:@selector(attending:) forControlEvents:UIControlEventTouchDown];
    [attending setImage:[UIImage imageNamed:@"_0004_attending-inactive.png"] forState:UIControlStateNormal];
    attendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 450, 90, 20)];
    attendingLabel.backgroundColor = [UIColor clearColor];
    attendingLabel.textAlignment = NSTextAlignmentLeft;
    attendingLabel.textColor = [UIColor blackColor];
    attendingLabel.text = @"Attending";
    attendingLabel.font=[attendingLabel.font fontWithSize:16];
    //    [self.view addSubview:attendingLabel];
    attending.tag = 234;
    notAttending = [[UIButton alloc]initWithFrame:CGRectMake(200, 400, 44, 44)];
    [notAttending.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
    notAttending.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [notAttending setTitle:@"NOT ATTENDING" forState:UIControlStateNormal];
    [notAttending setImage:[UIImage imageNamed:@"_0003_not-attending-inactive.png"] forState:UIControlStateNormal];
    [notAttending addTarget:self action:@selector(notAttending:) forControlEvents:UIControlEventTouchDown];
    notAttending.tag = 235;
    notAttendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 450, 120, 20)];
    notAttendingLabel.backgroundColor = [UIColor clearColor];
    notAttendingLabel.textAlignment = NSTextAlignmentLeft;
    notAttendingLabel.textColor = [UIColor blackColor];
    notAttendingLabel.font=[notAttendingLabel.font fontWithSize:16];
    notAttendingLabel.text = @" Not Attending";
    //    [self.view addSubview:notAttendingLabel];
    notAttendingLabel.tag = 435;
    attendingLabel.tag = 434;
    topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, 30)];
    [topLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    [topLabel setTextAlignment:NSTextAlignmentCenter];
    [topLabel setText:@"Please Confirm Your Attendance"];
    topLabel.tag = 237;
    NSNumber *boolSchedule = [[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleVisibility"];
    NSLog(@"%@",boolSchedule);
    if (boolSchedule.boolValue == YES){
        [self.view addSubview:attendingLabel];
        [self.view addSubview:notAttendingLabel];
        [self.view addSubview:topLabel];
        [self.view addSubview:notAttending];
        [self.view addSubview:attending];
        
    }else{
        
    }
    //    [self.view addSubview:topLabel];
    //    [self.view addSubview:notAttending];
    //    [self.view addSubview:attending];
}
#pragma mark Clear Screen
-(void)cleanInfoView {
    for (UIView *view in self.view.subviews) {
        if(!([view isKindOfClass:[UINavigationBar class]]||[view isKindOfClass:[MKMapView class]]||[view isKindOfClass:[FXBlurView class]])){
            [view removeFromSuperview];
        }
    }
}
#pragma mark IBActions
- (IBAction)mainSegmentedTypeChanged:(id)sender
{
    validateLogin *validate = [[validateLogin alloc] init];
    [validate setDelegate:self];
    switch ([sender selectedSegmentIndex]) {
        case 0:
            schedule = nil;
            [tripTable setHidden:YES];
            [[self.view viewWithTag:234] setHidden:NO];
            [[self.view viewWithTag:235] setHidden:NO];
            [[self.view viewWithTag:236] setHidden:NO];
            [[self.view viewWithTag:237] setHidden:NO];
            [[self.view viewWithTag:435] setHidden:NO];
            [[self.view viewWithTag:434] setHidden:NO];
            [[self.view viewWithTag:878] setHidden:NO];
            [[self.view viewWithTag:238] removeFromSuperview];
            [[self.view viewWithTag:223388] removeFromSuperview];
            
            schedule =[[EmpSchedule alloc] init:self];
            [currentDate setHidden:NO];
            [logoutTime setHidden:NO];
            [loginTime setHidden:NO];
            [scheduleImage setHidden:NO];
            loginLable.hidden = NO;
            logoutLabel.hidden = NO;
            /*  if(![[schedule getLogin] isEqualToString:@"OFF"]){
             
             }
             else
             {
             noScheduleView.hidden = NO;
             loginLable.hidden = YES;
             logoutLabel.hidden = YES;
             }*/
            [activityIndicator removeFromSuperview];
            break;
        case 1:
        {
            [self.view addSubview:activityIndicator];
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[self.view viewWithTag:234] setHidden:YES];
            [[self.view viewWithTag:235] setHidden:YES];
            [[self.view viewWithTag:435] setHidden:YES];
            [[self.view viewWithTag:878] setHidden:YES];
            [[self.view viewWithTag:434] setHidden:YES];
            [[self.view viewWithTag:236] setHidden:YES];
            [[self.view viewWithTag:237] setHidden:YES];
            [currentDate setHidden:YES];
            [logoutTime setHidden:YES];
            [loginTime setHidden:YES];
            [scheduleImage setHidden:YES];
            [logoutLabel setHidden:YES];
            [loginLable setHidden:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refresh];
                });
            });
            [tripTable setHidden:NO];
            [tripTable reloadData];
        }
            break;
        default:
            break;
    }
}
-(void)startTracking:(NSString *)scheduleDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    NSLog(@"secondselapsed %f",secondsBetween);
    if(secondsBetween < 1800){
        if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
        {
            NSLog(@"start tracking");
            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate updateLocation];
        }
    }
}
-(IBAction)openMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    infoView.dynamic = NO;
}
-(IBAction)attending:(id)sender
{
    attendingAlert = [[UIAlertView alloc]initWithTitle:@"Attending" message:@"Confirm Attendance?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [attendingAlert setTag:1];
    [attendingAlert show];
}
-(IBAction)notAttending:(id)sender
{
    attendingAlert = [[UIAlertView alloc]initWithTitle:@"Not Attending" message:@"Confirm Absence?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [attendingAlert setTag:2];
    [attendingAlert show];
}
-(IBAction)call:(id)sender{
    [self reachedDestination];
}
-(IBAction)sos:(id)sender{
    SOSMainViewController *sosController;
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }
    [self presentViewController:sosController animated:YES completion:nil];
    
    //    NSString *theMessage = @"Trip at some time and travels through some place to another place";
    //    NSArray *items = @[theMessage];
    //
    //    // build an activity view controller
    //    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    //
    //    // and present it
    //    [self presentActivityController:controller];
}
//- (void)presentActivityController:(UIActivityViewController *)controller {
//
//    controller.modalPresentationStyle = UIModalPresentationPopover;
//    [self presentViewController:controller animated:YES completion:nil];
//
//    UIPopoverPresentationController *popController = [controller popoverPresentationController];
//    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
//
//    // access the completion handler
//    controller.completionWithItemsHandler = ^(NSString *activityType,
//                                              BOOL completed,
//                                              NSArray *returnedItems,
//                                              NSError *error){
//        // react to the completion
//        if (completed) {
//
//            // user shared an item
//            NSLog(@"We used activity type%@", activityType);
//
//        } else {
//
//            // user cancelled
//            NSLog(@"We didn't want to share anything after all.");
//        }
//
//        if (error) {
//            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
//        }
//    };
//}
#pragma mark Map Delegate
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}
-(void)notifyAttendance:(BOOL)empAttending
{
    //    NSString *userName = [[NSUserDefaults standardUserDefaults]
    //                          stringForKey:@"username"];
    //    NSString *passwords = [[NSUserDefaults standardUserDefaults]
    //                           stringForKey:@"password"];
    //    NSString *userid = [[NSUserDefaults standardUserDefaults]
    //                        stringForKey:@"empid"];
    //    NSString *messageType;
    //    NSString *status;
    //    if(empAttending){
    //        messageType = @"confirmed_attendance";
    //        status = @"Confirmed to Attend from App";
    //    }
    //    else
    //    {
    //        messageType = @"confirmed_absence";
    //        status = @"Confirmed not to Attend from App";
    //    }
    //    NSString *empName = [[NSUserDefaults standardUserDefaults]
    //                         stringForKey:@"name"];
    //    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    //    [dateformate setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    //    NSString *date_String=[dateformate stringFromDate:[NSDate date]];
    //    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    //    NSString *findParam =[NSString stringWithFormat:@"{\"employeeID\":\"%@\",\"messageType\":\"%@\"}",userid,messageType];
    //    NSString *postParam =[NSString stringWithFormat:@"{\"employeeCurrentLocation\":[0,0],\"employeeID\":\"%@\",\"empname\":\"%@\",\"time\":\"%@\",\"status\":\"%@\",\"from\":\"app\",\"messageType\":\"%@\",\"scheduleDate\":\"%@\",\"geoEncodedValue\":\"\",}",userid,empName,date_String,status,messageType,[schedule getScheduleDate]];
    //    NSError *error_config;
    //    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    //    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    //    NSString *str= [NSString stringWithFormat:@"%@\n%@\n%@", newStr2,findParam,postParam];
    //    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQueryUpsert:@"write" withMethod:@"POST" andColumnName:@"notifications"];
    //    [requestWraper setPostParamFromString:str];
    //    [requestWraper print];
    //    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    //    [RestClient execute];
}
#pragma Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 1){
        if(buttonIndex == 1){
            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
            NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
            long double mine = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scheduleDate"];
            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
            NSNumber *intNumber = [NSNumber numberWithInt:1];
            NSDictionary *firstDict = @{@"_employeeId":[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"],@"date":todayTime};
            NSDictionary *secondDict = @{@"$set":@{@"isAttending":intNumber}};
            NSArray *finalArray = [[NSArray alloc]initWithObjects:firstDict,secondDict, nil];
            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:@"employees.schedules"];
            [requestWraper setAuthString:finalAuthString];
            [requestWraper setBodyFromArray:finalArray];
            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
            [RestClient execute];
            [self confirmAttendance:1];
            [[self.view viewWithTag:234] removeFromSuperview];
            [[self.view viewWithTag:235] removeFromSuperview];
            [[self.view viewWithTag:236] removeFromSuperview];
            [[self.view viewWithTag:435] removeFromSuperview];
            [[self.view viewWithTag:434] removeFromSuperview];
            [[self.view viewWithTag:237] removeFromSuperview];
        }
    }
    else if (alertView.tag == 2002){
        if (buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                SomeViewController *some = [[SomeViewController alloc]init];
                [self presentViewController:some animated:YES completion:nil];
            });
        }
    }
    else{
        if(buttonIndex == 1){
            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
            NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
            long double mine = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scheduleDate"];
            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
            NSNumber *intNumber = [NSNumber numberWithInt:-1];
            NSDictionary *firstDict = @{@"_employeeId":[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"],@"date":todayTime};
            NSDictionary *secondDict = @{@"$set":@{@"isAttending":intNumber}};
            NSArray *finalArray = [[NSArray alloc]initWithObjects:firstDict,secondDict, nil];
            NSLog(@"%@",finalArray);
            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:@"employees.schedules"];
            [requestWraper setAuthString:finalAuthString];
            [requestWraper setBodyFromArray:finalArray];
            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
            [RestClient execute];
            [self confirmAttendance:-1];
            [[self.view viewWithTag:234] removeFromSuperview];
            [[self.view viewWithTag:235] removeFromSuperview];
            [[self.view viewWithTag:435] removeFromSuperview];
            [[self.view viewWithTag:434] removeFromSuperview];
            [[self.view viewWithTag:236] removeFromSuperview];
            [[self.view viewWithTag:237] removeFromSuperview];
        }
    }
}
//protocol conformation for RestCallBack
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
}
-(void)onFailure
{
    refreshInProgress = FALSE;
    NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
    refreshInProgress = FALSE;
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    NSString* newStr = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"trip %@",newStr);
    NSMutableDictionary *historyDictionary =[[NSMutableDictionary alloc] init];
    if([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"historyData"]){
        historyDictionary =[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"historyData"] mutableCopy];
    }
    id obj = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    if([obj isKindOfClass:[NSDictionary class]]){
        if([obj objectForKey:@"error"]){
            NSLog(@"error at finding trips");
            no_trips = TRUE;
            unique = nil;
            tripsSection1 =nil;
            tripsSection2 =nil;
            [tripTable reloadData];
        }
    }
    else
    {
        NSError *error;
        NSArray *result = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
        for (NSDictionary *dict in result){
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([[dict valueForKey:@"startTime"]doubleValue] / 1000.0)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
            NSString *string = [dateFormatter stringFromDate:date];
            [startTimesArray addObject:string];
        }
        [self addTrip];
    }
    refreshInProgress = FALSE;
    //    [activityIndicator stopAnimating];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [activityIndicator removeFromSuperview];
}
-(void)addTrip
{
    NSLog(@"addtrip");
    NSLog(@"%@",[[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding]);
    no_trips = FALSE;
    TripCollection *tripcollection  = [TripCollection buildFromdata:_responseData];
    //    [tripcollection saveTripArray];
    tripDrop =[tripcollection getDrop];
    tripPickup =[tripcollection getPickup];
    //    [tripcollection getTripStartDate];
    [tripcollection sortTrip];
    timesArrayForNotification = [[NSMutableArray alloc]init];
    timesArrayForNotification = [tripcollection getTripBufferDates];
    
    tripList =[[tripcollection getTripList] mutableCopy];
    NSMutableArray * values = [[NSMutableArray alloc]initWithArray:[tripPickup allKeys]];
    [values addObjectsFromArray:[tripDrop allKeys]];
    unique = [NSMutableArray array];
    NSLog(@"%@",unique);
    for (id obj in values) {
        if (![unique containsObject:obj]) {
            [unique addObject:obj];
        }
    }
    NSLog(@"%@",unique);
    unique = [unique sortedArrayUsingSelector: @selector(compare:)];
    NSLog(@"%@",unique);
    tripsSection1 =[[NSMutableArray alloc]init];
    tripsSection2 =[[NSMutableArray alloc]init];
    NSString *pickupValue;
    NSString *dropValue ;
    NSString *key;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *dateFromString = [[NSDate alloc] init];
    NSDate *lastDate = [[NSDate alloc] init];
    NSLog(@"%@",[unique lastObject]);
    NSString *lastDateString = [unique lastObject];
    
    lastDate = [dateFormatter dateFromString:lastDateString];
    if([unique count] >1){
        BOOL shouldRemoveOldTrips =   [self getTripValidated:[dateFormatter stringFromDate:lastDate]];
        if(shouldRemoveOldTrips)
        {
            unique = [NSMutableArray arrayWithArray:unique];
            [unique removeObjectsInRange:NSMakeRange(0, unique.count-1)];
            [tripList removeObjectsInRange:NSMakeRange(0, tripList.count-1)];
            NSLog(@"should remove");
        }
    }
    if([unique count] >0){
        NSLog(@"%@",[unique objectAtIndex:0]);
        key =[unique objectAtIndex:0];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        pickupValue =[tripPickup objectForKey:key];
        dropValue =[tripDrop objectForKey:key];
        NSLog(@"pickup %@-key--%@",dropValue,key);
        if(pickupValue)
            [tripsSection1 addObject:pickupValue];
        if(dropValue)
            [tripsSection1 addObject:dropValue];
    }
    if([unique count] >1){
        key =[unique objectAtIndex:1];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        NSString *date = [key substringWithRange:NSMakeRange(0, 10)];
        pickupValue =[tripPickup objectForKey:key];
        dropValue =[tripDrop objectForKey:key];
        if([date isEqualToString:[[unique objectAtIndex:0] substringWithRange:NSMakeRange(0, 10)]])
        {
            if(pickupValue)
                [tripsSection1 addObject:pickupValue];
            if(dropValue)
                [tripsSection1 addObject:dropValue];
        }
        else
        {
            if(pickupValue)
                [tripsSection2 addObject:pickupValue];
            if(dropValue)
                [tripsSection2 addObject:dropValue];
        }
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([mainSegment selectedSegmentIndex] == 1)
    {
        [tripTable reloadData];
        
    }
    if([unique count] > 0){
        NSLog(@"trip mode %@--unique %@--",tripList,unique);
        NSString *tripTime =[unique objectAtIndex:0];
        [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        //        dateFromString = [dateFormatter dateFromString:tripTime];
        for (int i=0;i<timesArrayForNotification.count;i++){
            dateFromString = [dateFormatter dateFromString:[timesArrayForNotification objectAtIndex:i]];
            [self dateDifference:[dateFormatter stringFromDate:dateFromString]];
        }
        //         [self ScheduleTripEndNotification:]
        [self startTracking:[dateFormatter stringFromDate:dateFromString]];
    }
}
-(BOOL)getTripValidated:(NSString *)scheduleDate
{
    NSLog(@"last date-->%@",scheduleDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:30*60];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    NSLog(@"datefrom %@",dateFromString);
    if(secondsBetween > 0)
    {
        NSLog(@"greater");
        return NO;
    }
    else
    {
        NSLog(@"lesser");
        return YES;
        [tripTable reloadData];
    }
}
-(void)ScheduleTripEndNotification:(NSString *)scheduleDate withTripID:(NSString *)tripID
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [tripDate dateByAddingTimeInterval:30*60];
    for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if ([[lNotification.userInfo valueForKey:@"LastTripId"] isEqualToString:tripID])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:lNotification];
        }
    }
    
    UILocalNotification* n1 = [[UILocalNotification alloc] init];
    NSLog(@"firedate %@",date);
    //n1.timeZone = [NSTimeZone defaultTimeZone];
    n1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    n1.fireDate = date;
    n1.alertBody = [NSString stringWithFormat: @"Please Rate your Latest Trip"];
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Feedback", @"isFeedbackNotification", tripID, @"LastTripId", nil];
    n1.userInfo = userDict;
    n1.soundName = @"default";
    n1.applicationIconBadgeNumber = 1;
    NSString *feedbackRequired = [[NSUserDefaults standardUserDefaults] objectForKey:@"feedbackRequired"];
    if([feedbackRequired boolValue] ==1){
        //        [[UIApplication sharedApplication] scheduleLocalNotification: n1];
    }
}
-(void)dateDifference:(NSString *)scheduleDate
{
    //    NSLog(@"%@",scheduleDate);
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    //    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    //    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    //    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    //
    //    NSLog(@"%@",tripDate);
    //    NSDate *bufferDate = [NSDate dateWithTimeIntervalSinceNow:-(30*60)];
    //    NSLog(@"%@",bufferDate);
    //
    //
    ////    NSDate *date = [NSDate date];
    ////    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    ////    NSTimeZone *zone = [NSTimeZone localTimeZone];
    ////    [formatter setTimeZone:zone];
    ////    [formatter setDateFormat:@"YYYY/MM/dd--HH:mm:ss"];
    ////    NSDate *dateFromString = [[NSDate alloc] init];
    ////    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    ////    NSLog(@"seconds %@--%@--%@",tripDate,date,dateFromString);
    ////    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    ////    float difference = secondsBetween - 1800;
    //
    //        UILocalNotification* n1 = [[UILocalNotification alloc] init];
    //        n1.fireDate = bufferDate;
    //        n1.alertBody = [NSString stringWithFormat: @"Trip At %@",scheduleDate];
    //        n1.soundName = @"default";
    //        [[UIApplication sharedApplication] scheduleLocalNotification: n1];
    //        [localNotifications addObject:n1];
    //    NSLog(@"%@",localNotifications);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSLog(@"seconds %@--%@--%@",tripDate,date,dateFromString);
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    float difference = secondsBetween - 1800;
    if(difference > 0)
    {
        //        UILocalNotification* n1 = [[UILocalNotification alloc] init];
        //        n1.fireDate = [NSDate dateWithTimeIntervalSinceNow: difference];
        //        n1.alertBody = [NSString stringWithFormat: @"Trip At %@",scheduleDate];
        //        n1.soundName = @"default";
        //        [[UIApplication sharedApplication] scheduleLocalNotification: n1];
    }
    //
    //
}
-(void)empAttendance
{
    NSMutableString *mutableString = @"";
    if(![[schedule getLogin] isEqualToString:@"OFF"] && [schedule getLogin] != NULL){
        mutableString = [NSMutableString stringWithString:[schedule getLogin]];
        [mutableString insertString:@":" atIndex:2];
        loginTime.text =mutableString;
    }
    else{
        loginTime.text = @"OFF";
    }
    
    NSMutableString *logoutString;
    if(![[schedule getLogout] isEqualToString:@"OFF"] && [schedule getLogin] != NULL){
        logoutString = [NSMutableString stringWithString:[schedule getLogout]];
        [logoutString insertString:@":" atIndex:2];
        logoutTime.text =logoutString;
    }else{
        logoutTime.text = @"OFF";
    }
    //    mutableString = [NSMutableString stringWithString:[schedule getLogout]];
    //    if(![[schedule getLogout] isEqualToString:@"OFF"]){
    //        [mutableString insertString:@":" atIndex:2];
    //        logoutTime.text = mutableString;
    //    }
    //    else
    //        logoutTime.text = @"OFF";
    
    NSLog(@"schedule--> %ld",(long)[schedule isAttending]);
    //noScheduleView.hidden = YES;
    if(!([logoutTime.text isEqualToString:@"OFF"] && [loginTime.text isEqualToString:@"OFF"])){
        if([schedule isAttending] == 0 ) {
            [[self.view viewWithTag:234] removeFromSuperview];
            [[self.view viewWithTag:235] removeFromSuperview];
            [[self.view viewWithTag:434] removeFromSuperview];
            [[self.view viewWithTag:435] removeFromSuperview];
            [[self.view viewWithTag:237] removeFromSuperview];
            [self attendance];
        }
        else
        {
            [[self.view viewWithTag:878] removeFromSuperview];
            [self confirmAttendance:[schedule isAttending]];
        }
    }
    else
    {
        //        noScheduleView.hidden = NO;
        [[self.view viewWithTag:234] removeFromSuperview];
        [[self.view viewWithTag:235] removeFromSuperview];
        [[self.view viewWithTag:434] removeFromSuperview];
        [[self.view viewWithTag:435] removeFromSuperview];
        [[self.view viewWithTag:237] removeFromSuperview];
        [[self.view viewWithTag:878] removeFromSuperview];
    }
    //    [activityIndicator stopAnimating];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [activityIndicator removeFromSuperview];
    
}
-(void)confirmAttendance:(NSInteger)isAttending
{
    attendanceConfirmed = nil;
    attendanceConfirmed = [[UILabel alloc] initWithFrame:CGRectMake(70, 370, 220, 20)];
    attendanceConfirmed.backgroundColor = [UIColor clearColor];
    attendanceConfirmed.textAlignment = NSTextAlignmentLeft;
    attendanceConfirmed.textColor = [UIColor blackColor];
    if(isAttending == 1){
        attendanceConfirmed.textColor = [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:134.0/255.0 alpha:1];
        attendanceConfirmed.text = @"Confirmation: Attending";
    }
    else if(isAttending == -1){
        attendanceConfirmed.textColor = [UIColor redColor];
        attendanceConfirmed.text = @"Confirmation: Not Attending";
    }
    attendanceConfirmed.font=[attendanceConfirmed.font fontWithSize:16];
    attendanceConfirmed.tag = 878;
    [self.view addSubview:attendanceConfirmed];
}
#pragma mark Tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(no_trips == TRUE && [mainSegment selectedSegmentIndex] == 1)
    {
        if([self.view viewWithTag:238])
        {
            [[self.view viewWithTag:238] removeFromSuperview];
        }
        UIImageView *no_trips = [[UIImageView alloc] initWithFrame:CGRectMake(((self.view.frame.size.width/2)-25), 200, 100, 107)];
        no_trips.image = [UIImage imageNamed:@"_0008_no-trip-illustration.png"];
        no_trips.tag = 238;
        [self.view addSubview:no_trips];
        
        if([self.view viewWithTag:223388])
        {
            [[self.view viewWithTag:223388] removeFromSuperview];
        }
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(((self.view.frame.size.width/2)-84), 320, 168, 100)];
        label1.text = @"No Trips Configured";
        label1.tag = 223388;
        [self.view addSubview:label1];
    }
    else if(no_trips == FALSE)
    {
        [[self.view viewWithTag:238] removeFromSuperview];
        [[self.view viewWithTag:223388] removeFromSuperview];
        
    }
    if([tripsSection2 count] >0)
        return 2;
    else if([tripsSection1 count] >0)
        return 1;
    else
    {
        if( [mainSegment selectedSegmentIndex] == 1)
        {
            if([self.view viewWithTag:238])
            {
                [[self.view viewWithTag:238] removeFromSuperview];
            }
            UIImageView *no_trips = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 100, 107)];
            no_trips.image = [UIImage imageNamed:@"_0008_no-trip-illustration.png"];
            no_trips.tag = 238;
            [self.view addSubview:no_trips];
            
            if([self.view viewWithTag:223388])
            {
                [[self.view viewWithTag:223388] removeFromSuperview];
            }
            
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(((self.view.frame.size.width/2)-84), 320, 168, 100)];
            label1.text = @"No Trips Configured";
            label1.tag = 223388;
            [self.view addSubview:label1];
        }
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return [tripsSection1 count];
    else if(section == 1)
        return [tripsSection2 count];
    else
        return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString;
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    dateString = [unique objectAtIndex:section];
    [dateFormatters setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
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
    Cell = [self.tripTable dequeueReusableCellWithIdentifier:@"cell"];
    NSString *dateString ;
    NSString *endTime;
    NSString *tripId ;
    if(Cell == nil)
    {
        Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *StringArray =[[NSArray alloc] init];
    if (indexPath.section==0) {
        StringArray = [[tripsSection1 objectAtIndex:indexPath.row]  componentsSeparatedByString:@"&&"];
        Cell.textLabel.text = StringArray[0];
        NSLog(@"string array %@",StringArray);
        dateString = StringArray[2];
        endTime = StringArray[1];
        NSLog(@"%@",dateString);
    }
    else
    {
        
        StringArray = [[tripsSection2 objectAtIndex:indexPath.row]  componentsSeparatedByString:@"&&"];
        Cell.textLabel.text = StringArray[0];
        dateString = StringArray[2];
        endTime = StringArray[1];
        
    }
    tripId = StringArray[3];
    
    [self ScheduleTripEndNotification:StringArray[1] withTripID:tripId];
    dateString =  [dateString substringFromIndex: [dateString length] - 2];
    NSLog(@"string date is %@",[StringArray objectAtIndex:2]);
    //    int i = [self CheckActiveTrips:[StringArray objectAtIndex:2] with:1];
    int i = [self CheckActiveTrips:[startTimesArray objectAtIndex:indexPath.row] with:1];
    label = [[UILabel alloc] init];
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 12.0 ];
    label.font = myFont;
    Cell.accessoryView = nil;
    if(i == 1)
    {
        NSLog(@"set active");
        label.text = @"  Active";
        
        label.layer.borderColor = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f].CGColor;
        [label setTextAlignment:NSTextAlignmentCenter];
        label.layer.borderWidth = 3.0;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 8.0;
        label.backgroundColor = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f];
        Cell.accessoryView = label;
        Cell.accessoryView.tag = 1;
    }
    //    i = [self CheckActiveTrips:endTime:2];
    i = [self CheckActiveTrips:endTime with:2];
    if(i == 2)
    {
        //ActiveTrip = 0;
        NSLog(@"set completed");
        label.text = @"  Completed";
        [label setTextAlignment:NSTextAlignmentCenter];
        label.layer.borderColor = [UIColor grayColor].CGColor;
        label.layer.borderWidth = 3.0;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 8.0;
        label.backgroundColor = [UIColor grayColor];
        Cell.accessoryView = label;
        Cell.accessoryView.tag = 2;
    }
    
    [Cell.accessoryView setFrame:CGRectMake(0, 0, 75, 30)];
    //    NSInteger time =[dateString integerValue];
    
    
    //    if(time >=5 && time <18)
    //    {
    //        Cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"_0013_sun.png"]];
    //    }
    //    else
    //    {
    //        Cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"_0014_moon.png"]];
    //    }
    
    //    [Cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
    Cell.textLabel.numberOfLines = 0;
    
    
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (Cell.accessoryView.tag == 1){
        NSLog(@"ok it is in active so we can enable it");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activeInState"];
    }
    else if (Cell.accessoryView.tag == 2){
        NSLog(@"no it is not active so we have to disable all values");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"activeInState"];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"activeInState"];
    }
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
    NSString *tripString;
    /* if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
     return 100.0;
     else
     return UITableViewAutomaticDimension;*/
    if (indexPath.section==0) {
        tripString = [[tripsSection1 objectAtIndex:indexPath.row] substringToIndex:[[tripsSection1 objectAtIndex:indexPath.row] length]-2];
    }
    else
    {
        tripString = [[tripsSection2 objectAtIndex:indexPath.row] substringToIndex:[[tripsSection2 objectAtIndex:indexPath.row] length]-2];
        
    }
    CGRect textRect = [tripString boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 18.0 ]}
                                               context:nil];
    CGSize size = textRect.size;
    return size.height+10;
}
-(IBAction)cancelTrip:(id)sender{
    NSLog(@"abort trip");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(int)CheckActiveTrips:(NSString *)scheduleDate with:(int)type
{
    NSLog(@"%@",scheduleDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSLog(@"time %@----%@",tripDate,dateFromString);
    
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    NSLog(@"%f",secondsBetween);
    NSLog(@"difference %f",secondsBetween);
    if(type == 1 ){
        if((secondsBetween < 1800))
        {
            NSLog(@"difference less than 1 hour %f",secondsBetween);
            return 1;
        }
        else
            return 0;
    }
    if(type  == 2 ){
        if((secondsBetween < -1800))
        {
            return 2;
        }
        else
            return 0;
    }
    return 0;
}
-(void)pushDeviceTokenWithFCM
{
    NSLog(@"push device token");
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    NSString *token = [[FIRInstanceID instanceID] token];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *findParameters = @{@"empid":userid};
    
    NSDictionary *setParameters = @{@"$set":@{@"fcmtoken":token,@"empid":userid,@"app":@"iOS",@"version":version}};
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:findParameters,setParameters, nil];
    NSError *error;
    NSData *dataJson = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    
    
    NSError *error_config;
    
    
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
        url =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@&upsert=true",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],@"write",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"fcmtokens"];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@&upsert=true",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],@"write",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"fcmtokens"];
    }
    NSURL *URL =[NSURL URLWithString:url];
    NSLog(@"%@",URL);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:dataJson];
    NSURLResponse *responce;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error_config];
    NSLog(@"%@",json);
    if ([json isKindOfClass:[NSDictionary class]]){
        if ([[json valueForKey:@"status"] isEqualToString:@"ok"]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fcmtokenpushed"];
        }else{
            
        }
    }else{
        
    }
}

-(void)tripCompletedNotification:(NSNotification *)sender{
    NSDictionary *myDictionary = (NSDictionary *)sender.object;
    NSLog(@"%@",myDictionary);
    if ([sender.name isEqualToString:@"tripCompleted"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            SomeViewController *some = [[SomeViewController alloc]init];
            [some getTripId:[myDictionary valueForKey:@"tripId"]];
            [self presentViewController:some animated:YES completion:nil];
        });
    }
}
-(void)tripsForRating{
    
    NSString *idToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
    _responseData = nil;
    _responseData = [[NSMutableData alloc] init];
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    NSLog(@"%@",tokenString);
    long double today = [[[NSDate date] dateByAddingTimeInterval:-5*60*60] timeIntervalSince1970];
    long double yesterday = [[[NSDate date] dateByAddingTimeInterval: 48*60*60] timeIntervalSince1970];
    NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
    NSString *str2 = [NSString stringWithFormat:@"%.Lf",yesterday];
    long double mine = [str1 doubleValue]*1000;
    long double mine2 = [str2 doubleValue]*1000;
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions  error:&error];
    [request setHTTPBody:postData];
    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];

    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error];
    NSLog(@"%@",result);
    if ([result isKindOfClass:[NSArray class]]){
        NSArray *tripArray = result;
        if (tripArray.count != 0){
            for (NSDictionary *eachTrip in tripArray){
                long double bufferEndTimeinMS = [[eachTrip valueForKey:@"bufferEndTime"] doubleValue];
                NSDate *bufferEndDate = [NSDate dateWithTimeIntervalSince1970:(bufferEndTimeinMS / 1000.0)];
                NSDate *presentDate = [NSDate date];
                if ([bufferEndDate compare:presentDate] == NSOrderedDescending){
                    
                    NSArray *allEmployeesArray = [eachTrip valueForKey:@"employees"];
                    for (NSDictionary *eachEmployee in allEmployeesArray){
                        NSString *employeeId = [eachEmployee valueForKey:@"_employeeId"];
                        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"] isEqualToString:employeeId]){
                            if ([eachEmployee valueForKey:@"reached"]){
                                NSDictionary *info = @{@"tripId":[[eachTrip valueForKey:@"_id"] valueForKey:@"$oid"]};
                                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                            }
                        }else{
                            NSTimeInterval differenceInSeconds = [bufferEndDate timeIntervalSinceDate:presentDate];
                            NSLog(@"%.0f",differenceInSeconds);
                            NSDictionary *info = @{@"tripId":[[eachTrip valueForKey:@"_id"] valueForKey:@"$oid"]};
                            [NSTimer scheduledTimerWithTimeInterval:differenceInSeconds target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                        }
                
                }
                    
                }else{
                    NSDictionary *info = @{@"tripId":[[eachTrip valueForKey:@"_id"] valueForKey:@"$oid"]};
                    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                }
                
                }
        }
        else{
            
        }
    }
}
-(void)pushNotification:(NSTimer *)sender{
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"]);
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"] containsObject:[sender.userInfo valueForKey:@"tripId"]]){
        
    }else{
        NSArray *userdefaultsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"];
        userdefaultsArray = [NSArray arrayWithObject:[sender.userInfo valueForKey:@"tripId"]];
        [[NSUserDefaults standardUserDefaults] setObject:userdefaultsArray forKey:@"ratingCompletedTrips"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tripCompleted" object:sender.userInfo];
    }
}
@end
