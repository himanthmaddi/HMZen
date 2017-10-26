//
//  MapViewController.m
//  Safetrax
//
//  Created by Kumaran on 08/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "NewMapViewViewController.h"
#import "SomeViewController.h"
#import "RestClientTask.h"
#import "GCMRequest.h"
#import "AppDelegate.h"
#import "SOSMainViewController.h"
#import <MBProgressHUD.h>
#import "HomeViewController.h"
#import "SomeViewController.h"
#import "Reachability.h"
#import "MFSideMenu.h"
#import "MenuViewController.h"
#if Parent
#import "MapHelpViewController.h"
#endif
#import "AFURLSessionManager.h"
#import "tripIDModel.h"
#import "SessionValidator.h"
extern MFSideMenuContainerViewController *rootViewControllerParent_delegate;
int isRefresh =0;
@interface NewMapViewViewController ()
{
    tripIDModel *tripModelClass;
    NSMutableArray *totalTripIDSarray;
    UIView *statusView;
    UILabel *statusLabel;
}

@end
@implementation NewMapViewViewController
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
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Shown"];
    
    _buttonsView.hidden = YES;
    
    isRefresh = 0;
    _responseData = [[NSMutableData alloc] init];
    markers = [[NSMutableArray alloc] init];
    marker_driver= [[GMSMarker alloc] init];
    [self showMapPins:tripModel];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
        timer = [NSTimer scheduledTimerWithTimeInterval:20
                                                 target:self
                                               selector:@selector(refresh)
                                               userInfo:nil
                                                repeats:YES];
        [timer fire];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [statusView removeFromSuperview];
            [statusLabel removeFromSuperview];
            mapView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
            CGRect size = mapView.frame;
            mapView.frame = CGRectMake(size.origin.x, size.origin.y + 30, size.size.width, size.size.height);
            statusView = [[UIView alloc]initWithFrame:CGRectMake(0, size.origin.y, self.view.frame.size.width, 30)];
            [self.view addSubview:statusView];
            statusView.backgroundColor = [UIColor lightGrayColor];
            statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            statusLabel.textAlignment = NSTextAlignmentCenter;
            [statusView addSubview:statusLabel];
            statusLabel.font = [UIFont systemFontOfSize:12.0];
            statusLabel.text = @"Couldn't locate the cab, trip is not active.";
        });
    }
    [self ShowAllMarkers];
    mapView_.delegate = self;
    mapView_.myLocationEnabled = YES;
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
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"reached"] isEqualToString:@"YES"] || [tripModel.empstatus isEqualToString:@"reached"]){
            _tripConfirmationsButton.hidden = YES;
        }else{
            _tripConfirmationsButton.hidden = NO;
        }
    }else{
        reachedButton.hidden = YES;
        waitingButton.hidden = YES;
        boardedButton.hidden = YES;
        _tripConfirmationsButton.hidden = YES;
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
        SessionValidator *validator = [[SessionValidator alloc]init];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
            NSLog(@"%@",result);
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"no refresh");
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tripCompleted" object:nil];
    
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
    //    marker_current.map = nil;
    //    marker_driver.map =nil;
    _responseData = nil;
    _responseData = [[NSMutableData alloc] init];
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
#if Parent
    //No need of current Location
#else
    //    marker_current= [[GMSMarker alloc] init];
    //    marker_current.position = CLLocationCoordinate2DMake(latitude,longitude);
    //    marker_current.title = @"Current Location";
    //    marker_current.icon = [UIImage imageNamed:@"_0002_location-marker_blue.png"];
    //    marker_current.icon = [self image:marker_current.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
    //    marker_current.map = mapView_;
    //    [markers addObject:marker_current];
