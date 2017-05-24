//
//  LoginViewController.m
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//
#import "ForcePasswordViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MFSideMenu.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "GCMRequest.h"
#import "RestClientTask.h"
#import "HeadBundlerClass.h"
#import "SessionValidator.h"
#import "MenuViewControllerParent.h"
#import "MyChildrenViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <Smooch/Smooch.h>
#import <MBProgressHUD.h>
#import <FirebaseInstanceID/FirebaseInstanceID.h>

#if Parent
#import "LoginHelpViewController.h"
#endif

UIActivityIndicatorView *spinner;
extern MFSideMenuContainerViewController *rootViewControllerParent_delegate;
@interface LoginViewController ()
@end
@implementation LoginViewController
{
    CLLocationManager *LocationManager;
    CLGeocoder *geoCoder;
    CLPlacemark *placemark;
}
@synthesize responseData,userName,password,invalidCredentials,userNameSeparator,passwordSeparator,loginButton,LoginHelpButton;
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
    NSLog(@"string %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"feedbackRequired"]);
#if Parent
    LoginHelpButton.hidden = NO;
#endif
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    userName.autocorrectionType = UITextAutocorrectionTypeNo;
    //    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [password setDelegate:self];
    [userName setDelegate:self];
    [invalidCredentials setHidden:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [super viewDidLoad];
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}
-(void)dismissKeyboard {
    [password resignFirstResponder];
    [userName resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}
#if Parent
-(IBAction)LoginHelp:(id)sender
{
    LoginHelpViewController *SchoolCodeFaq = [[LoginHelpViewController alloc] initWithNibName:@"LoginHelpViewController" bundle:nil];
    [self presentViewController:SchoolCodeFaq animated:YES completion:nil];
    
}
#endif
-(IBAction)login:(id)sender
{
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = spinner.frame;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = 100;
    spinner.frame = frame;
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    loginButton.enabled = NO;
    userNameSeparator.backgroundColor = [UIColor lightGrayColor];
    passwordSeparator.backgroundColor = [UIColor lightGrayColor];
    [invalidCredentials setHidden:YES];
    [spinner startAnimating];
    [self methodForGettingHeaders];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//protocol conformation for RestCallBack
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    NSDictionary *auth_dictionary= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([auth_dictionary objectForKey:@"email"]){
        CATransition* transition = [CATransition animation];
        transition.duration = 1;
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        [[NSUserDefaults standardUserDefaults] setObject:[userName.text lowercaseString] forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"emgcontact"] forKey:@"emgcontact"];
        [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary valueForKey:@""] forKey:@"phonenum"];
        [[NSUserDefaults standardUserDefaults] setObject:[self md5:password.text] forKey:@"password"];
        //    [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"empid"] forKey:@"empid"];
        //    [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"name"] forKey:@"name"];
#if Parent
        [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"imageLink"] forKey:@"imageLinkMainInfo"];
        [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"extras"] forKey:@"extras"];
