//
//  EmpSchedule.m
//  Safetrax
//
//  Created by Kumaran on 12/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "EmpSchedule.h"
#import <MBProgressHUD.h>

NSString *previousDay;
NSInteger isAttending =0;
NSString *currentDate;
NSString *login;
NSString *date;
NSString *logout;
@implementation EmpSchedule
- (id) init:(HomeViewController *)home {
    self = [super init];
    if(self) {
        homeObject = home;
        [self restCall];
    }
    return self;
}

- (void)viewDidLoad
{
    _responseData = [[NSMutableData alloc] init];
}
-(void)restCall
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"scheduleVisibility"]){
        NSString *urlInString;
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        if([Port isEqualToString:@"-1"])
        {
            urlInString =[NSString stringWithFormat:@"%@://%@/getRosteringData?requestType=rosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
        }
        else
        {
            urlInString =[NSString stringWithFormat:@"%@://%@:%@/getRosteringData?requestType=rosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
        }
        
        NSURL *scheduleURL = [NSURL URLWithString:urlInString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:scheduleURL];
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
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [NSDate date];
        NSString *dateInStringForWeb = [formatter stringFromDate:date];
        NSDate *resultDate = [formatter dateFromString:dateInStringForWeb];
        
        long double today = [resultDate timeIntervalSince1970];
        NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
        long double mine = [str1 doubleValue]*1000;
        NSDecimalNumber *fromDate = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
        
        NSDictionary *bodyDict = @{@"employeeId":userid,@"startDate":[fromDate stringValue],@"endDate":[fromDate stringValue]};
        NSLog(@"%@",bodyDict);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
        id json = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
        NSLog(@"%@",json);
        if ([json isKindOfClass:[NSArray class]]){
            if ([json count] == 0){
                login = @"NA";
                logout = @"NA";
                [homeObject empAttendance];
            }else{
                [self fetchedAttendance:json];
            }
        }else{
            login = @"NA";
            logout = @"NA";
            [homeObject empAttendance];
        }
    }else{
        login = @"";
        logout = @"";
        [homeObject empAttendance];
    }
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
}
-(NSString *)getLogin
{
    return login;
}
-(NSString *)getLogout
{
    return logout;
}
-(NSString *)getScheduleDate
{
    return date;
}
-(NSInteger)isAttending
{
    NSLog(@"isattending %ld",(long)isAttending);
    return isAttending;
}
-(void)onFailure
{
    NSLog(@"no  data found");
    login =@"OFF";
    logout  =@"OFF";
    [homeObject empAttendance];
}
-(void)onConnectionFailure
{
    NSLog(@"no  data found");
    login =@"OFF";
    logout  =@"OFF";
    [homeObject empAttendance];
    NSLog(@"Connection Failure callback emp");
}
-(void)onFinishLoading
{
    
}
-(void)fetchedAttendance:(id)info_array
{
    if ([info_array count] == 2){
        for (NSDictionary *eachBand in info_array){
            if ([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"login"] boolValue]){
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"HH:mm"];
                NSLog(@"%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]]);
                login = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]];
            }else{
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"HH:mm"];
                NSLog(@"%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]]);
                logout = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]];
            }
        }
    }else{
        NSDictionary *eachBand = [info_array firstObject];
        if ([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"login"] boolValue]){
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"HH:mm"];
            NSLog(@"%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]]);
            login = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]];
            logout = @"NA";
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"HH:mm"];
            NSLog(@"%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]]);
            logout = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([[[eachBand objectForKey:@"deploymentBand"] valueForKey:@"time"] doubleValue]/1000)]];
            login = @"NA";
        }
    }
    
    [homeObject empAttendance];
}
@end
