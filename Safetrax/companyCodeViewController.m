//
//  companyCodeViewController.m
//  Safetrax
//
//  Created by Kumaran on 03/04/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "companyCodeViewController.h"
#import "LoginViewController.h"
#if Parent
#import "SchoolCodeFAQViewController.h"
#endif

@interface companyCodeViewController ()
@end
UIActivityIndicatorView *spinnerIndicator;
@implementation companyCodeViewController
@synthesize companyCodeText,nextButton,HelpTextButton;
- (void)viewDidLoad {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [super viewDidLoad];
    [companyCodeText setDelegate:self];
#if Parent
    companyCodeText.placeholder = @"Enter School Code";
    HelpTextButton.hidden = NO;
#endif
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    return ([response statusCode]==200)?YES:NO;
}
-(void)dismissKeyboard {
    [companyCodeText resignFirstResponder];
}
#if Parent
- (IBAction)SmoochHelp:(id)sender
{
    SchoolCodeFAQViewController *SchoolCodeFaq = [[SchoolCodeFAQViewController alloc] initWithNibName:@"SchoolCodeFAQViewController" bundle:nil];
    [self presentViewController:SchoolCodeFaq animated:YES completion:nil];
}
#endif
- (IBAction)nextClicked:(id)sender
{
    if([self connectedToInternet]){
        [companyCodeText resignFirstResponder];
        nextButton.enabled = FALSE;
        if([companyCodeText.text length] > 0){
            [self downloadConfig:[companyCodeText.text lowercaseString]];
             [[NSUserDefaults standardUserDefaults] setObject:[companyCodeText.text lowercaseString] forKey:@"companycode"];
            spinnerIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGRect frame = spinnerIndicator.frame;
            frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
            frame.origin.y = 100;
            spinnerIndicator.frame = frame;
            spinnerIndicator.hidesWhenStopped = YES;
            [self.view addSubview:spinnerIndicator];
            [spinnerIndicator startAnimating];
        }
        else
        {
            companyCodeText.text = @"";
            nextButton.enabled = TRUE;
           #if Parent
            companyCodeText.placeholder = @"Enter School Code";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid School Code" message:@"Please enter a Valid School Code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
          #else
            companyCodeText.placeholder = @"Enter Company Code";
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Company Code" message:@"Please enter a Valid Company Code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
          #endif
           
            [alertView show];
        }
   }
    else
    {
        nextButton.enabled = TRUE;
        [spinnerIndicator stopAnimating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device Offline" message:@"Device Not Connected To Internet!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}
-(void)downloadConfig:(NSString *)code
{
    NSString *userName_config = @"pm1";
    NSString *password=@"iopex@!23";
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName_config, @"username", password, @"password", nil];
    NSMutableDictionary *code_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code",@"commuter",@"type",nil];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSData* config_json2 = [NSJSONSerialization dataWithJSONObject:code_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *newStr4 = [[NSString alloc] initWithData:config_json2 encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@", newStr2, newStr4];
    NSData* finalJson = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request_config = [[NSMutableURLRequest alloc] init];
//    [request_config setURL:[NSURL URLWithString: @"https://raptor.safetrax.in/mongoser/query?dbname=safetraxZensar&colname=companyConfig"]];
    [request_config setURL:[NSURL URLWithString: @"https://raptor.safetrax.in/mongoser/query?dbname=safetrexMeteor&colname=companyConfig"]];

    [request_config setHTTPMethod:@"POST"];
    [request_config setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request_config setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request_config setHTTPBody:finalJson];
    NSLog(@"final json %@",str);
    NSURLConnection *connection_config = [[NSURLConnection alloc] initWithRequest:request_config delegate:self];
    [connection_config start];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [spinnerIndicator stopAnimating];
    nextButton.enabled = TRUE;
//    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"received----%@",newStr);
    id config_array= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@",config_array);
    if([config_array isKindOfClass:[NSDictionary class]]){
        if([config_array objectForKey:@"status"]){
            NSLog(@"no config data");
            companyCodeText.text = @"";
         #if Parent
            companyCodeText.placeholder = @"Enter School Code";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid School Code" message:@"Please enter a Valid School Code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         #else
            companyCodeText.placeholder = @"Enter Company Code";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Company Code" message:@"Please enter a Valid Company Code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         #endif
            [alertView show];
        }
    }
    else
    {
        for (NSDictionary *config in config_array) {
            [[NSUserDefaults standardUserDefaults] setValue:companyCodeText.text forKey:@"company"];
            [[NSUserDefaults standardUserDefaults] setObject:[config objectForKey:@"secretKey"] forKey:@"secretKey"];
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
            if(config[@"feedbackRequired"]){
          [[NSUserDefaults standardUserDefaults] setObject:config[@"feedbackRequired"] forKey:@"feedbackRequired"];

        }
            if (config[@"rosterEnabled"]){
                if ([[config valueForKey:@"rosterEnabled"]boolValue]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"rosterVisible"];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"rosterVisible"];
                }
            }

            NSNumber *scheduleBool = config[@"scheduleVisibility"];
            
            [[NSUserDefaults standardUserDefaults]setObject:scheduleBool forKey:@"scheduleVisibility"];
            
            
            NSNumber *externalPassword = config[@"externalAuth"];
            NSLog(@"%@",externalPassword);
            [[NSUserDefaults standardUserDefaults] setValue:externalPassword forKey:@"externalAuth"];
            
            
            NSNumber *callEnableBool = config[@"callEnabled"];
            [[NSUserDefaults standardUserDefaults] setObject:callEnableBool forKey:@"callEnabled"];
            
            NSNumber *callMaskEnableBool = config[@"callMask"];
            [[NSUserDefaults standardUserDefaults] setObject:callMaskEnableBool forKey:@"callMaskEnabled"];
            
            [[NSUserDefaults standardUserDefaults] setObject:config[@"supportToken"] forKey:@"supportToken"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        LoginViewController *login = [[LoginViewController alloc] init];
        [self presentViewController:login animated:YES completion:nil];
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
    nextButton.enabled = TRUE;
    [spinnerIndicator stopAnimating];
}
-(void)refreshCompanyConfig:(NSString *)companyCodeString;
{
    NSString *userName_config = @"pm1";
    NSString *password=@"iopex@!23";
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName_config, @"username", password, @"password", nil];
    NSMutableDictionary *code_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:companyCodeString, @"code",@"commuter",@"type",nil];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSData* config_json2 = [NSJSONSerialization dataWithJSONObject:code_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *newStr4 = [[NSString alloc] initWithData:config_json2 encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@", newStr2, newStr4];
    NSData* finalJson = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request_config = [[NSMutableURLRequest alloc] init];
    [request_config setURL:[NSURL URLWithString: @"https://raptor.safetrax.in/mongoser/query?dbname=safetrexMeteor&colname=companyConfig"]];
    [request_config setHTTPMethod:@"POST"];
    [request_config setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request_config setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request_config setHTTPBody:finalJson];
    NSLog(@"final json %@",str);
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request_config returningResponse:nil error:&error_config];
    
    id config_array= [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
    NSLog(@"%@",config_array);
    
    if([config_array isKindOfClass:[NSDictionary class]]){
        if([config_array objectForKey:@"status"]){
            NSLog(@"no config data");
        }
    }
    else
    {
        for (NSDictionary *config in config_array) {
            [[NSUserDefaults standardUserDefaults] setValue:companyCodeText.text forKey:@"company"];
            [[NSUserDefaults standardUserDefaults] setObject:[config objectForKey:@"secretKey"] forKey:@"secretKey"];
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
            if(config[@"feedbackRequired"]){
                [[NSUserDefaults standardUserDefaults] setObject:config[@"feedbackRequired"] forKey:@"feedbackRequired"];
                
            }
            
            NSNumber *scheduleBool = config[@"scheduleVisibility"];
            [[NSUserDefaults standardUserDefaults]setObject:scheduleBool forKey:@"scheduleVisibility"];
            
            if (config[@"rosterEnabled"]){
                if ([[config valueForKey:@"rosterEnabled"]boolValue]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"rosterVisible"];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"rosterVisible"];
                }
            }
            
            NSNumber *callEnableBool = config[@"callEnabled"];
            [[NSUserDefaults standardUserDefaults] setObject:callEnableBool forKey:@"callEnabled"];
            
            NSNumber *callMaskEnableBool = config[@"callMask"];
            [[NSUserDefaults standardUserDefaults] setObject:callMaskEnableBool forKey:@"callMaskEnabled"];
            
            NSNumber *externalPassword = config[@"externalAuth"];
            [[NSUserDefaults standardUserDefaults] setValue:externalPassword forKey:@"externalAuth"];

            
            if (config[@"callerId"]){
                [[NSUserDefaults standardUserDefaults] setValue:config[@"callerId"] forKey:@"callMaskNumber"];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
