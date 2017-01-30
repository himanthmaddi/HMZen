//
//  AppDelegate.m
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//
#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "MFSideMenu.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "MenuViewControllerParent.h"
#import "LoginViewController.h"
#import "TripModel.h"
#import <GoogleMaps/GoogleMaps.h>
#import "companyCodeViewController.h"
#import "MyChildrenViewController.h"
#import <Smooch/Smooch.h>

BOOL isFromLogin = TRUE;
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
MFSideMenuContainerViewController *rootViewController_delegate;
@implementation AppDelegate
@synthesize responseData;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
        {
            [self updateLocation];
        }
    }
    UIRemoteNotificationType notificationTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (notificationTypes == UIRemoteNotificationTypeNone) {
        NSLog(@"notification denied");
    }
    BOOL isgranted;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        isgranted =  [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
#else
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types & UIRemoteNotificationTypeAlert)
    {
        isgranted = true;
    }
#endif
    NSLog(@"notification granted? %hhd",isgranted);
    isOffline = FALSE;
    [Crashlytics startWithAPIKey:@"5881ca3d437e8b95dd5fde3b605b97ad61959ddf"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#if Parent
    [GMSServices provideAPIKey:@"AIzaSyAqxAR0no2-2V7Gl2iyKsA_Bh08bDBAz08"];
#else
    [GMSServices provideAPIKey:@"AIzaSyAj0qQwpJXiEfDJoEgLaOD67v-n5j4FB78"];
#endif
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
            [application registerUserNotificationSettings:settings];
        }
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BOOL login = [userDefault boolForKey:@"login"];
    if (login){
        isFromLogin = FALSE;
#if Parent
        NSLog(@"parentttt");
        [Smooch initWithSettings:[SKTSettings settingsWithAppToken:@"1pbsslnn950rbdla9zdp82ged"]];
        [SKTUser currentUser].firstName = [[NSUserDefaults standardUserDefaults]
                                           stringForKey:@"name"];
        [SKTUser currentUser].email = [[NSUserDefaults standardUserDefaults]
                                       stringForKey:@"email"];
        SKTSettings* settings = [SKTSettings settingsWithAppToken:@"1pbsslnn950rbdla9zdp82ged"];
        settings.conversationAccentColor = [UIColor redColor];
        settings.conversationStatusBarStyle = UIStatusBarStyleLightContent;
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
        MyChildrenViewController *Mytrip = [[MyChildrenViewController alloc]init];
       // HomeViewController *home = [[HomeViewController alloc]init];
        MenuViewControllerParent *menu = [[MenuViewControllerParent alloc]init];
        rootViewController_delegate = [MFSideMenuContainerViewController
                                       containerWithCenterViewController:Mytrip
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
         [Smooch initWithSettings:[SKTSettings settingsWithAppToken:@"1pbsslnn950rbdla9zdp82ged"]];
        SKTSettings* settings = [SKTSettings settingsWithAppToken:@"1pbsslnn950rbdla9zdp82ged"];
        settings.conversationAccentColor = [UIColor redColor];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
        isFromLogin = TRUE;
        companyCodeViewController *companyCodeView = [[companyCodeViewController alloc]init];
        self.window.rootViewController = companyCodeView;
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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
            [serverDownAlert show];
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
        [self requestWhenInUseAuthorization];
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
- (void)requestWhenInUseAuthorization
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
    [self.locationManager startUpdatingLocation];
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
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:@"deviceToken"];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if([userInfo[@"aps"][@"content-available"] intValue]== 1) //it's the silent notification
    {
        for (id key in userInfo) {
            NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        }
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    }
    else
    {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    float latitude = self.locationManager.location.coordinate.latitude;
    float longitude = self.locationManager.location.coordinate.longitude;
    NSLog(@"update locations ---->%f %f",latitude,longitude);
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:@"longitude"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    NSString *tripid = [[NSUserDefaults standardUserDefaults] stringForKey:@"tripid"];
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSString *tripStatus =[NSString stringWithFormat:@"{\"empid\":\"%@\",\"tripID\":\"%@\",\"employeeCurrentLocation\":[%f,%f]}}",userid,tripid,latitude,longitude];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@", newStr2, tripStatus];
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"PUT" andColumnName:@"trackings"];
    [requestWraper setPostParamFromString:str];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient execute];
}
-(IBAction)dismiss_delegate:(id)sender
{
    [self stopUpdateLocation];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
    [rootViewController_delegate dismiss];
    [self.window setRootViewController:nil];
    self.window.backgroundColor = [UIColor whiteColor];
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
    

    NSLog(@"received local push");
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
@end
