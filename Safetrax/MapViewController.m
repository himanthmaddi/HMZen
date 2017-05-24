//
//  MapViewController.m
//  Safetrax
//
//  Created by Kumaran on 08/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "MapViewController.h"
#import "SomeViewController.h"
#import "RestClientTask.h"
#import "GCMRequest.h"
#import "AppDelegate.h"
#import "SOSMainViewController.h"
#import <MBProgressHUD.h>
#import "HomeViewController.h"

#if Parent
#import "MapHelpViewController.h"
#endif
#import "AFURLSessionManager.h"
#import "tripIDModel.h"
#import "SessionValidator.h"

int isRefresh =0;
@interface MapViewController ()
{
    tripIDModel *tripModelClass;
    NSMutableArray *totalTripIDSarray;
}

@end
@implementation MapViewController
@synthesize DriverName,scrollview,boardedButton,reachedButton,waitingButton,MapHelpText;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model withHome:(HomeViewController*)homeobject {
    _buttonsView.hidden = YES;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tripModel = model;
        home = homeobject;
        // Custom initialization
    }
    return self;
}
#if Parent
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model {
    _buttonsView.hidden = YES;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tripModel = model;
        // Custom initialization
    }
    return self;
}
#endif
-(void)viewDidAppear:(BOOL)animated
{
    _buttonsView.hidden = YES;
    
    isRefresh = 0;
    _responseData = [[NSMutableData alloc] init];
    markers = [[NSMutableArray alloc] init];
    [self getDriverLocation];
    [self showMapPins:tripModel];
    timer = [NSTimer scheduledTimerWithTimeInterval:20
                                             target:self
                                           selector:@selector(refresh)
                                           userInfo:nil
                                            repeats:YES];
    [self ShowAllMarkers];
    mapView_.delegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _buttonsView.hidden = YES;
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
    }else{
        reachedButton.hidden = YES;
        waitingButton.hidden = YES;
        boardedButton.hidden = YES;
    }
    
    NSNumber *callEnabledBool = [[NSUserDefaults standardUserDefaults] objectForKey:@"callEnabled"];
    if (callEnabledBool.boolValue == YES){
        
        _callButton.hidden = NO;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
            _callButton.enabled = YES;
        }else{
            _callButton.enabled = NO;
        }
        
    }else{
        _callButton.hidden = YES;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"tripConfirmationsButtons"] && callEnabledBool.boolValue == NO){
        _buttonsView.hidden = YES;
    }else{
        _buttonsView.hidden = NO;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
    totalTripIDSarray = [[NSMutableArray alloc]init];
    reachedButton.enabled = FALSE;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"reached"] isEqualToString:@"YES"])
    {
        boardedButton.selected = TRUE;
        boardedButton.enabled = FALSE;
        waitingButton.enabled = FALSE;
        reachedButton.selected = TRUE;
        reachedButton.enabled = TRUE;
        NSLog(@"reached");
    }
    else if([tripModel.empstatus isEqualToString:@"incab"])
    {boardedButton.selected  = TRUE;
        waitingButton.enabled = FALSE;
        reachedButton.enabled = TRUE;
        NSLog(@"incab");
    }
    else if([tripModel.empstatus isEqualToString:@"waiting_cab"])
    {
        NSLog(@"waiting");
        waitingButton.selected = TRUE;
        reachedButton.enabled = FALSE;
    }
    scrollview.scrollEnabled = YES;
    scrollview.contentSize =CGSizeMake(320, 850);
#if Parent
    NSString *DriverDetails= [NSString stringWithFormat:@"%@\n%@",  tripModel.driverName,tripModel.driverPhone];
    DriverName.text = DriverDetails;