#endif
    [self getDriverLocation];
    if ([tripModel.tripType isEqualToString:@"Pickup"]){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
            [self getETA];
        }
    }else{
        
    }
}
-(void)getDriverLocation
{
    if ([self connectedToInternet]){
        NSString *vehicleId = tripModel.vehicleId;
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
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [statusView removeFromSuperview];
            [statusLabel removeFromSuperview];
            mapView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
            CGRect size = mapView.frame;
            mapView.frame = CGRectMake(size.origin.x, size.origin.y + 30, size.size.width, size.size.height);
            statusView = [[UIView alloc]initWithFrame:CGRectMake(0, size.origin.y, self.view.frame.size.width, 30)];
            [self.view addSubview:statusView];
            statusView.backgroundColor = [UIColor lightGrayColor];
            statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            statusLabel.textAlignment = NSTextAlignmentCenter;
            [statusView addSubview:statusLabel];
            statusLabel.font = [UIFont systemFontOfSize:12.0];
            statusLabel.text = @"Internet connection appears to be offline.";
        });
    }
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
    marker_start = [[GMSMarker alloc] init];
    marker_start.position = CLLocationCoordinate2DMake([[model.pickupLngLat objectAtIndex:1] doubleValue],[[model.pickupLngLat objectAtIndex:0] doubleValue]);
    if ([model.tripType isEqualToString:@"Pickup"]){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                marker_start.title = _etaString;
                mapView_.selectedMarker = marker_start;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                marker_start.title = [NSString stringWithFormat:@"Starts at %@",[model.scheduledTime substringWithRange:NSMakeRange(12, 5)]];
                marker_start.snippet =model.pickup;
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            marker_start.title = [NSString stringWithFormat:@"Starts at %@",[model.scheduledTime substringWithRange:NSMakeRange(12, 5)]];
            marker_start.snippet =model.pickup;
        });
    }
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
        //        marker_current= [[GMSMarker alloc] init];
        //        NSLog(@"%f",longitude);
        //        NSLog(@"%f",latitude);
        //        marker_current.position = CLLocationCoordinate2DMake(latitude,longitude);
        //        marker_current.title = @"Current Location";
        //        marker_current.icon = [UIImage imageNamed:@"_0002_location-marker_blue.png"];
        //        marker_current.icon = [self image:marker_current.icon scaledToSize:CGSizeMake(50.0f, 50.0f)];
        //        [markers addObject:marker_current];
    }
