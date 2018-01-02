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
#import "SessionValidator.h"

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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        else if(result == NSOrderedAscending)
        {
        }
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
            if ([status isKindOfClass:[NSArray class]]){
                NSArray *array = status;
                if (array.count == 1){
                    for (NSDictionary *dict in array){
                        if ([[dict valueForKey:@"app"] isEqualToString:@"iOS"]){
                            
                        }else{
                            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                            [appDelegate dismiss_delegate:nil];
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                        }
                    }
                }else{

                }
            }else{

            }
        }else{
            
        }
    });


}

@end