#endif
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(refresh)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Refresh" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 80, 40.0);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refresh
{
    isRefresh = 1;
    NSLog(@"markers count %d",[markers count]);
    if([markers count] >3)
        [markers removeObjectAtIndex:3];
    if([markers count] >2)
        [markers removeObjectAtIndex:2];
    marker_current.map = nil;
    marker_driver.map =nil;
    _responseData = nil;
    _responseData = [[NSMutableData alloc] init];
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
#if Parent
    //No need of current Location
#else
    marker_current= [[GMSMarker alloc] init];
    marker_current.position = CLLocationCoordinate2DMake(latitude,longitude);
    marker_current.title = @"Current Location";
    marker_current.icon = [UIImage imageNamed:@"_0002_location-marker_blue.png"];
    marker_current.icon = [self image:marker_current.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
    marker_current.map = mapView_;
    [markers addObject:marker_current];
#endif
    [self getDriverLocation];
}
-(void)getDriverLocation
{
    NSLog(@"getdriverloc");
    NSString *vehicleId = tripModel.vehicleId;
    NSLog(@"%@",vehicleId);
    NSString *columnName =@"vehicles.lastlocation";
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    NSString *headerString;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
    }else{
        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    }
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    NSDictionary *postDict = @{@"_vehicleId":vehicleId};
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"query" withMethod:@"POST" andColumnName:columnName];
    [requestWraper setBody:postDict];
    [requestWraper setAuthString:finalAuthString];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}
