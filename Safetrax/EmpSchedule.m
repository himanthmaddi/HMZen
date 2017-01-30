//
//  EmpSchedule.m
//  Safetrax
//
//  Created by Kumaran on 12/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "EmpSchedule.h"
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
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    long double today = [[NSDate date] timeIntervalSince1970];
    long double yesterday = [[[NSDate date] dateByAddingTimeInterval: -86400] timeIntervalSince1970];
    NSString *tempString = [NSString stringWithFormat:@"%.Lf",today];
    NSString *tempString2 = [NSString stringWithFormat:@"%.Lf",yesterday];
    long double mine = [tempString doubleValue]*1000;
    long double mine2 = [tempString2 doubleValue]*1000;
    NSLog(@"%Lf",mine);
    NSLog(@"%Lf",mine2);
        NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
        NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
    NSLog(@"%@",todayTime);
        NSDecimalNumber *beforeDayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine2]];
    NSLog(@"%@",beforeDayTime);
        NSDictionary *postDictionary = @{@"_employeeId":[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"],@"date":@{@"$gte":beforeDayTime,@"$lte":todayTime}};
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    currentDate = [dateFormatter stringFromDate:currDate];

    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"query" withMethod:@"POST" andColumnName:@"employees.schedules"];
    [requestWraper setBody:postDictionary];
    [requestWraper setAuthString:finalAuthString];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    _responseData = [[NSMutableData alloc] init];
    [RestClient execute];
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
    NSLog(@"Connection finish loading empschedule");
    id info_array= [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    NSLog(@"%@",info_array);

    if([info_array isKindOfClass:[NSDictionary class]]){
        if([info_array objectForKey:@"status"]){
            NSLog(@"no data found");
            login =@"OFF";
            logout  =@"OFF";
            [homeObject empAttendance];
        }
    }
    else
    {
        [self fetchedAttendance:info_array];
    }
}
-(void)fetchedAttendance:(id ) info_array
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    NSLog(@"%@",info_array);
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HHmm";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    for (NSDictionary *info in info_array) {
        NSDateFormatter *dateFo = [[NSDateFormatter alloc]init];
        [dateFo setDateFormat:@"YYYY-MM-dd"];
        double currentDateInInfo = [[info objectForKey:@"date"] doubleValue];
        [[NSUserDefaults standardUserDefaults] setDouble:currentDateInInfo forKey:@"scheduleDate"];
        NSDate *presentDate = [NSDate dateWithTimeIntervalSince1970:(currentDateInInfo/1000.0)];
        date = [dateFo stringFromDate:presentDate];
//        date =[info objectForKey:@"date"];
        if([date isEqualToString:currentDate])
        {
            if([info objectForKey:@"isAttending"])
            {
                
                isAttending =[[info objectForKey:@"isAttending"] integerValue];
                
                if(isAttending  == 0)
                {
                    isAttending = 0;
                }
            }
            else
            {
                isAttending = 0;
            }
            double loginTimr = [[info objectForKey:@"loginTime"] doubleValue];
            double logoutTimr = [[info objectForKey:@"logoutTime"] doubleValue];
            NSDate *logInDate = [NSDate dateWithTimeIntervalSince1970:(loginTimr/1000.0)];
            NSDate * logoutDate = [NSDate dateWithTimeIntervalSince1970:(logoutTimr/1000.0)];
            [dateFormat setDateFormat:@"hhmma"];
            NSString *loginStr = [dateFormat stringFromDate:logInDate];
            NSString *logoutStr = [dateFormat stringFromDate:logoutDate];
//            NSString *loginStr =[[info objectForKey:@"newShiftStart"] substringWithRange:NSMakeRange(12,4)];
            login = loginStr;
            logout = logoutStr;
            int shiftTime = [loginStr intValue];
            int currentTime = [[dateFormatter stringFromDate:now] intValue];
            if((shiftTime - currentTime) > 600){
            }
            else{
                login = loginStr;
                logout = logoutStr;
//                login =[[info objectForKey:@"newShiftStart"]substringWithRange:NSMakeRange(12,4)];
                
               /* NSString *logintime = @"2016-02-09--2000";
                login = [logintime substringWithRange:NSMakeRange(12,4)];*/
                            }
        }
        else
        {
            login =@"OFF";
            logout = @"OFF";
            
        }
//        if( !([[info objectForKey:@"newShiftEnd"] isEqualToString:@"OFF"] && [[info objectForKey:@"date"] isEqualToString:currentDate] ))
//        {
//            if(!([[info objectForKey:@"newShiftEnd"] isEqualToString:@"OFF"]))
//            logout  =[[info objectForKey:@"newShiftEnd"] substringWithRange:NSMakeRange(12,4)];
//            /*{
//                NSString *logouttime = @"2016-02-10--0400";
//                logout = [logouttime substringWithRange:NSMakeRange(12,4)];
//            }*/
//        
//        }
//        else
//            logout = @"OFF";
        if([date isEqualToString:currentDate]){
        if([info objectForKey:@"isAttending"])
        {
            isAttending =[[info objectForKey:@"isAttending"] integerValue];
            if(isAttending  == 0)
            {
                isAttending = 0;
            }
        }
        else
            isAttending = 0;
        }
        if([date isEqualToString:previousDay])
        {
            login =@"OFF";
            logout  =@"OFF";
        }
    }
    NSLog(@"%@",logout);
    NSLog(@"%@",login);
    [homeObject empAttendance];
}
@end
