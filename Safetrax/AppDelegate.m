//
//  AppDelegate.m
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//
#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "MenuViewControllerParent.h"
#import "LoginViewController.h"
#import "TripModel.h"
#import <GoogleMaps/GoogleMaps.h>
#import "companyCodeViewController.h"
#import "FeedbackViewController.h"
#import "CheckFeedbackViewController.h"
#import <Smooch/Smooch.h>
#import "Harpy.h"
#import <IQKeyboardManager.h>


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif
@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;


BOOL isFromLogin = TRUE;
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
MFSideMenuContainerViewController *rootViewController_delegate;

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

NSString *const SubscriptionTopic = @"/topics/global";

#endif
// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation AppDelegate
@synthesize responseData;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [IQKeyboardManager sharedManager].enable = YES;
    
    [FIRApp configure];
    
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            [application registerForRemoteNotifications];
            
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
             }
             ];
            // For iOS 10 display notification (sent via APNS)
            [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
            // For iOS 10 data message (sent via FCM)
            [[FIRMessaging messaging] setRemoteMessageDelegate:self];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
#endif
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    
    NSLog(@"launched");
    
        // Launched from push notification
        UILocalNotification *localNotif =
        [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotif)
        {
            application.applicationIconBadgeNumber = 0;
            NSLog(@"ss-%@",localNotif);
            NSDictionary *userInfo = localNotif.userInfo;
            if ([@"Feedback" isEqualToString:[userInfo objectForKey:@"isFeedbackNotification"]]){
                NSString *tripID = [userInfo objectForKey:@"LastTripId"];
                 [[NSUserDefaults standardUserDefaults] setObject:tripID forKey:@"LastTripId"];
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
                //CheckFeedbackViewController *CheckFeedback = [[CheckFeedbackViewController alloc] init];
                //[CheckFeedback downloadConfig];
            }
        }
       /* if ([notification.userInfo[@"isFeedbackNotification"] isEqualToString:@"Feedback"]) {
            NSLog(@"received local push");
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
            
        }*/


    
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
        {
        [self updateLocation];
        }
    }
    
    
    
    
