//
//  EmpSchedule.h
//  Safetrax
//
//  Created by Kumaran on 12/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestClientTask.h"
#import "HomeViewController.h"
@interface EmpSchedule : NSObject<RestCallBackDelegate>
{
    NSMutableData *_responseData;
    HomeViewController *homeObject;
}
-(NSString *)getLogin;
-(NSString *)getLogout;
-(NSString *)getScheduleDate;
-(NSInteger)isAttending;
- (id) init:(HomeViewController *)home;
@end