#endif
    [markers addObject:marker_start];
    [markers addObject:marker_end];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude                                                            longitude:longitude
                                                                 zoom:12];
    CGRect fr= CGRectMake(0, 0, mapView.frame.size.width,mapView.frame.size.height);
    mapView_ = [GMSMapView mapWithFrame:fr camera:camera];
    [mapView addSubview:mapView_];
    //    marker_current.map = mapView_;
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
    [timer invalidate];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    });
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2222){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Dismiss"];
        dispatch_async(dispatch_get_main_queue(), ^{
            HomeViewController *home = [[HomeViewController alloc]init];
            MenuViewController *menu = [[MenuViewController alloc]init];
            rootViewControllerParent_delegate = [MFSideMenuContainerViewController
                                                 containerWithCenterViewController:home
                                                 leftMenuViewController:menu
                                                 rightMenuViewController:nil];
            [self presentViewController:rootViewControllerParent_delegate animated:NO completion:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        });
    }
    if (alertView.tag == 01234){
        
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
                SessionValidator *validator = [[SessionValidator alloc]init];
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                    NSLog(@"%@",result);
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
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
            
            NSDictionary *bodyDict = @{@"type":@"waiting",@"tripId":tripId,@"employeeId":employeeId};
            
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
                    //                    [home refresh];
                    boardedButton.enabled = TRUE;
                    reachedButton.enabled = FALSE;
                    UIButton *button3=(UIButton *)[self.view viewWithTag:601];
                    button3.selected =YES;
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                    {
                        NSLog(@"start tracking home");
                        //                        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                        //                        [appDelegate updateLocation];
                    }
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            [dataTask resume];
            
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
                        SessionValidator *validator = [[SessionValidator alloc]init];
                        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                        [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                            NSLog(@"%@",result);
                            dispatch_semaphore_signal(semaphore);
                        }];
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        
                    }
                    else if(result == NSOrderedAscending)
                    {
                        NSLog(@"no refresh");
                    }
                    
                    long double today = [[NSDate date] timeIntervalSince1970];
                    NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
                    long double mine = [str1 doubleValue]*1000;
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
                    NSDictionary *bodyDict = @{@"type":@"boarded",@"tripId":tripId,@"employeeId":employeeId};
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
                                tripModel.empstatus = @"incab";
                                //                                [home refresh];
                                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                                waitingButton.enabled = FALSE;
                                reachedButton.enabled =TRUE;
                                UIButton *button=(UIButton *)[self.view viewWithTag:502];
                                button.selected =YES;
                                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                                {
                                    //                                    NSLog(@"start tracking home");
                                    //                                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                    //                                    [appDelegate updateLocation];
                                }
                            }
                            
                        } else {
                            NSLog(@"%@ %@", response, responseObject);
                            tripModel.empstatus = @"incab";
                            //                            [home refresh];
                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"incab"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
                            waitingButton.enabled = FALSE;
                            reachedButton.enabled =TRUE;
                            UIButton *button=(UIButton *)[self.view viewWithTag:502];
                            button.selected =YES;
                            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
                            {
                                NSLog(@"start tracking home");
                                //                                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                //                                [appDelegate updateLocation];
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([tripModel.tripType isEqualToString:@"Pickup"]){
                                mapView_.selectedMarker = marker_start;
                                marker_start.title = @"ETA --";
                            }
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
                        SessionValidator *validator = [[SessionValidator alloc]init];
                        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                        [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                            NSLog(@"%@",result);
                            dispatch_semaphore_signal(semaphore);
                        }];
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    }
                    
                    else if(result == NSOrderedAscending)
                    {
                        NSLog(@"no refresh");
                    }
                    
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
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
                    [request setHTTPMethod:@"POST"];
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error];
                    [request setHTTPBody:jsonData];
                    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        if (error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                            if ((long)[httpResponse statusCode] == 409){
                                _tripConfirmationsButton.hidden = YES;
                                UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You already reached destination with RFID swipe" delegate:self cancelButtonTitle:@"Ok! Thanks" otherButtonTitles:nil, nil];
                                [aler show];
                                aler.tag = 01234;
                                boardedButton.selected = TRUE;
                                boardedButton.enabled = FALSE;
                                waitingButton.enabled = FALSE;
                                tripModelClass = [[tripIDModel alloc]init];
                                [tripModelClass addIdToMutableArray:tripModel.tripid];
                                
                                [totalTripIDSarray addObject:tripModelClass.tripIdArray];
                                [[NSUserDefaults standardUserDefaults] setObject:totalTripIDSarray forKey:@"allTrips"];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                                UIButton *button=(UIButton *)[self.view viewWithTag:503];
                                button.selected =YES;
                                //                                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                                //                                [appDelegate stopUpdateLocation];
                                
                                NSDictionary *info = @{@"tripId":tripModel.tripid};
                                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                            }
                        }
                        else {
                            //                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have successfully reached your destination." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            //                            [alert show];
                            //                            alert.tag = 2222;
                            _tripConfirmationsButton.hidden = YES;
                            NSLog(@"%@",response);
                            //                            [home refresh];
                            boardedButton.selected = TRUE;
                            boardedButton.enabled = FALSE;
                            waitingButton.enabled = FALSE;
                            tripModelClass = [[tripIDModel alloc]init];
                            [tripModelClass addIdToMutableArray:tripModel.tripid];
                            
                            NSLog(@"%@",tripModelClass.tripIdArray);
                            [totalTripIDSarray addObject:tripModelClass.tripIdArray];
                            [[NSUserDefaults standardUserDefaults] setObject:totalTripIDSarray forKey:@"allTrips"];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"incab"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reached"];
                            UIButton *button=(UIButton *)[self.view viewWithTag:503];
                            button.selected =YES;
                            //                            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            //                            [appDelegate stopUpdateLocation];
                            
                            NSDictionary *info = @{@"tripId":tripModel.tripid};
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushNotification:) userInfo:info repeats:NO];
                        }
                        tripModel.empstatus = @"reached";
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }];
                    [dataTask resume];
                    
                });
            });
        }else if (alertView.tag == 1004)
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
                SessionValidator *validator = [[SessionValidator alloc]init];
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                    NSLog(@"%@",result);
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
            }
            else if(result == NSOrderedAscending)
            {
                NSLog(@"no refresh");
            }
            
            NSString *tripId = tripModel.tripid;
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can not cancel this trip" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{
                    NSLog(@"%@",jsonObject);
                    NSLog(@"%@",response);
                    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)response;
                    if (httpresponse.statusCode == 200){
                        NSMutableArray *newArray = [[NSMutableArray alloc]init];
                        [newArray addObject:tripModel.tripid];
                        NSArray *oldArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"notAvailTrips"];
                        [newArray addObjectsFromArray:oldArray];
                        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"notAvailTrips"];
                        [timer invalidate];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are no longer avail for this trip" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        alert.tag = 2222;
                        
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can not cancel this trip" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }
                }
            }];
            [dataTask resume];
            
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
-(void)setDriverLocation
{
    NSArray *loc =[[NSUserDefaults standardUserDefaults] arrayForKey:@"driverCurrentLocation"];
    NSLog(@"%f",[[loc objectAtIndex:1] doubleValue]);
    NSLog(@"%f",[[loc objectAtIndex:0] doubleValue]);
    if ([[loc objectAtIndex:1] doubleValue] == 0 || [[loc objectAtIndex:0] doubleValue] == 0){
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeInState"]){
                [CATransaction begin];
                [CATransaction setAnimationDuration:5.0];
                marker_driver.icon = [self image:[UIImage imageNamed:@"mapnewCar.png"] scaledToSize:CGSizeMake(20.0f, 40.0f)];
                marker_driver.position = CLLocationCoordinate2DMake([[loc objectAtIndex:1] doubleValue],[[loc objectAtIndex:0] doubleValue]);
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy/MM/dd-HH:mm"];
                double lastupdateTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"LastUpdated"] doubleValue];
                NSTimeInterval seconds = lastupdateTime / 1000;
                NSDate *lastUpdateDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                marker_driver.title = [NSString stringWithFormat:@"%@ %@",@"Last updated at",[formatter stringFromDate:lastUpdateDate]];
                marker_driver.rotation = [[NSUserDefaults standardUserDefaults] floatForKey:@"course"];
                marker_driver.map = mapView_;
                marker_driver.flat = YES;
                [CATransaction commit];
                [markers addObject:marker_driver];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Shown"]){
                    
                }else{
                    [self ShowAllMarkersWithCab];
                }
            }else{
                marker_driver.map = nil;
            }
        });
        if(!isRefresh)
            [self ShowAllMarkers]; //for the first time alone
    }
}
-(void)ShowAllMarkersWithCab{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];;
    
    for (GMSMarker *marker in markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    [mapView_ moveCamera:update];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Shown"];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
}
-(void)onFailure
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [statusView removeFromSuperview];
        [statusLabel removeFromSuperview];
        mapView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
        CGRect size = mapView.frame;
        mapView.frame = CGRectMake(size.origin.x, size.origin.y + 30, size.size.width, size.size.height);
        statusView = [[UIView alloc]initWithFrame:CGRectMake(0, size.origin.y, self.view.frame.size.width, 30)];
        [self.view addSubview:statusView];
        statusView.backgroundColor = [UIColor lightGrayColor];
        statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [statusView addSubview:statusLabel];
        statusLabel.font = [UIFont systemFontOfSize:12.0];
        statusLabel.text = @"Couldn't get cab location, Retrying...";
    });
    
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
    if(![driverinfo isKindOfClass:[NSArray class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [statusView removeFromSuperview];
            [statusLabel removeFromSuperview];
            mapView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
            CGRect size = mapView.frame;
            mapView.frame = CGRectMake(size.origin.x, size.origin.y + 30, size.size.width, size.size.height);
            statusView = [[UIView alloc]initWithFrame:CGRectMake(0, size.origin.y, self.view.frame.size.width, 30)];
            [self.view addSubview:statusView];
            statusView.backgroundColor = [UIColor lightGrayColor];
            statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            statusLabel.textAlignment = NSTextAlignmentCenter;
            [statusView addSubview:statusLabel];
            statusLabel.font = [UIFont systemFontOfSize:12.0];
            statusLabel.text = @"Couldn't get cab location, Retrying...";
        });
    }
    else
    {
        if([driverinfo count] != 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [statusView removeFromSuperview];
                [statusLabel removeFromSuperview];
                mapView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
            });
            for (NSDictionary *config in driverinfo) {
                if(config[@"coordinates"]){
                    NSLog(@"Driver Loc-->%@",config[@"coordinates"]);
                    [[NSUserDefaults standardUserDefaults] setObject:config[@"coordinates"] forKey:@"driverCurrentLocation"];
                    [[NSUserDefaults standardUserDefaults] setValue:config[@"address"] forKey:@"vehicleAddress"];
                    [[NSUserDefaults standardUserDefaults] setFloat:[[config objectForKey:@"course"] floatValue] forKey:@"course"];
                    [[NSUserDefaults standardUserDefaults] setValue:config[@"time"] forKey:@"LastUpdated"];
                }
            }
            [self setDriverLocation];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [statusView removeFromSuperview];
                [statusLabel removeFromSuperview];
                mapView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
                CGRect size = mapView.frame;
                mapView.frame = CGRectMake(size.origin.x, size.origin.y + 30, size.size.width, size.size.height);
                statusView = [[UIView alloc]initWithFrame:CGRectMake(0, size.origin.y, self.view.frame.size.width, 30)];
                [self.view addSubview:statusView];
                statusView.backgroundColor = [UIColor lightGrayColor];
                statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
                statusLabel.textAlignment = NSTextAlignmentCenter;
                [statusView addSubview:statusLabel];
                statusLabel.font = [UIFont systemFontOfSize:12.0];
                statusLabel.text = @"Couldn't get cab location, Retrying...";
            });
        }
    }
}
-(NSString *)getDoubleValueInStringWithFormate:(NSString *)dateFormat andWithDouble:(long double)dateInDouble{
    NSDate *doubleInDate = [NSDate dateWithTimeIntervalSince1970:(dateInDouble / 1000.0)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSString *dateInString = [dateFormatter stringFromDate:doubleInDate];
    return dateInString;
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
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tripCompleted" object:nil];
                SomeViewController *some1 = [[SomeViewController alloc]init];
                [some1 getTripId:[myDictionary valueForKey:@"tripId"]];
                [self presentViewController:some1 animated:YES completion:nil];
            }else{
                
            }
        });
    }
}
-(void)pushNotification:(NSTimer *)sender{
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"] containsObject:tripModel.tripid]){
        
    }else{
        NSMutableArray *newArray = [[NSMutableArray alloc]init];
        [newArray addObject:[sender.userInfo valueForKey:@"tripId"]];
        NSArray *oldArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"];
        [newArray addObjectsFromArray:oldArray];
        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"ratingCompletedTrips"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tripCompleted" object:sender.userInfo];
    }
}
-(IBAction)tripConfirmationsButton:(id)sender;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Update your trip status" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    if([tripModel.empstatus isEqualToString:@"reached"]){
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
            _sosMainButton.hidden = YES;
        }else{
            _sosMainButton.hidden = NO;
        }
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"You have already reached destination" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
    }
    else{
        if([tripModel.empstatus isEqualToString:@"incab"])
        {
            [actionSheet addButtonWithTitle:@"I have reached"];
            [actionSheet showInView:self.view];
            
        }
        else if([tripModel.empstatus isEqualToString:@"waiting_cab"])
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
                //                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
                //                    _sosMainButton.hidden = YES;
                //                }else{
                //                    _sosMainButton.hidden = NO;
                //                }
                UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"You can give your confirmations when trip is in active state" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertview show];
            }
        }
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 8_3) __TVOS_PROHIBITED;
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I am waiting"]){
        NSDateFormatter *dateFormatter123 = [[NSDateFormatter alloc]init];
        [dateFormatter123 setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
        if ([[NSDate date] compare:[dateFormatter123 dateFromString:tripModel.scheduledTime]] == NSOrderedAscending){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You can send waiting only after boarding time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            UIAlertView *waitingAlert = [[UIAlertView alloc] initWithTitle:@"Are You Waiting For The Cab At The Boarding Point?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [waitingAlert show];
            waitingAlert.tag = 1001;
        }
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I have boarded"]){
        
        UIAlertView *boardingAlert = [[UIAlertView alloc] initWithTitle:@"Did You Board The Cab?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [boardingAlert show];
        boardingAlert.tag = 1002;
        
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"I have reached"]){
        
        NSString *message;
        
        if([tripModel.tripType isEqualToString:@"Drop"])
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
-(BOOL)connectedToInternet
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}
-(void)getETA{
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
            SessionValidator *validator = [[SessionValidator alloc]init];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                NSLog(@"%@",result);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
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
            if ([jsonResult isKindOfClass:[NSArray class]]){
                NSArray *array = jsonResult;
                NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                for (NSDictionary *dict in array){
                    if ([tripModel.tripid isEqualToString:[[dict valueForKey:@"_id"] valueForKey:@"$oid"]]){
                        for (NSDictionary *dict2 in [dict valueForKey:@"employees"]){
                            if ([[dict2 valueForKey:@"_employeeId"] isEqualToString:employeeId]){
                                if ([dict2 valueForKey:@"boarded"] || [dict2 valueForKey:@"reached"])
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        marker_start.title = @"ETA --";
                                        mapView_.selectedMarker = marker_start;
                                    });
                                }else{
                                    NSArray *allStops = [dict objectForKey:@"stoppages"];
                                    for (NSDictionary *eachDict in allStops){
                                        if ([[eachDict valueForKey:@"type"] isEqualToString:@"employee"]){
                                            if ([[eachDict objectForKey:@"_pickup"] containsObject:employeeId]){
                                                if ([eachDict objectForKey:@"entryTime"] || [eachDict objectForKey:@"exitTime"]){
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        marker_start.title = @"ETA  --";
                                                        mapView_.selectedMarker = marker_start;
                                                    });
                                                }else{
                                                    [self getETAWithCompletionBlock:^(NSString *minutes) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            mapView_.selectedMarker = marker_start;
                                                            if ([minutes isEqualToString:@"NO"]){
                                                                marker_start.title = @"ETA --";
                                                            }else{
                                                                if ([minutes isEqualToString:@"1"] || [minutes isEqualToString:@"0"]){
                                                                    marker_start.title = [NSString stringWithFormat:@"%@ %@%@",@"ETA",minutes,@"min"];
                                                                }else{
                                                                    marker_start.title = [NSString stringWithFormat:@"%@ %@%@",@"ETA",minutes,@"mins"];
                                                                }
                                                            }
                                                        });
                                                    }];
                                                }
                                            }else{
                                                
                                            }
                                        }else{
                                            
                                        }
                                    }
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
    });
}
-(void)getETAWithCompletionBlock:(void(^)(NSString *))completion{
    NSString *tripId = tripModel.tripid;
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
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError){
            completion(@"NO");
        }else{
            NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&connectionError]);
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&connectionError];
            dispatch_async(dispatch_get_main_queue(), ^{
                int time;
                if ([json isKindOfClass:[NSDictionary class]]){
                    if ([json valueForKey:@"time"]){
                        time = [[json valueForKey:@"time"] intValue];
                        int minutes = (time / 60) % 60;
                        completion([NSString stringWithFormat:@"%i",minutes]);
                    }else{
                        mapView_.selectedMarker = marker_start;
                        marker_start.title = @"ETA --";
                        completion(@"NO");
                    }
                }else{
                    mapView_.selectedMarker = marker_start;
                    marker_start.title = @"ETA --";
                    completion(@"NO");
                }
            });
        }
    }];
    
}

@end


