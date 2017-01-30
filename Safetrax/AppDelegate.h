//
//  AppDelegate.h
//  Safetrax
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import "Harpy.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,UNUserNotificationCenterDelegate,FIRMessagingDelegate,HarpyDelegate>
{
    UIAlertView *offlineAlertView ;
    UIAlertView *serverDownAlert;
    BOOL isOffline;
    BOOL isServerDown;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSData* responseData;
@property (strong, nonatomic) CLLocationManager *locationManager;
-(void)updateLocation;
-(void)stopUpdateLocation;
-(IBAction)dismiss_delegate:(id)sender;
-(void)showAlert:(BOOL)isDevOffline;

@end;
