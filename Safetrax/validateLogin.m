//
//  validateLogin.m
//  Safetrax
//
//  Created by Kumaran on 23/03/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "validateLogin.h"
#import "AppDelegate.h"
#import  "HomeViewController.h"
#import "MyChildrenViewController.h"
#import "MyTripParentViewController.h"
#import <FirebaseInstanceID/FirebaseInstanceID.h>
@implementation validateLogin
- (id) init {
    self = [super init];
    if(self) {
        
    }
    return self;
}
- (void)setDelegate:(id)newDelegate{
    homeObject = newDelegate;
    [self validate];
}
-(void)validate
{
    _responseData = [[NSMutableData alloc] init];
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
        url =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],@"query",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"fcmtokens"];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],@"query",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"fcmtokens"];
    }
    NSURL *URL =[NSURL URLWithString:url];
    NSLog(@"%@",URL);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL];
    [request setHTTPMethod:@"POST"];
    NSError *error_config;
    
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    NSString *headerString;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
    }else{
        headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    }
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *findParameters = @{@"empid":userid};
    NSData *data = [NSJSONSerialization dataWithJSONObject:findParameters options:kNilOptions error:&error_config];
    [request setHTTPBody:data];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
    if (resultData != nil){
        id status = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
        NSLog(@"%@",status);
        //        NSString *localFcmToken = [[FIRInstanceID instanceID]token];
        
        if ([status isKindOfClass:[NSArray class]]){
            NSArray *array = status;
            if (array.count == 1){
                for (NSDictionary *dict in array){
                    //                    NSString *dbFcmToken = [dict valueForKey:@"fcmtoken"];
                    if ([[dict valueForKey:@"app"] isEqualToString:@"iOS"]){
                    }else{
                        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                        [appDelegate dismiss_delegate:nil];
                        //                    [homeObject didFinishvalidation];
                        
                    }
                }
            }else{
                AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate dismiss_delegate:nil];
            }
        }else{
            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate dismiss_delegate:nil];
        }
    }else{
        
    }
    //    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    //    [connection start];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_responseData setLength:0];//Set your data to 0 to clear your buffer
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];//Append the download data..
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id status = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    NSLog(@"%@",status);
    NSString *localFcmToken = [[FIRInstanceID instanceID]token];
    
    if ([status isKindOfClass:[NSArray class]]){
        NSArray *array = status;
        if (array.count == 1){
            for (NSDictionary *dict in array){
                NSString *dbFcmToken = [dict valueForKey:@"fcmtoken"];
                if ([localFcmToken isEqualToString:dbFcmToken] && [[dict valueForKey:@"app"] isEqualToString:@"iOS"]){
                    [homeObject didFinishvalidation];
                }else{
                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate dismiss_delegate:nil];
                    //                    [homeObject didFinishvalidation];
                    
                }
            }
        }else{
            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate dismiss_delegate:nil];        }
    }else{
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate dismiss_delegate:nil];
    }
}
@end