//    UIRemoteNotificationType notificationTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//
//    if (notificationTypes == UIRemoteNotificationTypeNone) {
//        NSLog(@"notification denied");
//    }
//    BOOL isgranted;
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
//    {
//        isgranted =  [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
//    }
//#else
//    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//    if (types & UIRemoteNotificationTypeAlert)
//    {
//        isgranted = true;
//    }
//#endif
//     NSLog(@"notification granted? %hhd",isgranted);
    isOffline = FALSE;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [GMSServices provideAPIKey:@"AIzaSyBVjiFtamOckXkk_3EVT_KkbiBZyWbJxwg"];
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
//            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
//            [application registerUserNotificationSettings:settings];
//        }
//    } else {
//        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
//        [application registerForRemoteNotificationTypes:myTypes];
//    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    

    
    BOOL login = [userDefault boolForKey:@"loginAlready"];
    if (login){
        isFromLogin = FALSE;
        #if Parent
        NSLog(@"parent safetrax delegate");
        HomeViewController *home = [[HomeViewController alloc]init];
        MenuVIewControllerParent *menu = [[MenuVIewControllerParent alloc]init];
        rootViewController_delegate = [MFSideMenuContainerViewController
                                       containerWithCenterViewController:home
                                       leftMenuViewController:menu
                                       rightMenuViewController:nil];
        #else
        HomeViewController *home = [[HomeViewController alloc]init];
        MenuViewController *menu = [[MenuViewController alloc]init];
        rootViewController_delegate = [MFSideMenuContainerViewController
                                       containerWithCenterViewController:home
                                       leftMenuViewController:menu
                                       rightMenuViewController:nil];
        #endif
        self.window.rootViewController = rootViewController_delegate ;
    }
    else{
        isFromLogin = TRUE;
        companyCodeViewController *companyCodeView = [[companyCodeViewController alloc]init];
        self.window.rootViewController = companyCodeView;
        }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    
    [[Harpy sharedInstance] setDelegate:self];
    
    [[Harpy sharedInstance] setDebugEnabled:YES];
    
    [[Harpy sharedInstance] setAppID:@"1191713834"];
    
    [[Harpy sharedInstance] setAlertControllerTintColor:[UIColor blueColor]];
    
    [[Harpy sharedInstance] setAppName:@"ZenGo"];
    
    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeOption];
    
    [[Harpy sharedInstance] checkVersion];

    return YES; 
}
-(void)showAlert:(BOOL)isDevOffline
{
    if(isDevOffline){
        if(!isOffline){
    offlineAlertView = [[UIAlertView alloc] initWithTitle:@"Device Offline" message:@"Device Not Connected To Internet!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    offlineAlertView.tag = 333;
    [offlineAlertView show];
    isOffline = TRUE;
       }
    }
    else
    {
        if(!isServerDown){
        serverDownAlert = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                     message:@"Error Connecting to Server!"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        serverDownAlert.tag = 444;
//        [serverDownAlert show];
        isServerDown = TRUE;
        }
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if(alertView.tag == 333)
        {
            isOffline = FALSE;
        }
        else if(alertView.tag == 444)
        {
            isServerDown = FALSE;
        }
    }
}
-(void)downloadConfig:(NSString *)code
{
    NSString *userName_config = @"pm1";
    NSString *password=@"iopex@!23";
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName_config, @"username", password, @"password", nil];
    NSMutableDictionary *code_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code",nil];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSData* config_json2 = [NSJSONSerialization dataWithJSONObject:code_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *newStr4 = [[NSString alloc] initWithData:config_json2 encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@", newStr2, newStr4];
    NSData* finalJson = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request_config = [[NSMutableURLRequest alloc] init];
    [request_config setURL:[NSURL URLWithString: @"http://182.72.184.213:8081/query?dbname=safetrexMeteor&colname=companyConfig"]];
    [request_config setHTTPMethod:@"POST"];
    [request_config setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request_config setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request_config setHTTPBody:finalJson];
    NSURLConnection *connection_config = [[NSURLConnection alloc] initWithRequest:request_config delegate:self];
    [connection_config start];
}
-(void)updateLocation
{
    self.locationManager = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    self.locationManager.distanceFilter=kCLDistanceFilterNone;
    if(![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"denied");
        [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"latitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"longitude"];
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        NSString *title;
        title = @"Location Services Not Enabled!";
        NSString *message = @"Please  Turn On Location Services In The Location Services Settings";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
//        [alertView show];
    }
    else
    {
        [self requestAlwaysAuthorization];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
            [self.locationManager requestWhenInUseAuthorization];
            }
    [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"longitude"];
}
- (void)requestAlwaysAuthorization
{
   CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (&UIApplicationOpenSettingsURLString != NULL){
         if (status == kCLAuthorizationStatusDenied) {
             [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"latitude"];
             [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"longitude"];
             NSString *title;
             title = @"Location Services Not Enabled!";
            NSString *message = @"Please  Turn On Location Services In The Location Services Settings";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
//            [alertView show];
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    else
    {
        if (status == kCLAuthorizationStatusDenied) {
            [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"latitude"];
            [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"longitude"];
            NSString *title;
            title = @"Location Services Not Enabled!";
            NSString *message = @"Please  Turn On Location Services In The Location Services Settings";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
//            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}
-(void)stopUpdateLocation
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [self connectToFcm];
    [[Harpy sharedInstance] checkVersionDaily];
    
    [self.locationManager startUpdatingLocation];
//    int unacknowledgedNotifs = application.applicationIconBadgeNumber;
//    
//    if(unacknowledgedNotifs > 0)
//    {
////        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
//    }
    //do something about it...
    
    //You might want to reset the count afterwards:
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSLog(@"");
    NSLog(@"became active");
}

- (void) checkLocalNotifications:(UIApplication *) application
{
    UIApplication*  app        = [UIApplication sharedApplication];
    NSArray*        eventArray = [app scheduledLocalNotifications];
    
    for (int i = 0; i < [eventArray count]; i++)
    {
        UILocalNotification* notification = [eventArray objectAtIndex:i];
        NSDictionary *userInfo = notification.userInfo;
        if ([@"Feedback" isEqualToString:[userInfo objectForKey:@"isFeedbackNotification"]]){
            NSString *tripID = [userInfo objectForKey:@"LastTripId"];
            [[NSUserDefaults standardUserDefaults] setObject:tripID forKey:@"LastTripId"];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
            //CheckFeedbackViewController *CheckFeedback = [[CheckFeedbackViewController alloc] init];
            //[CheckFeedback downloadConfig];
        }
  
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* deviceTokenStr = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""] ;
    NSLog(@"Device_Token     -----> %@\n",deviceTokenStr);
    NSLog(@"%@",[deviceToken description]);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"success"];
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
                                        type:FIRInstanceIDAPNSTokenTypeProd];
    
}
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    if([userInfo[@"aps"][@"content-available"] intValue]== 1) //it's the silent notification
//    {
//        for (id key in userInfo) {
//            NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
//        }
//        completionHandler(UIBackgroundFetchResultNewData);
//        return;
//    }
//    else
//    {
//        completionHandler(UIBackgroundFetchResultNoData);
//        return;
//    }
//}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    float latitude = self.locationManager.location.coordinate.latitude;
    float longitude = self.locationManager.location.coordinate.longitude;
//    NSLog(@"update locations ---->%f %f",latitude,longitude);
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:@"longitude"];
}
-(IBAction)dismiss_delegate:(id)sender
{
    [self stopUpdateLocation];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"feedbackRequired"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"loginAlready"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [rootViewController_delegate dismiss];
    [self.window setRootViewController:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Company Code" message:@"Please enter your Company Code" delegate:self cancelButtonTitle:@"Submit" otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 989;
    companyCodeViewController *companyCodeView = [[companyCodeViewController alloc]init];
    self.window.rootViewController = companyCodeView;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    NSLog(@"Received Remote Push Notification");
    NSLog(@"userinfo %@",userInfo);
    if([userInfo[@"aps"][@"content-available"] intValue]== 1) //it's the silent notification
    {
        for (id key in userInfo) {
            NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        }
    }
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    UIApplicationState state = [application applicationState];
    
//    NSLog(@"didreceive");
//    NSDictionary *userInfo = notification.userInfo;
//    if ([@"Feedback" isEqualToString:[userInfo objectForKey:@"isFeedbackNotification"]]){
//        NSString *tripID = [userInfo objectForKey:@"LastTripId"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"addFeedback" object:nil];
//        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
//        [[NSUserDefaults standardUserDefaults] setObject:tripID forKey:@"LastTripId"];
//        //CheckFeedbackViewController *CheckFeedback = [[CheckFeedbackViewController alloc] init];
//        //[CheckFeedback downloadConfig];
//    }
    application.applicationIconBadgeNumber = 0;

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received----%@",newStr);
    id config_array= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([config_array isKindOfClass:[NSDictionary class]]){
        if([config_array objectForKey:@"status"]){
            NSLog(@"no config data");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"Please enter a valid Company Code" delegate:self cancelButtonTitle:@"Submit" otherButtonTitles:nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertView.tag = 989;
            [alertView show];
        }
    }
    else
    {
        for (NSDictionary *config in config_array) {
            if(config[@"gcmConfig"]){
                NSDictionary *dictionary = config[@"gcmConfig"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"host"] forKey:@"gcmHost"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"port"] forKey:@"gcmPort"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"scheme"] forKey:@"gcmScheme"];
            }
            if(config[@"mongoConfig"]){
                NSDictionary *dictionary = config[@"mongoConfig"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"host"] forKey:@"mongoHost"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"port"] forKey:@"mongoPort"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"scheme"] forKey:@"mongoScheme"];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"dbName"] forKey:@"mongoDbName"];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Error %@",error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            NSLog(@" locationss in the names %@",[placemark locality]);
        }
    }];
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    //    completionHandler(UNNotificationPresentationOptionAlert);
}