#endif
        [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"email"] forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@",[auth_dictionary objectForKey:@"onetimepass"] );
        NSNumber *onetimepass = [auth_dictionary objectForKey:@"onetimepass"];
        NSLog(@"force change pass- %@",onetimepass);
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        if(onetimepass.intValue == 1){
            NSLog(@"force change pass");
            //        [self showChangePassowrd];
        }
        else
        {
#if Parent
            MyChildrenViewController *MyChildren = [[MyChildrenViewController alloc]init];
            MenuViewControllerParent *menu = [[MenuViewControllerParent alloc]init];
            rootViewControllerParent_delegate = [MFSideMenuContainerViewController
                                                 containerWithCenterViewController:MyChildren
                                                 leftMenuViewController:menu
                                                 rightMenuViewController:nil];
            
#else
            HomeViewController *home = [[HomeViewController alloc]init];
            MenuViewController *menu = [[MenuViewController alloc]init];
            rootViewControllerParent_delegate = [MFSideMenuContainerViewController
                                                 containerWithCenterViewController:home
                                                 leftMenuViewController:menu
                                                 rightMenuViewController:nil];
#endif
            [self presentViewController:rootViewControllerParent_delegate animated:NO completion:nil];
        }
    }
    else
    {
        NSLog(@"login failed");
        [invalidCredentials setText:@"Oops! Invalid Credentials"];
        [invalidCredentials setHidden:NO];
        userNameSeparator.backgroundColor = [UIColor redColor];
        passwordSeparator.backgroundColor = [UIColor redColor];
    }
    loginButton.enabled =  YES;
    [spinner stopAnimating];
}
-(void)showChangePassowrd
{
    ForcePasswordViewController *changePasswordView = [[ForcePasswordViewController alloc] initWithNibName:@"ForcePasswordViewController"  bundle:Nil];
    changePasswordView.modalPresentationStyle = UIModalPresentationFormSheet;
    changePasswordView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:changePasswordView animated:YES completion:nil];
}
-(void)pushDeviceToken
{
}
-(void)onFailure
{
    NSLog(@"Failure callback");
    loginButton.enabled =  YES;
    [spinner stopAnimating];
}
-(void)onConnectionFailure
{
    NSLog(@"Connection Failure callback");
    loginButton.enabled =  YES;
    [spinner stopAnimating];
}
-(void)onFinishLoading
{
    NSLog(@"Connection finish loading");
}
-(void)methodForGettingHeaders{
    NSRequest = [[NSMutableURLRequest alloc] init];
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    if ([Port isEqualToString:@"-1"]){
        [NSRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/auth",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]]]];
    }else{
        [NSRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@/auth",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]]]];
    }
    [NSRequest setHTTPMethod:@"HEAD"];
    NSLog(@"%@",[NSRequest URL]);
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:NSRequest delegate:self];
    [connection start];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == mainConnection){
        NSLog(@"%@",response);
    }else if (connection == connectionForSchedules){
        NSLog(@"%@",response);
    }
    else{
        NSLog(@"response %@",response);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            NSDictionary *dictionary = [httpResponse allHeaderFields];
            HeadBundlerClass *head = [[HeadBundlerClass alloc]init];
            [head initWithHeaders:dictionary];
        }
        
        [self methodForGettingUserConfig];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    //only main connection will go to data another connection wont go to get data it will give only header files
    if (connection == mainConnection){
        NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *newData = [newStr dataUsingEncoding:NSUTF8StringEncoding];
        
        if (newStr == (id)[NSNull null] || newStr.length == 0){
            NSLog(@"received null responce");
        }
        [self OnDataReceivedForUserConfig:newData];
    }
    else if (connection == connectionForSchedules){
        schedulesArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
}
-(void)methodForGettingUserConfig{
    NSTimeInterval time = ([[NSDate date] timeIntervalSince1970]); // returned as a double
    long digits = (long)time; // this is the first 10 digits
    int decimalDigits = (int)(fmod(time, 1) * 1000); // this will get the 3 missing digits
    double timestamp = (digits * 1000) + decimalDigits;
    NSString *value = [NSString stringWithFormat:@"%f%@",timestamp,[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"]];
    NSString *cnonce = [self md5:value];
    NSString *another = [NSString stringWithFormat:@"%@:%@:%@:%@",[userName.text lowercaseString],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],password.text,cnonce];
    NSString *ha1 = [self md5:another];
    NSString *final = [NSString stringWithFormat:@"%@:%@",ha1,[[NSUserDefaults standardUserDefaults] stringForKey:@"headValue"]];
    NSString *request = [self md5:final];
    NSString *urlInString;
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    if ([Port isEqualToString:@"-1"]){
        urlInString = [NSString stringWithFormat:@"%@://%@/auth",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
    }else{
        urlInString = [NSString stringWithFormat:@"%@://%@:%@/auth",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
    }
    NSURL *mainUrl = [NSURL URLWithString:urlInString];
    NSMutableURLRequest *mainRequest = [NSMutableURLRequest requestWithURL:mainUrl];
    [mainRequest setHTTPMethod:@"POST"];
    [mainRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mainRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSString *allHeadString;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"externalAuth"]){
        allHeadString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@,%@=%@,%@=%@,%@=%@,%@=%@",@"oauth_username",[userName.text lowercaseString],@"oauth_nonce",[[NSUserDefaults standardUserDefaults] stringForKey:@"headValue"],@"oauth_cnonce",cnonce,@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_version",@"1.0",@"oauth_request",request,@"oauth_password",password.text];
    }else{
        allHeadString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@,%@=%@,%@=%@,%@=%@",@"oauth_username",[userName.text lowercaseString],@"oauth_nonce",[[NSUserDefaults standardUserDefaults] stringForKey:@"headValue"],@"oauth_cnonce",cnonce,@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_version",@"1.0",@"oauth_request",request];
    }
    NSString *dataSetInfore = [NSString stringWithFormat:@"%@ %@",@"OAuth",allHeadString];
    [mainRequest setValue:dataSetInfore forHTTPHeaderField:@"Authorization"];
    mainConnection = [[NSURLConnection alloc] initWithRequest:mainRequest delegate:self];
    [mainConnection start];
}
-(void)getHeadBundlerValue:(NSString *)bundlerValue;
{
    [[NSUserDefaults standardUserDefaults] setObject:bundlerValue forKey:@"headValue"];
}
-(void)OnDataReceivedForUserConfig:(NSData *)userConfigData{
    NSError *error;
    
    NSDictionary *userConfigDictionary = [NSJSONSerialization JSONObjectWithData:userConfigData options:kNilOptions error:&error];
    NSLog(@"%@",userConfigDictionary);
    
    if (userConfigDictionary != nil){
        
        if ([userConfigDictionary valueForKey:@"accessToken"]){
            
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/global"];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
            double expireTime = [[userConfigDictionary valueForKey:@"expiresAt"] doubleValue];
            NSTimeInterval seconds = expireTime / 1000;
            NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
            NSLog(@"%@",[dateFormat stringFromDate:expireDate]);
            
            //        NSDate *date = [NSDate date];
            //        NSComparisonResult result = [date compare:expireDate];
            //        if(result == NSOrderedDescending)
            //        {
            //            SessionValidator *validator = [[SessionValidator alloc]init];
            //            [validator validateAccessToken:[userConfigDictionary valueForKey:@"accessToken"]];
            //        }
            //        else if(result == NSOrderedAscending)
            //        {
            [[NSUserDefaults standardUserDefaults] setObject:[userConfigDictionary valueForKey:@"accessToken"] forKey:@"userAccessToken"];
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"]);
            [[NSUserDefaults standardUserDefaults] setObject:[userConfigDictionary valueForKey:@"expiresAt"] forKey:@"expiredTime"];
            //        }
            //        else
            //        {
            //            SessionValidator *validator = [[SessionValidator alloc]init];
            //            [validator validateAccessToken:[userConfigDictionary valueForKey:@"accessToken"]];
            //        }
            
            [SKTUser currentUser].firstName = [[userConfigDictionary objectForKey:@"userInfo"] objectForKey:@"fullName"];
            [SKTUser currentUser].email = [[userConfigDictionary valueForKey:@"userInfo"]valueForKey:@"email"];
            [[SKTUser currentUser] addProperties:@{[[NSUserDefaults standardUserDefaults] valueForKey:@"company"]:@"Company"}];
            
            [[NSUserDefaults standardUserDefaults] setObject:[self md5:password.text] forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary objectForKey:@"userInfo"] objectForKey:@"fullName"] forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary objectForKey:@"userInfo"] objectForKey:@"fullName"] forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary objectForKey:@"userInfo"] objectForKey:@"userId"] forKey:@"empid"];
            [[NSUserDefaults standardUserDefaults] setObject:[[[userConfigDictionary valueForKey:@"userInfo"] valueForKey:@"_referenceId"] valueForKey:@"$oid"] forKey:@"employeeId"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary valueForKey:@"userInfo"] valueForKey:@"imageLink"] forKey:@"userImageUrl"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary valueForKey:@"userInfo"] valueForKey:@"mobile"] forKey:@"phonenum"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary valueForKey:@"userInfo"]valueForKey:@"email"] forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userConfigDictionary valueForKey:@"userInfo"]valueForKey:@"_officeId"] forKey:@"officeId"];
            loginButton.enabled =  YES;
            [spinner stopAnimating];
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/global"];
            if ([[userConfigDictionary objectForKey:@"isOneTimePass"] boolValue] ){
                [self showChangePassowrd];
            }
            else{
                HomeViewController *home = [[HomeViewController alloc]init];
                MenuViewController *menu = [[MenuViewController alloc]init];
                rootViewControllerParent_delegate = [MFSideMenuContainerViewController
                                                     containerWithCenterViewController:home
                                                     leftMenuViewController:menu
                                                     rightMenuViewController:nil];
                rootViewControllerParent_delegate.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                rootViewControllerParent_delegate.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:rootViewControllerParent_delegate animated:YES completion:nil];
            }
        }
        else{
            
            NSLog(@"login failed");
            [invalidCredentials setText:@"Oops! Invalid Credentials"];
            [invalidCredentials setHidden:NO];
            userNameSeparator.backgroundColor = [UIColor redColor];
            passwordSeparator.backgroundColor = [UIColor redColor];
            loginButton.enabled =  YES;
            [spinner stopAnimating];
        }
    }else{
        [self methodForGettingUserConfig];
    }
    
}
-(IBAction)forgotPassword:(id)sender{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Please enter your Id" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av textFieldAtIndex:0].placeholder = @"UserId";
    [av show];
    av.tag = 123456;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0);  // after animation
{
    if (alertView.tag == 123456){
        if (buttonIndex == 1){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *userid = [alertView textFieldAtIndex:0].text;
                    NSLog(@"%@",userid);
                    NSString *urlInString;
                    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                    if ([Port isEqualToString:@"-1"]){
                        urlInString = [NSString stringWithFormat:@"%@://%@/auth?type=reset_password&siteUrl=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                    }else{
                        urlInString = [NSString stringWithFormat:@"%@://%@:%@/auth?type=reset_password&siteUrl=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                    }
                    NSURL *mainUrl = [NSURL URLWithString:urlInString];
                    NSMutableURLRequest *mainRequest = [NSMutableURLRequest requestWithURL:mainUrl];
                    [mainRequest setHTTPMethod:@"POST"];
                    [mainRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [mainRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                    NSString *allHeadString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_username",userid,@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"]];
                    NSString *dataSetInfore = [NSString stringWithFormat:@"%@ %@",@"OAuth",allHeadString];
                    [mainRequest setValue:dataSetInfore forHTTPHeaderField:@"Authorization"];
                    NSError *error;
                    NSLog(@"%@",mainRequest.allHTTPHeaderFields);
                    NSLog(@"%@",mainUrl);
                    NSHTTPURLResponse *response;
                    NSData *resultData = [NSURLConnection sendSynchronousRequest:mainRequest returningResponse:&response error:&error];
                    NSLog(@"%@",response);
                    id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error];
                    NSLog(@"%@",result);
                    NSHTTPURLResponse *resultResponse = (NSHTTPURLResponse *)response;
                    if ([resultResponse statusCode] == 200){
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Email sent successfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"No records found for this Id" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
        }
    }
    
}
@end
