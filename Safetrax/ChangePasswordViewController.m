//
//  ChangePasswordViewController.m
//  Safetrax
//
//  Created by Kumaran on 06/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "SOSMainViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SOSMainViewController.h"
#import "SomeViewController.h"

extern NSArray *tripList;
CGRect PasswordkeyboardFrame;
@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize passwordFieldOld,passwordFieldOne,passwordFieldTwo,invalidCredentials,spinner;
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    passwordFieldOld.delegate = self;
    passwordFieldOne.delegate = self;
    passwordFieldTwo.delegate = self;
    [invalidCredentials setHidden:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)changePassword:(id)sender
{
    
    [invalidCredentials setHidden:YES];
    NSLog(@"%@",passwordFieldOld.text);
    NSString *oldPassword =[self md5:passwordFieldOld.text];
    if([oldPassword isEqualToString:[[NSUserDefaults standardUserDefaults]
                                     stringForKey:@"password"]])
    {
        if([passwordFieldOne.text length]>0 && [passwordFieldTwo.text length]>0){
            if([passwordFieldOne.text isEqualToString:passwordFieldTwo.text]){
                NSLog(@"Hurray! Password matches ");
                NSString *newPassword =[self md5:passwordFieldOne.text];
                if([newPassword isEqualToString:[[NSUserDefaults standardUserDefaults]
                                                 stringForKey:@"password"]])            {
                    NSLog(@"Oops!Same Passwords!");
                    invalidCredentials.textColor = [UIColor redColor];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"New Password Must Be Different Than The Old Password!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    passwordFieldOne.text = @"";
                    passwordFieldTwo.text = @"";
                    passwordFieldOld.text = @"";
                    passwordFieldOne.placeholder = @"New Password";
                    passwordFieldTwo.placeholder = @"Confirm Password";
                    passwordFieldOld.placeholder = @"Old Password";
                    return;
                }
                invalidCredentials.textColor = [UIColor greenColor];
                [invalidCredentials setText:@"Updating New Password!"];
                NSURL *mainUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@/auth?type=change_password",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]]];
                NSMutableURLRequest *mainRequest = [NSMutableURLRequest requestWithURL:mainUrl];
                [mainRequest setHTTPMethod:@"POST"];
                [mainRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [mainRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                NSString *headString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"],@"change_request",passwordFieldOne.text];
                [mainRequest setValue:[NSString stringWithFormat:@"%@ %@",@"OAuth",headString] forHTTPHeaderField:@"Authorization"];
                NSLog(@"%@",[mainRequest allHTTPHeaderFields]);
                NSURLConnection *connection = [NSURLConnection connectionWithRequest:mainRequest delegate:self];
                [connection start];
                spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                CGRect frame = spinner.frame;
                frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
                frame.origin.y = self.view.frame.size.height/2+40;
                spinner.frame = frame;
                spinner.hidesWhenStopped = YES;
                [self.view addSubview:spinner];
                [spinner startAnimating];
            }
            else
            {
                NSLog(@"Oops! Password does not match!");
                invalidCredentials.textColor = [UIColor redColor];
                [invalidCredentials setText:@"Oops! Password does not match!"];
                passwordFieldOne.text = @"";
                passwordFieldTwo.text = @"";
                passwordFieldOld.text = @"";
                passwordFieldOne.placeholder = @"New Password";
                passwordFieldTwo.placeholder = @"Confirm Password";
                passwordFieldOld.placeholder = @"Old Password";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Change"
                                                                message:@"Oops! Password does not match!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }else
        {
            NSLog(@"Password field can not be empty!");
            [invalidCredentials setText:@"Password field can not be empty!"];
            passwordFieldOne.text = @"";
            passwordFieldTwo.text = @"";
            passwordFieldOld.text = @"";
            passwordFieldOne.placeholder = @"New Password";
            passwordFieldTwo.placeholder = @"Confirm Password";
            passwordFieldOld.placeholder = @"Old Password";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Change"
                                                            message:@"Password field can not be empty!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    else{
        invalidCredentials.textColor = [UIColor redColor];
        [invalidCredentials setText:@"Incorrect Old Password!"];
        passwordFieldOne.text = @"";
        passwordFieldTwo.text = @"";
        passwordFieldOld.text = @"";
        passwordFieldOne.placeholder = @"New Password";
        passwordFieldTwo.placeholder = @"Confirm Password";
        passwordFieldOld.placeholder = @"Old Password";
        NSLog(@"Incorrect Old Password!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password"
                                                        message:@"Incorrect Old Password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
    [passwordFieldOne resignFirstResponder];
    [passwordFieldOld resignFirstResponder];
    [passwordFieldTwo resignFirstResponder];
}
-(void)dismissKeyboard {
    [passwordFieldOne resignFirstResponder];
    [passwordFieldOld resignFirstResponder];
    [passwordFieldTwo resignFirstResponder];
}
-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
-(IBAction)sos:(id)sender{
    SOSMainViewController *sosController;
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }
    [self presentViewController:sosController animated:YES completion:nil];
}
//-(void)keyboardOnScreen:(NSNotification *)notification
//{
//    NSDictionary *info  = notification.userInfo;
//    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
//    CGRect rawFrame      = [value CGRectValue];
//    PasswordkeyboardFrame = [self.view convertRect:rawFrame fromView:nil];
//}
//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    return YES;
//}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
//    [self.view endEditing:YES];
//    return YES;
//}
//- (void)keyboardDidShow:(NSNotification *)notification
//{
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        CGSize result = [[UIScreen mainScreen] bounds].size;
//        if(result.height == 480)
//        {
//            [self.view setFrame:CGRectMake(0,-100,self.view.frame.size.width,self.view.frame.size.height)];
//        }
//        if(result.height >= 568)
//        {
//            [self.view setFrame:CGRectMake(0,-60,self.view.frame.size.width,self.view.frame.size.height)];
//        }
//    }
//}
//-(void)keyboardDidHide:(NSNotification *)notification
//{
//    [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    
}
-(void)onFailure
{
    [spinner stopAnimating];
    NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
    [spinner stopAnimating];
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [spinner stopAnimating];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",jsonDict);
    if ([jsonDict valueForKey:@"accessToken"]){
        [[NSUserDefaults standardUserDefaults] setObject:[jsonDict valueForKey:@"accessToken"] forKey:@"userAccessToken"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Password Changed Successfully"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        NSLog(@"failing call back");
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2002){
        if (buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                SomeViewController *some = [[SomeViewController alloc]init];
                [self presentViewController:some animated:YES completion:nil];
            });
        }
    }
    
}
@end