- (void)focusOnCoordinate:(CLLocationCoordinate2D) coordinate {
    [mapView_ animateToLocation:coordinate];
    [mapView_ animateToBearing:0];
    [mapView_ animateToViewingAngle:0];
    [mapView_ animateToZoom:14];
}
-(void)showMapPins:(TripModel *)model
{
    mapView_.mapType = kGMSTypeNormal;
    mapView_.settings.scrollGestures = NO;
    mapView_.settings.zoomGestures = NO;
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
    NSLog(@"%@",model.pickupLngLat);
    GMSMarker *marker_start = [[GMSMarker alloc] init];
    marker_start.position = CLLocationCoordinate2DMake([[model.pickupLngLat objectAtIndex:1] doubleValue],[[model.pickupLngLat objectAtIndex:0] doubleValue]);
    marker_start.title = [NSString stringWithFormat:@"Starts at %@",[model.scheduledTime substringWithRange:NSMakeRange(12, 5)]];
    marker_start.snippet =model.pickup;
    marker_start.icon = [UIImage imageNamed:@"_0001_location-marker_green.png"];
    marker_start.icon = [self image:marker_start.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
    //marker_start.map = mapView_;
    GMSMarker *marker_end= [[GMSMarker alloc] init];
    NSLog(@"droplang %@",model.dropLngLat);
    marker_end.position = CLLocationCoordinate2DMake([[model.dropLngLat objectAtIndex:1] doubleValue],[[model.dropLngLat objectAtIndex:0] doubleValue]);
    marker_end.title = [NSString stringWithFormat:@"Ends at %@",[model.tripEndTime substringWithRange:NSMakeRange(12, 5)]];
    marker_end.icon = [UIImage imageNamed:@"_0000_location-marker_red.png"];
    marker_end.icon = [self image:marker_end.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
    marker_end.snippet =model.drop;
    
#if Parent
    //Ignore Current Location
#else
    if (longitude == 0 || latitude == 0){
        
    }else{
        marker_current= [[GMSMarker alloc] init];
        NSLog(@"%f",longitude);
        NSLog(@"%f",latitude);
        marker_current.position = CLLocationCoordinate2DMake(latitude,longitude);
        marker_current.title = @"Current Location";
        marker_current.icon = [UIImage imageNamed:@"_0002_location-marker_blue.png"];
        marker_current.icon = [self image:marker_current.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
        [markers addObject:marker_current];
    }
#endif
    [markers addObject:marker_start];
    [markers addObject:marker_end];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude                                                            longitude:longitude
                                                                 zoom:12];
    CGRect fr= CGRectMake(0, 0, mapView.frame.size.width,mapView.frame.size.height);
    mapView_ = [GMSMapView mapWithFrame:fr camera:camera];
    [mapView addSubview:mapView_];
    marker_current.map = mapView_;
    marker_end.map = mapView_;
    marker_start.map =mapView_;
    //[self ShowAllMarkers];
    
}
- (void)ShowAllMarkers
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];;
    
    for (GMSMarker *marker in markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    [mapView_ moveCamera:update];
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
- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    // mapView.selectedMarker = marker;
    [mapView_ setSelectedMarker:marker];
    CGPoint point = [mapView_.projection pointForCoordinate:marker.position];
    // point.x = point.x + 100;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView_.projection coordinateForPoint:point]];
    [mapView_ animateWithCameraUpdate:camera];
    
    return TRUE;
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
            
            NSString *phNo = tripModel.driverPhone;
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
#if Parent
-(IBAction)Help:(id)sender
{
    MapHelpViewController *MapHelp = [[MapHelpViewController alloc] initWithNibName:@"MapHelpViewController" bundle:nil];
    [self presentViewController:MapHelp animated:YES completion:nil];
}
#endif

-(IBAction)waiting:(id)sender
{
    NSDateFormatter *dateFormatter123 = [[NSDateFormatter alloc]init];
    [dateFormatter123 setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    if ([[NSDate date] compare:[dateFormatter123 dateFromString:tripModel.scheduledTime]] == NSOrderedAscending){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You can send waiting only after boarding time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        NSLog(@"waiting pressed");
        UIButton *button = (UIButton *)sender;
        button.tag =601;
        if(button.selected == FALSE)
        {
            if(![tripModel.empstatus isEqualToString:@"incab"]){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @""
                                      message: @"Are You Waiting For The Cab At The Boarding Point?"
                                      delegate: self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Yes", nil];
                alert.tag =2001;
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
    NSLog(@"boarded pressed");
    UIButton *button = (UIButton *)sender;
    button.tag =602;
    if(button.selected == FALSE)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Did You Board The Cab?"
                              delegate: self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Yes", nil];
        alert.tag =2002;
        [alert show];
    }
}
-(IBAction)reached:(id)sender
{
    NSString *message;
    UIButton *button = (UIButton *)sender;
    button.tag =603;
    if(button.selected == FALSE)
    {
        if([tripModel.tripType isEqualToString:@"drop"])
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
        alert.tag =2003;
        [alert show];
    }
}
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        if(alertView.tag == 2001)
//        {
//            long double today = [[NSDate date] timeIntervalSince1970];
//            NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
//            long double mine = [str1 doubleValue]*1000;
//            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
//            NSString *columnName =@"trips";
//            NSString *tripId = tripModel.tripid;
//            NSLog(@"%@",tripId);
//            NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
//            NSLog(@"%@",employeeId);
//            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
//            NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
//            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
//            NSDictionary *firstDict = @{@"_id":@{@"$oid":tripId},@"employees._employeeId":employeeId};
//            NSDictionary *secondDict = @{@"$set":@{@"employees.$.waiting":@{@"time":todayTime,@"mode":@"ios-app"}}};
//            NSArray *finalArry = [NSArray arrayWithObjects:firstDict,secondDict, nil];
//            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:columnName];
//            [requestWraper setAuthString:finalAuthString];
//            [requestWraper setBodyFromArray:finalArry];
//            [requestWraper print];
//            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
//            [RestClient setDelegate:self];
//
//            BOOL isDone = [RestClient execute];
//            if(isDone){
//            tripModel.empstatus = @"waiting_cab";
//            [home refresh];
//            boardedButton.enabled = TRUE;
//            reachedButton.enabled = FALSE;
//            UIButton *button=(UIButton *)[self.view viewWithTag:601];
//            button.selected =YES;
//          }
//        }
//        else if(alertView.tag == 2002)
//        {
//            long double today = [[NSDate date] timeIntervalSince1970];
//            NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
//            long double mine = [str1 doubleValue]*1000;
//            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
//            NSString *columnName =@"trips";
//            NSString *tripId = tripModel.tripid;
//            NSLog(@"%@",tripId);
//            NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
//            NSLog(@"%@",employeeId);
//            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
//            NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
//            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
//            NSDictionary *firstDict = @{@"_id":@{@"$oid":tripId},@"employees._employeeId":employeeId};
//            NSDictionary *secondDict = @{@"$set":@{@"employees.$.boarded":@{@"time":todayTime,@"mode":@"ios-app"}}};
//            NSArray *finalArry = [NSArray arrayWithObjects:firstDict,secondDict, nil];
//            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:columnName];
//            [requestWraper setAuthString:finalAuthString];
//            [requestWraper setBodyFromArray:finalArry];
//            [requestWraper print];
//            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
//            [RestClient setDelegate:self];
//            BOOL isDone = [RestClient execute];
//            if(isDone){
//            tripModel.empstatus = @"incab";
//            [home refresh];
//            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
//            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
//            waitingButton.enabled = FALSE;
//            reachedButton.enabled =TRUE;
//            UIButton *button=(UIButton *)[self.view viewWithTag:602];
//            button.selected =YES;
//            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
//                {
//                    NSLog(@"start tracking home");
//                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
//                    [appDelegate updateLocation];
//                }
//            }
//       }
//        else if(alertView.tag == 2003)
//        {long double today = [[NSDate date] timeIntervalSince1970];
//            NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
//            long double mine = [str1 doubleValue]*1000;
//            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
//            NSString *columnName =@"trips";
//            NSString *tripId = tripModel.tripid;
//            NSLog(@"%@",tripId);
//            NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
//            NSLog(@"%@",employeeId);
//            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
//            NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
//            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
//            NSDictionary *firstDict = @{@"_id":@{@"$oid":tripId},@"employees._employeeId":employeeId};
//            NSDictionary *secondDict = @{@"$set":@{@"employees.$.reached":@{@"time":todayTime,@"mode":@"ios-app"}}};
//            NSArray *finalArry = [NSArray arrayWithObjects:firstDict,secondDict, nil];
//            MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:columnName];
//            [requestWraper setAuthString:finalAuthString];
//            [requestWraper setBodyFromArray:finalArry];
//            [requestWraper print];
//            RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
//            [RestClient setDelegate:self];
//            BOOL isDone = [RestClient execute];
//            if(isDone){
//            [home refresh];
//            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
//            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
//            waitingButton.enabled = FALSE;
//            boardedButton.selected = TRUE;
//            boardedButton.enabled = FALSE;
//            UIButton *button=(UIButton *)[self.view viewWithTag:603];
//            button.selected =YES;
//            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
//            [appDelegate stopUpdateLocation];
//            }
//        }
//      }
//    else {
//        NSLog(@"user pressed Cancel");
//    }
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2002){
        if (buttonIndex == 0){
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                TripRatingViewController *some = [[TripRatingViewController alloc]init];
            //                [self presentViewController:some animated:YES completion:nil];
            //            });
        }
    }
    else{
        if (alertView.tag == 2003){
            if (buttonIndex == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    SomeViewController *some = [[SomeViewController alloc]init];
                    [self presentViewController:some animated:YES completion:nil];
                });
            }
        }
        else{
            if (buttonIndex == 1) {
                if(alertView.tag == 2001)
                {
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
                    NSString *tripId = tripModel.tripid;
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
                            tripModel.empstatus = @"waiting_cab";
                            [home refresh];
                            boardedButton.enabled = TRUE;
                            reachedButton.enabled = FALSE;
                            UIButton *button=(UIButton *)[self.view viewWithTag:601];
                            button.selected =YES;
                            
                            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                            {
                                NSLog(@"start tracking home");
                                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                [appDelegate updateLocation];
                            }
                        }
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
                else if(alertView.tag == 2002)
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
                            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
                            NSString *tripId = tripModel.tripid;
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
                                if (error) {
                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                    NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                    if ((long)[httpResponse statusCode] == 409){
                                        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You already boarded cab with RFID swipe" delegate:nil cancelButtonTitle:@"Ok! Thanks" otherButtonTitles:nil, nil];
                                        [aler show];
                                        tripModel.empstatus = @"incab";
                                        [home refresh];
                                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                                        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                                        waitingButton.enabled = FALSE;
                                        reachedButton.enabled =TRUE;
                                        UIButton *button=(UIButton *)[self.view viewWithTag:602];
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
                                    
                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                    NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                    if ((long)[httpResponse statusCode] == 409){
                                        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You already boarded cab with RFID swipe" delegate:nil cancelButtonTitle:@"Ok! Thanks" otherButtonTitles:nil, nil];
                                        [aler show];
                                    }
                                    //                    tripModel.empstatus = @"incab";
                                    //                    [home refresh];
                                    //                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                                    //                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                                    //                    waitingButton.enabled = FALSE;
                                    //                    reachedButton.enabled =TRUE;
                                    //                    UIButton *button=(UIButton *)[self.view viewWithTag:502];
                                    //                    button.selected =YES;
                                    //                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                                    //                    {
                                    //                        NSLog(@"start tracking home");
                                    //                        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                    //                        [appDelegate updateLocation];
                                    //                    }
                                    tripModel.empstatus = @"incab";
                                    [home refresh];
                                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                                    waitingButton.enabled = FALSE;
                                    reachedButton.enabled =TRUE;
                                    UIButton *button=(UIButton *)[self.view viewWithTag:602];
                                    button.selected =YES;
                                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                                    {
                                        NSLog(@"start tracking home");
                                        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                        [appDelegate updateLocation];
                                    }
                                }
                            }];
                            [dataTask resume];
                            
                            
                            //           BOOL isDone = [RestClient execute];
                            //           if(isDone){
                            //             model.empstatus = @"incab";
                            //           [home refresh];
                            //               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                            //               [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                            //               waitingButton.enabled = FALSE;
                            //               reachedButton.enabled =TRUE;
                            //               UIButton *button=(UIButton *)[self.view viewWithTag:502];
                            //               button.selected =YES;
                            //               if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                            //               {
                            //                   NSLog(@"start tracking home");
                            //                   AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            //                   [appDelegate updateLocation];
                            //               }
                            //           }
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                }
                else if(alertView.tag == 2003)
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
                            NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
                            NSString *tripId = tripModel.tripid;
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
                            
                            NSDictionary *bodyDict = @{@"type":@"reached",@"tripId":tripId,@"employeeId":employeeId};
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
                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                    NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                    if ((long)[httpResponse statusCode] == 409){
                                        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You already reached destination with RFID swipe" delegate:nil cancelButtonTitle:@"Ok! Thanks" otherButtonTitles:nil, nil];
                                        [aler show];
                                        [home refresh];
                                        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                                        waitingButton.enabled = FALSE;
                                        boardedButton.selected = TRUE;
                                        boardedButton.enabled = FALSE;
                                        UIButton *button=(UIButton *)[self.view viewWithTag:603];
                                        button.selected =YES;
                                        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                        [appDelegate stopUpdateLocation];
                                    }
                                } else {
                                    [home refresh];
                                    
                                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                                    waitingButton.enabled = FALSE;
                                    boardedButton.selected = TRUE;
                                    boardedButton.enabled = FALSE;
                                    UIButton *button=(UIButton *)[self.view viewWithTag:603];
                                    button.selected =YES;
                                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                    [appDelegate stopUpdateLocation];
                                }
                            }];
                            [dataTask resume];
                            
                            //            BOOL isDone = [RestClient execute];
                            //            if(isDone){
                            //            [home refresh];
                            //            boardedButton.selected = TRUE;
                            //            boardedButton.enabled = FALSE;
                            //            waitingButton.enabled = FALSE;
                            //            tripModelClass = [[tripIDModel alloc]init];
                            //            [tripModelClass addIdToMutableArray:model.tripid];
                            //
                            //                NSLog(@"%@",tripModelClass.tripIdArray);
                            //                [_totalTripIDSarray addObject:tripModelClass.tripIdArray];
                            //                [[NSUserDefaults standardUserDefaults] setObject:_totalTripIDSarray forKey:@"allTrips"];
                            //
                            //            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                            //            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                            //            UIButton *button=(UIButton *)[self.view viewWithTag:503];
                            //            button.selected =YES;
                            //            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            //            [appDelegate stopUpdateLocation];
                            //            }
                            NSDictionary *info = @{@"tripId":tripModel.tripid};
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                }
                
            }
        }
    }
}

