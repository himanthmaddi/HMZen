//
//  ScheduleViewController.h
//  Commuter
//
//  Created by Himanth Maddi on 19/12/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import "SOSMainViewController.h"

@interface ScheduleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    FXBlurView *infoView;
    SOSMainViewController *sosController;
    IBOutlet UIBarButtonItem *select;
    IBOutlet UIBarButtonItem *cancel;
    IBOutlet UIBarButtonItem *sideDrawer;
}

@property (weak , nonatomic) IBOutlet UIButton *sosMainButton;

-(IBAction)sos:(id)sender;

@property (nonatomic , strong) NSString *cutoffDay;
@property (nonatomic , strong) NSString *cutoffTime;
@property (nonatomic , strong) NSDate *cutoffDateAndTime;

//@property (nonatomic , assign) BOOL loginRivisionAllowed;
//@property (nonatomic , assign) BOOL logoutRivisionAllowed;

@property (nonatomic , assign) BOOL loginCancellationAllowed;
@property (nonatomic , assign) BOOL logoutCancellationAllowed;
@property (nonatomic , assign) BOOL loginCancellationCutoffTime;
@property (nonatomic , assign) BOOL logoutCancellationCutoffTime;

@property (nonatomic , strong) NSDictionary *cutOffModel;

@property (nonatomic , strong) NSMutableArray *allDatesArray;
@property (nonatomic , strong) NSMutableArray *loginTimesArray;
@property (nonatomic , strong) NSMutableArray *logoutTimesArray;
@property (nonatomic , strong) NSMutableArray *daysArray;
@property (nonatomic , strong) NSMutableArray *officeIdsArray;
@property (nonatomic , strong) NSMutableArray *officeNamesArray;
@property (nonatomic , strong) NSMutableArray *officeIdsFromRoster;
@property (nonatomic , strong) NSMutableArray *allOfficeIdsFromCells;
@property (nonatomic , strong) NSMutableArray *rosterLoginIdsArray;
@property (nonatomic , strong) NSMutableArray *rosterLogoutIdsArray;

@property (nonatomic , strong) NSMutableArray *loginDoubleValuesArray;
@property (nonatomic , strong) NSMutableArray *logoutDoubleValuesArray;

@property (nonatomic , strong) NSString *finalEmergencyDate;


@property (nonatomic , strong) IBOutlet UITableView *scheduleTableView;
@property (nonatomic , strong) IBOutlet UIButton    *selectButton;

-(void)getAllSchedule;
-(void)getAllOffices;
@end
