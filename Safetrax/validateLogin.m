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
#import <FIRInstanceID.h>

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
//    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
//    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
//    NSString *queryString = [NSString stringWithFormat:@"gcmidreg?gcmid=%@&empid=%@",token,userid];
//    NSString *url =[NSString stringWithFormat:@"%@://%@:%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"],queryString];
//    NSURL *Url = [[NSURL alloc]initWithString:url];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
//    [request setHTTPMethod:@"GET"];
//    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
//    [connection start];
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
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *findParameters = @{@"empid":userid};
    NSData *data = [NSJSONSerialization dataWithJSONObject:findParameters options:kNilOptions error:&error_config];
    [request setHTTPBody:data];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
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
//    if([loginStatus_dictionary objectForKey:@"status"]){
//        NSString *value  = [loginStatus_dictionary objectForKey:@"status"];
//        if([value isEqualToString:@"valid"])
//        {
//            [homeObject didFinishvalidation];
//        }
//        else
//        {
//            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
//            [appDelegate dismiss_delegate:nil];
//            [homeObject didFinishvalidation];

//        }
        
//    }
    NSString *localFcmToken = [[FIRInstanceID instanceID]token];
    
    if ([status isKindOfClass:[NSArray class]]){
        NSArray *array = status;
        if (array.count == 1){
            for (NSDictionary *dict in array){
                NSString *dbFcmToken = [dict valueForKey:@"fcmtoken"];
                if ([localFcmToken isEqualToString:dbFcmToken]){
                    [homeObject didFinishvalidation];
                }else{
//                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
//                    [appDelegate dismiss_delegate:nil];
                    [homeObject didFinishvalidation];

                }
            }
        }else{
            [homeObject didFinishvalidation];
        }
    }else{
        [homeObject didFinishvalidation];
    }
}
@end