//- (void)application:(UIApplication *)application
//didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    
//    NSLog(@"Notification received: %@", userInfo);
//    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
//    {
//        //opened from a push notification when the app was on background
//    }
//}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"Notification received: %@", userInfo);
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
        return;
    }
    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        handler( UIBackgroundFetchResultNewData );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        NSLog( @"BACKGROUND" );
        handler( UIBackgroundFetchResultNewData );
    }
    else
    {
        NSLog( @"FOREGROUND" );
        handler( UIBackgroundFetchResultNewData );
    }
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    NSLog(@"%@", userInfo);
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        completionHandler( UNNotificationPresentationOptionAlert );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        NSLog( @"BACKGROUND" );
        completionHandler( UNNotificationPresentationOptionAlert );
    }
    else
    {
        NSLog( @"FOREGROUND" );
        completionHandler( UNNotificationPresentationOptionAlert );
    }
}
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    [[NSUserDefaults standardUserDefaults] setValue:refreshedToken forKey:@"GCMToken"];
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"%@", [remoteMessage appData]);
    NSDictionary *appData = [remoteMessage appData];
    if ([[appData valueForKey:@"syncdata"] isEqualToString:@"true"]){
        NSLog(@"called");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
        {
    
        NSString *idToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
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
        NSLog(@"%@",postDictionary);
        
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
        id jsonResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",jsonResult);
            if ([jsonResult isKindOfClass:[NSArray class]]){
                NSArray *array = jsonResult;
                tripSummaryViewController *tripSummery = [[tripSummaryViewController alloc]init];
                [tripSummery getSyncTripsFromFCM:array];
            }else{
                
            }
        });
    }else{
        NSLog(@"not called");
    }
}

@end
