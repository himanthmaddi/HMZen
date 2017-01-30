//
//  LoginViewController.h
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "RestClientTask.h"
@interface LoginViewController : UIViewController <CLLocationManagerDelegate,RestCallBackDelegate,UITextFieldDelegate>
{
    NSMutableURLRequest *NSRequest;
    NSString *finalNonceString;
    NSURLConnection *mainConnection;
    NSURLConnection *connectionForSchedules;
    NSString *accessTokenString;
    NSArray *schedulesArray;
}

@property (nonatomic, retain) NSData* responseData;
@property (weak, nonatomic) IBOutlet UIView *passwordSeparator;
@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIView *userNameSeparator;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *New_Password;
@property (weak, nonatomic) IBOutlet UIButton *Change_Password;
@property (weak, nonatomic) IBOutlet UITextField *ReTypePassword;
@property (weak, nonatomic) IBOutlet UILabel *invalidCredentials;
@property (weak, nonatomic) IBOutlet UIButton *LoginHelpButton;
-(IBAction)login:(id)sender;
-(IBAction)LoginHelp:(id)sender;
-(void)userConfiguration:(NSDictionary *)detailDictionary;
-(void)getHeadBundlerValue:(NSString *)bundlerValue;
@end