-(IBAction)sos:(id)sender{
    SOSMainViewController *sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:tripModel];
    [self presentViewController:sosController animated:YES completion:nil];
}
-(IBAction)moreButtonClicked
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                  @"Call Driver",
                                  @"Refresh Map",
                                  nil];
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Call Driver"]) {
        [self call:nil];
    }
    if ([buttonTitle isEqualToString:@"Refresh Map"]) {
        [self refresh];
    }
}
-(void)setDriverLocation
{
    NSArray *loc =[[NSUserDefaults standardUserDefaults] arrayForKey:@"driverCurrentLocation"];
    NSLog(@"%f",[[loc objectAtIndex:1] doubleValue]);
    NSLog(@"%f",[[loc objectAtIndex:0] doubleValue]);
    if ([[loc objectAtIndex:1] doubleValue] == 0 || [[loc objectAtIndex:0] doubleValue] == 0){
    }
    else{
        marker_driver = nil;
        marker_driver= [[GMSMarker alloc] init];
        marker_driver.position = CLLocationCoordinate2DMake([[loc objectAtIndex:1] doubleValue],[[loc objectAtIndex:0] doubleValue]);
        marker_driver.title = @"Driver Current Location";
        marker_driver.icon = [UIImage imageNamed:@"DriverLoc.png"];
        marker_driver.icon = [self image:marker_driver.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
        marker_driver.snippet = [[NSUserDefaults standardUserDefaults] stringForKey:@"vehicleAddress"];
        marker_driver.map = mapView_;
        [markers addObject:marker_driver];
        if(!isRefresh)
            [self ShowAllMarkers]; //for the first time alone
    }
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
    NSLog(@"driver loc finished %@",newStr);
    id driverinfo= [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    if([driverinfo isKindOfClass:[NSDictionary class]]){
        if([driverinfo objectForKey:@"status"]){
            NSLog(@"no driver data");
        }
    }
    else
    {
        for (NSDictionary *config in driverinfo) {
            if(config[@"coordinates"]){
                NSLog(@"Driver Loc-->%@",config[@"coordinates"]);
                [[NSUserDefaults standardUserDefaults] setObject:config[@"coordinates"] forKey:@"driverCurrentLocation"];
                [[NSUserDefaults standardUserDefaults] setValue:config[@"address"] forKey:@"vehicleAddress"];
            }
        }
        [self setDriverLocation];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}
-(void)viewWillAppear:(BOOL)animated{
    _buttonsView.hidden = YES;
    
    NSMutableArray *myArray;
    for (NSArray *tempArray in [[NSUserDefaults standardUserDefaults] objectForKey:@"allTrips"])
    {
        myArray = [[NSMutableArray alloc]initWithArray:tempArray copyItems:YES];
    }
    if([tripModel.empstatus isEqualToString:@"reached"]){
        boardedButton.selected = TRUE;
        boardedButton.enabled = FALSE;
        waitingButton.enabled = FALSE;
        [reachedButton setBackgroundImage:[UIImage imageNamed:@"_0012_office_active.png"] forState:UIControlStateNormal];
        UIButton *button=(UIButton *)[self.view viewWithTag:503];
        button.selected =YES;    }
    else{
        if([tripModel.empstatus isEqualToString:@"incab"])
        {
            boardedButton.selected  = TRUE;
            waitingButton.enabled = FALSE;
            reachedButton.enabled = TRUE;
        }
        if([tripModel.empstatus isEqualToString:@"waiting_cab"])
        {
            waitingButton.selected = TRUE;
            reachedButton.enabled = FALSE;
        }
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"reached"] isEqualToString:@"YES"])
        {
            waitingButton.selected = FALSE;
            boardedButton.enabled = FALSE;
            reachedButton.enabled = TRUE;
            reachedButton.selected = TRUE;
        }
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:tripModel.scheduledTime];
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
    if (secondsBetween < 1800){
        
    }else{
        waitingButton.enabled = FALSE;
        boardedButton.enabled = FALSE;
        reachedButton.enabled = FALSE;
        boardedButton.selected = TRUE;
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

