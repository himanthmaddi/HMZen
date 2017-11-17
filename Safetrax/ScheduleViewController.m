//
//  ScheduleViewController.m
//  Commuter
//
//  Created by Himanth Maddi on 19/12/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "ScheduleViewController.h"
#import "MFSideMenu.h"
#import "SosViewController.h"
#import "ScheduleTableViewCell.h"
#import "editViewController.h"
#import <MBProgressHUD.h>
#import "SomeViewController.h"
#import "SessionValidator.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SomeViewController.h"
#import "validateLogin.h"

extern NSArray *tripList;
@interface ScheduleViewController ()
{
    UIToolbar *toolBar;
    NSMutableArray *indexpathOfSelectedItemsInTableView;
    ScheduleTableViewCell *cell;
    UIRefreshControl *refreshControl;
}

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        validateLogin *validate = [[validateLogin alloc]init];
        [validate setDelegate:self];
    });
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
    double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
    NSTimeInterval seconds = expireTime / 1000;
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSLog(@"%f",expireTime);
    
    
    NSDate *date = [NSDate date];
    NSComparisonResult result = [date compare:expireDate];
    NSLog(@"%@",expireDate);
    if(result == NSOrderedDescending || result == NSOrderedSame)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
            for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
            [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate dismiss_delegate:nil];
            [self.view removeFromSuperview];
        }else{
            SessionValidator *validator = [[SessionValidator alloc]init];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                NSLog(@"%@",result);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"no refresh");
    }
    
    
    [self getCutoffs];
    
    //    _daysArray = [[NSMutableArray alloc]init];
    //
    //    [self getCutoffs];
    //    _allDatesArray = [self getWeekDays];
    //
    //    _officeIdsArray = [[NSMutableArray alloc]init];
    //    _officeNamesArray = [[NSMutableArray alloc]init];
    //
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //    for (int i=0;i<_allDatesArray.count;i++){
    //        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //        [formatter setDateFormat:@"dd\nEE"];
    //        NSDate *date = [dateFormatter dateFromString:[_allDatesArray objectAtIndex:i]];
    //        NSString *dayString = [formatter stringFromDate:date];
    //        [_daysArray addObject:dayString];
    //    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enabledSelection"];
    
    indexpathOfSelectedItemsInTableView = [[NSMutableArray alloc]init];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    //    _scheduleTableView.allowsSelectionDuringEditing = YES;
    //
    //    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    //
    //    UIBarButtonItem *editBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemAction:)];
    //
    //    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //
    //    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteBarButtonItemAction:)];
    //
    //    [toolBar setItems:[NSArray arrayWithObjects:editBarButtonItem,space,deleteBarButtonItem, nil]];
    //
    //    [self.view addSubview:toolBar];
    //
    //    toolBar.hidden = YES;
    
    //    refreshControl = [[UIRefreshControl alloc]init];
    //    [refreshControl addTarget:self action:@selector(handleRefreshControl) forControlEvents:UIControlEventValueChanged];
    //    _scheduleTableView.refreshControl = refreshControl;
    //    refreshControl.backgroundColor = [UIColor lightGrayColor];
    //    refreshControl.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self connectedToInternet]){
                if (indexPath.section == 0){
                    if ([[_allDatesArray objectAtIndex:0] isEqualToString:_finalEmergencyDate]){
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Schedule can not be edit after raised emergency logout. But you can raise emergency." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
                        editViewController *edit = [story instantiateViewControllerWithIdentifier:@"editViewController"];
                        
                        NSString *officeId = [_officeIdsFromRoster objectAtIndex:indexPath.section];
                        NSString *officeName;
                        if ([_officeIdsArray containsObject:officeId]){
                            int index = [_officeIdsArray indexOfObject:officeId];
                            officeName = [_officeNamesArray objectAtIndex:index];
                        }else{
                            officeName = @"NA";
                        }
                        NSLog(@"%@",_loginDoubleValuesArray);
                        
                        [edit getAllOfficeNames:_officeNamesArray withAllOfficeIds:_officeIdsArray];
                        
                        [edit getLoginTime:[_loginTimesArray objectAtIndex:indexPath.section] withLogoutTime:[_logoutTimesArray objectAtIndex:indexPath.section] withOffice:[_officeIdsFromRoster objectAtIndex:indexPath.section] withDate:[_allDatesArray objectAtIndex:indexPath.section] withOfficeName:officeName withCutoffDateAndTime:_cutoffDateAndTime];
                        
                        [edit getDoubleValuesForLogin:[_loginDoubleValuesArray objectAtIndex:indexPath.section] withLogout:[_logoutDoubleValuesArray objectAtIndex:indexPath.section]];
                        
                        [edit getCutoffsModel:_cutOffModel];
                        
                        [edit getLoginRosterId:[_rosterLoginIdsArray objectAtIndex:indexPath.section] withLogoutRosterId:[_rosterLogoutIdsArray objectAtIndex:indexPath.section]];
                        
                        [self.navigationController pushViewController:edit animated:YES];
                    }
                }else{
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
                    editViewController *edit = [story instantiateViewControllerWithIdentifier:@"editViewController"];
                    
                    NSString *officeId = [_officeIdsFromRoster objectAtIndex:indexPath.section];
                    NSString *officeName;
                    if ([_officeIdsArray containsObject:officeId]){
                        int index = [_officeIdsArray indexOfObject:officeId];
                        officeName = [_officeNamesArray objectAtIndex:index];
                    }else{
                        officeName = @"NA";
                    }
                    [edit getAllOfficeNames:_officeNamesArray withAllOfficeIds:_officeIdsArray];
                    
                    [edit getLoginTime:[_loginTimesArray objectAtIndex:indexPath.section] withLogoutTime:[_logoutTimesArray objectAtIndex:indexPath.section] withOffice:[_officeIdsFromRoster objectAtIndex:indexPath.section] withDate:[_allDatesArray objectAtIndex:indexPath.section] withOfficeName:officeName withCutoffDateAndTime:_cutoffDateAndTime];
                    
                    [edit getDoubleValuesForLogin:[_loginDoubleValuesArray objectAtIndex:indexPath.section] withLogout:[_logoutDoubleValuesArray objectAtIndex:indexPath.section]];
                    
                    [edit getCutoffsModel:_cutOffModel];
                    
                    [edit getLoginRosterId:[_rosterLoginIdsArray objectAtIndex:indexPath.section] withLogoutRosterId:[_rosterLogoutIdsArray objectAtIndex:indexPath.section]];
                    
                    
                    [self.navigationController pushViewController:edit animated:YES];
                }
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection problem" message:@"Please check your data connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}
-(void)editBarButtonItemAction:(UIBarButtonItem *)sender{
    
    NSLog(@"%@",[_scheduleTableView indexPathsForSelectedRows]);
    
    if ([_scheduleTableView indexPathsForSelectedRows]){
        NSMutableArray *datesSelected = [[NSMutableArray alloc]init];
        NSMutableArray *daysArray = [[NSMutableArray alloc]init];
        
        for (int i=0;i<[_scheduleTableView indexPathsForSelectedRows].count;i++){
            NSIndexPath *firstIndexPath = [[_scheduleTableView indexPathsForSelectedRows] objectAtIndex:i];
            NSUInteger row = firstIndexPath.section;
            [datesSelected addObject:[_allDatesArray objectAtIndex:row]];
        }
        NSLog(@"%@",datesSelected);
        for (NSString *dateString in datesSelected){
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [formatter dateFromString:dateString];
            [formatter setDateFormat:@"EEEE"];
            NSString *resultDay = [formatter stringFromDate:date];
            [daysArray addObject:resultDay];
        }
        NSLog(@"%@",daysArray);
        if ([daysArray containsObject:@"Sunday"] || [daysArray containsObject:@"Saturday"]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Please select either weekdays or weekends" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
            editViewController *edit = [story instantiateViewControllerWithIdentifier:@"editViewController"];
            [self.navigationController pushViewController:edit animated:YES];
        }
        
    }else{
        
    }
}
-(void)deleteBarButtonItemAction:(UIBarButtonItem *)sender{
    NSLog(@"%@",[_scheduleTableView indexPathsForSelectedRows]);
    if (_scheduleTableView.indexPathsForSelectedRows.count >0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure to delete selected schedules?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Schedule", nil];
        [alert show];
        alert.tag = 200;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.title = @"MY SCHEDULES";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosEnabled"]){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sosOnTrip"]){
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OneTripIsInActive"]){
                _sosMainButton.hidden = NO;
            }else{
                _sosMainButton.hidden = YES;
            }
        }else{
            _sosMainButton.hidden = NO;
        }
    }else{
        _sosMainButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"timeCompleted" object:nil];
    
    
    _scheduleTableView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    self.navigationItem.leftBarButtonItem = sideDrawer;
    //    self.navigationItem.rightBarButtonItem = select;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enabledSelection"];
    [_scheduleTableView setEditing:NO animated:YES];
    [self adjustNavigationItems];
    toolBar.hidden = YES;
    
    //    CGRect frame = _scheduleTableView.frame;
    //    _scheduleTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    
    _officeIdsArray = [[NSMutableArray alloc]init];
    _officeNamesArray = [[NSMutableArray alloc]init];
    
    _allDatesArray = [self getWeekDays];
    _daysArray = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    for (int i=0;i<_allDatesArray.count;i++){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd\nEE"];
        NSDate *date = [dateFormatter dateFromString:[_allDatesArray objectAtIndex:i]];
        NSString *dayString = [formatter stringFromDate:date];
        [_daysArray addObject:dayString];
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
            double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
            NSTimeInterval seconds = expireTime / 1000;
            NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
            
            NSDate *date = [NSDate date];
            NSComparisonResult result = [date compare:expireDate];
            
            if(result == NSOrderedDescending || result == NSOrderedSame)
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
                    for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
                    }
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
                    [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
                    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate dismiss_delegate:nil];
                    [self.view removeFromSuperview];
                }else{
                    SessionValidator *validator = [[SessionValidator alloc]init];
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                        NSLog(@"%@",result);
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }
            }
            else if(result == NSOrderedAscending)
            {
                NSLog(@"no refresh");
            }
            
            [self getAllSchedule];
            if (_officeNamesArray.count != 0){
            }else{
                [self getAllOffices];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}
-(void)viewDidAppear:(BOOL)animated{
}
//- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//{
//    NSIndexPath *path = [tableView indexPathForSelectedRow];
//
//    return nil;
//}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)menuStateEventOccurred:(NSNotification *)notification {
    //When menu is closed, make the blurred view dynamic again
    MFSideMenuStateEvent event = [[notification userInfo][@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose){
        infoView.dynamic = YES;
    }
}
-(IBAction)selectPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enabledSelection"];
    [_scheduleTableView setEditing:YES animated:YES];
    [self adjustNavigationItems];
    toolBar.hidden = NO;
    //    CGRect frame = _scheduleTableView.frame;
    //    _scheduleTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}
-(IBAction)openSettingsMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    infoView.dynamic = NO;
}
-(IBAction)cancelPressed:(id)sender{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enabledSelection"];
    [_scheduleTableView setEditing:NO animated:YES];
    [self adjustNavigationItems];
    toolBar.hidden = YES;
    //    CGRect frame = _scheduleTableView.frame;
    //    _scheduleTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
}

-(void)adjustNavigationItems{
    //    if (_scheduleTableView.editing)
    //    {
    //        // Show the option to cancel the edit.
    //        self.navigationItem.rightBarButtonItem = cancel;
    //
    //    }
    //    else
    //    {
    //        // Not in editing mode.
    //        self.navigationItem.rightBarButtonItem = select;
    //
    //    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allDatesArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ScheduleTableViewCell" owner:nil options:nil];
    for (id curentObject in topLevelObjects)
    {
        if ([curentObject isKindOfClass:[UITableViewCell class]])
        {
            cell = (ScheduleTableViewCell *)curentObject;
            
            
            UIButton *emergencyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            emergencyButton = [[UIButton alloc]init];
            [emergencyButton setImage:[self image:[UIImage imageNamed:@"siren copy.png"] scaledToSize:CGSizeMake(25, 25)] forState:UIControlStateNormal];
            [emergencyButton addTarget:self action:@selector(emergencyPressed:) forControlEvents:UIControlEventTouchUpInside];
            emergencyButton.frame = CGRectMake(0, 0, 50, 50);
            [emergencyButton sizeToFit];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"today"]){
                if (indexPath.section == 0){
                    NSLog(@"%@",_loginDoubleValuesArray);
                    if ([[_loginDoubleValuesArray objectAtIndex:0] isEqualToString:@"OFF"]){
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                            cell.accessoryView  = emergencyButton;
                        }else{
                            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        }
                    }else{
                        NSDate *loginDate = [NSDate dateWithTimeIntervalSince1970:([[_loginDoubleValuesArray objectAtIndex:0] doubleValue]/1000)];
                        if ([[NSDate date] compare:loginDate] == NSOrderedAscending){
                            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        }else{
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                cell.accessoryView  = emergencyButton;
                            }else{
                                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            }                        }
                    }
                }else{
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }else{
                NSString *loginForNextday = [_loginDoubleValuesArray objectAtIndex:1];
                if ([loginForNextday isEqualToString:@"OFF"]){
                    if (indexPath.section == 0){
                        if ([[_loginDoubleValuesArray objectAtIndex:0] isEqualToString:@"OFF"]){
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                cell.accessoryView  = emergencyButton;
                            }else{
                                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            }                        }else{
                                NSDate *loginDate = [NSDate dateWithTimeIntervalSince1970:([[_loginDoubleValuesArray objectAtIndex:0] doubleValue]/1000)];
                                if ([[NSDate date] compare:loginDate] == NSOrderedAscending){
                                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                }else{
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                        cell.accessoryView  = emergencyButton;
                                    }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }                            }
                            }
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                }else{
                    NSDate *loginDate = [NSDate dateWithTimeIntervalSince1970:([loginForNextday doubleValue]/1000)];
                    NSLog(@"%@",loginDate);
                    
                    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    [cal setTimeZone:[NSTimeZone systemTimeZone]];
                    
                    NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
                    
                    [comp setMinute:0];
                    [comp setHour:8];
                    
                    NSDate *eighthoursSdate = [cal dateFromComponents:comp];
                    NSLog(@"%@",eighthoursSdate);
                    
                    if ([loginDate compare:eighthoursSdate] == NSOrderedAscending){
                        if ([[_logoutDoubleValuesArray objectAtIndex:0] isEqualToString:@"OFF"]){
                            
                            if ([[NSDate date] compare:loginDate] == NSOrderedDescending){
                                if (indexPath.section == 1){
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                        cell.accessoryView  = emergencyButton;
                                    }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }                                }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }
                            }else{
                                if (indexPath.section == 0){
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                        cell.accessoryView  = emergencyButton;
                                    }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }
                                }else{
                                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                }
                            }
                        }else{
                            if ([[NSDate date] compare:loginDate] == NSOrderedDescending){
                                if (indexPath.section == 1){
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                        cell.accessoryView  = emergencyButton;
                                    }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }                                }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }
                            }else{
                                if (indexPath.section == 0){
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                        cell.accessoryView  = emergencyButton;
                                    }else{
                                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                    }
                                }else{
                                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                }
                            }
                        }
                    }else{
                        if (indexPath.section == 0){
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"emergencyButton"]){
                                cell.accessoryView  = emergencyButton;
                            }else{
                                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            }
                        }else{
                            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        }
                    }
                }
            }
            
            cell.dateLabel.text = [_daysArray objectAtIndex:indexPath.section];
            cell.dateLabel.numberOfLines = 2;
            cell.dateLabel.adjustsFontSizeToFitWidth = YES;
            cell.loginLabel.text = [NSString stringWithFormat:@"%@ %@",@"Login at",[_loginTimesArray objectAtIndex:indexPath.section]];
            cell.logoutLabel.text = [NSString stringWithFormat:@"%@ %@",@"Logout at",[_logoutTimesArray objectAtIndex:indexPath.section]];
            NSString *officeId = [_officeIdsFromRoster objectAtIndex:indexPath.section];
            
            cell.loginLabel.adjustsFontSizeToFitWidth = YES;
            cell.logoutLabel.adjustsFontSizeToFitWidth = YES;
            if ([_officeIdsArray containsObject:officeId]){
                int index = [_officeIdsArray indexOfObject:officeId];
                
                cell.officeLabel.text = [_officeNamesArray objectAtIndex:index];
                
            }else{
                cell.officeLabel.text = @"NA";
            }
        }
    }
    cell.backgroundColor = [UIColor colorWithRed:(220.0/255.0) green:(220.0/255.0) blue:(220.0/255.0) alpha:1.0];
    UITableViewCell *cell1 = [UITableViewCell new]; // or other instantiation...
    [cell1 setTintColor:[UIColor redColor]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section {
    
    return 6.0;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForFooterInSection:(NSInteger)section {
    return 5.0;
}

- (UIView*)tableView:(UITableView*)tableView
viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView*)tableView
viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)handleRefreshControl{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //        [self getAllSchedule];
    //        if (_officeNamesArray.count != 0){
    //        }else{
    //            [self getAllOffices];
    //        }
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [refreshControl endRefreshing];
    //        });
    //    });
    
}
-(void)getAllSchedule{
    
    if ([self connectedToInternet]){
        _loginTimesArray = [[NSMutableArray alloc]init];
        _logoutTimesArray = [[NSMutableArray alloc]init];
        _loginDoubleValuesArray = [[NSMutableArray alloc]init];
        _logoutDoubleValuesArray = [[NSMutableArray alloc]init];
        _officeIdsFromRoster = [[NSMutableArray alloc]init];
        _rosterLoginIdsArray = [[NSMutableArray alloc]init];
        _rosterLogoutIdsArray = [[NSMutableArray alloc]init];
        
        [_loginDoubleValuesArray removeAllObjects];
        [_logoutDoubleValuesArray removeAllObjects];
        
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
        }    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
        [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [[NSDate date] dateByAddingTimeInterval:(-24*60*60)];
        NSString *dateInStringForWeb = [formatter stringFromDate:date];
        NSDate *resultDate = [formatter dateFromString:dateInStringForWeb];
        
        long double today = [resultDate timeIntervalSince1970];
        NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
        long double mine = [str1 doubleValue]*1000;
        NSDecimalNumber *fromDate = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
        
        long double thatDay = [[resultDate dateByAddingTimeInterval:(15*24*60*60)] timeIntervalSince1970];
        NSString *str2 = [NSString stringWithFormat:@"%.Lf",thatDay];
        long double mine2 = [str2 doubleValue]*1000;
        NSDecimalNumber *toDate = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine2]];
        
        NSDictionary *bodyDict = @{@"employeeId":userid,@"startDate":[fromDate stringValue],@"endDate":[toDate stringValue]};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
        NSArray *resultArray;
        if (resultData != nil){
            id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
            if ([result isKindOfClass:[NSArray class]]){
                resultArray = result;
                
                for (int i=0;i<_allDatesArray.count;i++){
                    
                    NSMutableArray *datesCountArray = [[NSMutableArray alloc]init];
                    
                    NSString *dateStringFromAllDates = [_allDatesArray objectAtIndex:i];
                    
                    for (NSDictionary *eachBand in resultArray){
                        long double date = [[eachBand valueForKey:@"date"] doubleValue];
                        NSTimeInterval seconds = date/1000;
                        NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        NSString *dateinStringFromEachBand = [formatter stringFromDate:finalDate];
                        if ([dateStringFromAllDates isEqualToString:dateinStringFromEachBand]){
                            [datesCountArray addObject:eachBand];
                        }
                    }
                    if (datesCountArray.count == 2){
                        for (int i=0;i<datesCountArray.count;i++){
                            NSDictionary *eachBand = [datesCountArray objectAtIndex:i];
                            NSDictionary *deploymentBand = [eachBand valueForKey:@"deploymentBand"];
                            BOOL loginOrNot = [[deploymentBand valueForKey:@"login"] boolValue];
                            if (loginOrNot){
                                long double time = [[deploymentBand valueForKey:@"time"] doubleValue];
                                [_loginDoubleValuesArray addObject:[[deploymentBand valueForKey:@"time"] stringValue]];
                                NSTimeInterval seconds = time/1000;
                                NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                [formatter setDateFormat:@"dd MMMM HH:mm"];
                                NSString *dateInString = [formatter stringFromDate:finalDate];
                                [_loginTimesArray addObject:dateInString];
                                [_officeIdsFromRoster addObject:[deploymentBand valueForKey:@"_officeId"]];
                                [_rosterLoginIdsArray addObject:[[eachBand valueForKey:@"_id"] valueForKey:@"$oid"]];
                            }
                            if (!loginOrNot){
                                [_logoutDoubleValuesArray addObject:[[deploymentBand valueForKey:@"time"] stringValue]];
                                long double time = [[deploymentBand valueForKey:@"time"] doubleValue];
                                NSTimeInterval seconds = time/1000;
                                NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                [formatter setDateFormat:@"dd MMMM HH:mm"];
                                NSString *dateInString = [formatter stringFromDate:finalDate];
                                [_logoutTimesArray addObject:dateInString];
                                [_rosterLogoutIdsArray addObject:[[eachBand valueForKey:@"_id"] valueForKey:@"$oid"]];
                            }
                        }
                    }else if (datesCountArray.count == 1){
                        NSDictionary *eachBand = [datesCountArray objectAtIndex:0];
                        NSDictionary *deploymentBand = [eachBand valueForKey:@"deploymentBand"];
                        BOOL loginOrNot = [[deploymentBand valueForKey:@"login"] boolValue];
                        if (loginOrNot){
                            [_loginDoubleValuesArray addObject:[[deploymentBand valueForKey:@"time"] stringValue]];
                            [_logoutDoubleValuesArray addObject:@"OFF"];
                            long double time = [[deploymentBand valueForKey:@"time"] doubleValue];
                            NSTimeInterval seconds = time/1000;
                            NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                            [formatter setDateFormat:@"dd MMMM HH:mm"];
                            NSString *dateInString = [formatter stringFromDate:finalDate];
                            [_loginTimesArray addObject:dateInString];
                            [_logoutTimesArray addObject:@"OFF"];
                            [_rosterLoginIdsArray addObject:[[eachBand valueForKey:@"_id"] valueForKey:@"$oid"]];
                            [_rosterLogoutIdsArray addObject:@"OFF"];
                            [_officeIdsFromRoster addObject:[deploymentBand valueForKey:@"_officeId"]];
                        }
                        if (!loginOrNot){
                            [_logoutDoubleValuesArray addObject:[[deploymentBand valueForKey:@"time"] stringValue]];
                            [_loginDoubleValuesArray addObject:@"OFF"];
                            long double time = [[deploymentBand valueForKey:@"time"] doubleValue];
                            NSTimeInterval seconds = time/1000;
                            NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                            [formatter setDateFormat:@"dd MMMM HH:mm"];
                            NSString *dateInString = [formatter stringFromDate:finalDate];
                            [_logoutTimesArray addObject:dateInString];
                            [_loginTimesArray addObject:@"OFF"];
                            [_officeIdsFromRoster addObject:[deploymentBand valueForKey:@"_officeId"]];
                            [_rosterLogoutIdsArray addObject:[[eachBand valueForKey:@"_id"] valueForKey:@"$oid"]];
                            [_rosterLoginIdsArray addObject:@"OFF"];
                        }
                    }else{
                        [_rosterLoginIdsArray addObject:@"OFF"];
                        [_rosterLogoutIdsArray addObject:@"OFF"];
                        [_loginDoubleValuesArray addObject:@"OFF"];
                        [_logoutDoubleValuesArray addObject:@"OFF"];
                        [_loginTimesArray addObject:@"OFF"];
                        [_logoutTimesArray addObject:@"OFF"];
                        [_officeIdsFromRoster addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"officeId"]];
                    }
                }
            }
            
            
            
            
            NSDate* sourceDate = [NSDate date];
            NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
            NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
            NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
            NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
            NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
            NSLog(@"%@",destinationDate);
            
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [cal setTimeZone:[NSTimeZone systemTimeZone]];
            
            NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
            
            [comp setMinute:0];
            [comp setHour:8];
            
            NSDate *startOfToday = [cal dateFromComponents:comp];
            
            NSTimeZone* sourceTimeZone12 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            NSTimeZone* destinationTimeZone12 = [NSTimeZone systemTimeZone];
            NSInteger sourceGMTOffset12 = [sourceTimeZone12 secondsFromGMTForDate:startOfToday];
            NSInteger destinationGMTOffset12 = [destinationTimeZone12 secondsFromGMTForDate:startOfToday];
            NSTimeInterval interval12 = destinationGMTOffset12 - sourceGMTOffset12;
            NSDate* destinationDate12 = [[NSDate alloc] initWithTimeInterval:interval12 sinceDate:startOfToday];
            
            
            if ([destinationDate compare:destinationDate12] == NSOrderedAscending){
                NSString *nextdayLoginDoublrValue = [_loginDoubleValuesArray objectAtIndex:1];
                if ([nextdayLoginDoublrValue isEqualToString:@"OFF"]){
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"today"];
                }else{
                    NSDate *nextDayLoginDate = [NSDate dateWithTimeIntervalSince1970:([nextdayLoginDoublrValue doubleValue]/1000)];
                    if ([nextDayLoginDate compare:startOfToday] == NSOrderedAscending){
                        if ([[NSDate date] compare:nextDayLoginDate] == NSOrderedAscending){
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"today"];
                        }else{
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"today"];
                            [_allDatesArray removeObjectAtIndex:0];
                            [_loginTimesArray removeObjectAtIndex:0];
                            [_logoutTimesArray removeObjectAtIndex:0];
                            [_daysArray removeObjectAtIndex:0];
                            [_loginDoubleValuesArray removeObjectAtIndex:0];
                            [_logoutDoubleValuesArray removeObjectAtIndex:0];
                            [_officeIdsFromRoster removeObjectAtIndex:0];
                            [_rosterLoginIdsArray removeObjectAtIndex:0];
                            [_rosterLogoutIdsArray removeObjectAtIndex:0];
                        }
                    }else{
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"today"];
                    }
                }
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"today"];
                [_allDatesArray removeObjectAtIndex:0];
                [_loginTimesArray removeObjectAtIndex:0];
                [_logoutTimesArray removeObjectAtIndex:0];
                [_daysArray removeObjectAtIndex:0];
                [_loginDoubleValuesArray removeObjectAtIndex:0];
                [_logoutDoubleValuesArray removeObjectAtIndex:0];
                [_officeIdsFromRoster removeObjectAtIndex:0];
                [_rosterLoginIdsArray removeObjectAtIndex:0];
                [_rosterLogoutIdsArray removeObjectAtIndex:0];
            }
            
            NSString *logoutDoubleValue = [_logoutTimesArray firstObject];
            NSLog(@"%@",logoutDoubleValue);
            if ([logoutDoubleValue isEqualToString:@"OFF"]){
                
            }else{
                long double value = [logoutDoubleValue doubleValue];
                NSDate *logoutDate = [NSDate dateWithTimeIntervalSince1970:(value/1000.0)];
                NSLog(@"%@",logoutDate);
                NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:logoutDate];
                NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:logoutDate];
                NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
                NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:logoutDate] dateByAddingTimeInterval:(2*60*60)];
                NSLog(@"%@",logoutDate);
                
                NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
                NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
                NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
                NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
                NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
                NSLog(@"%@",destinationDate1);
                
                
                if ([destinationDate compare:destinationDate1] == NSOrderedDescending){
                    NSTimeInterval differenceInSeconds = [destinationDate timeIntervalSinceDate:destinationDate1];
                    NSLog(@"%f",differenceInSeconds);
                    [NSTimer scheduledTimerWithTimeInterval:differenceInSeconds target:self selector:@selector(timeCompleted) userInfo:nil repeats:NO];
                }else{
                    
                }
            }
            
            if (resultArray.count !=0 || resultArray.count){
                for (NSDictionary *eachBand in resultArray){
                    long double date = [[eachBand valueForKey:@"date"] doubleValue];
                    NSTimeInterval seconds = date/1000;
                    NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *finalDate = [formatter stringFromDate:convertedDate];
                    
                    if ([[_allDatesArray objectAtIndex:0] isEqualToString:finalDate]){
                        BOOL emergency = [[eachBand valueForKey:@"emergency"] boolValue];
                        NSLog(@"%@",[NSNumber numberWithBool:emergency]);
                        if (emergency){
                            _finalEmergencyDate = finalDate;
                        }else{
                            _finalEmergencyDate = @"OFF";
                        }
                    }
                }
                
                
            }else{
                
            }
            
            
            [_scheduleTableView reloadData];
            
        }
        else{
            
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please check your connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)timeCompleted{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"timeCompleted" object:nil];
}
- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(void)getAllOffices{
    if ([self connectedToInternet]){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [NSDate date];
        NSString *dateInStringForWeb = [formatter stringFromDate:date];
        NSDate *resultDate = [formatter dateFromString:dateInStringForWeb];
        
        long double today = [resultDate timeIntervalSince1970];
        NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
        long double mine = [str1 doubleValue]*1000;
        NSDecimalNumber *fromDate = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
        
        NSString *urlInString;
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        if([Port isEqualToString:@"-1"])
        {
            urlInString =[NSString stringWithFormat:@"%@://%@/getRosteringData?requestType=office",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
        }
        else
        {
            urlInString =[NSString stringWithFormat:@"%@://%@:%@/getRosteringData?requestType=office",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
        
        NSDictionary *json = @{@"employeeId":userid,@"date":fromDate};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
        if (resultData != nil){
            id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
            if ([result isKindOfClass:[NSArray class]]){
                for (NSDictionary *eachOffice in result){
                    NSLog(@"%@",eachOffice);
                    NSString *officeName = [eachOffice valueForKey:@"name"];
                    NSString *officeId = [[eachOffice valueForKey:@"_id"] valueForKey:@"$oid"];
                    [_officeNamesArray addObject:officeName];
                    [_officeIdsArray addObject:officeId];
                }
            }else{
                
            }
            [[NSUserDefaults standardUserDefaults] setValue:[_officeIdsArray firstObject] forKey:@"defaultOfficeId"];
        }else{
            //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //        [alert show];
        }
        _scheduleTableView.dataSource = self;
        _scheduleTableView.delegate = self;
        [_scheduleTableView reloadData];
    }else{
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //        [alert show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //    if (alertView.tag == 100){
    //        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enabledSelection"];
    //        [_scheduleTableView setEditing:NO animated:YES];
    //        [self adjustNavigationItems];
    //        toolBar.hidden = YES;
    //
    //        CGRect frame = _scheduleTableView.frame;
    //        _scheduleTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    //
    //    }
    if (alertView.tag == 2002){
        if (buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                SomeViewController *some = [[SomeViewController alloc]init];
                [self presentViewController:some animated:YES completion:nil];
            });
        }
    }
    if (alertView.tag == 2222){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                _allDatesArray = [self getWeekDays];
                _daysArray = [[NSMutableArray alloc]init];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                for (int i=0;i<_allDatesArray.count;i++){
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"dd\nEE"];
                    NSDate *date = [dateFormatter dateFromString:[_allDatesArray objectAtIndex:i]];
                    NSString *dayString = [formatter stringFromDate:date];
                    [_daysArray addObject:dayString];
                }
                [self getAllSchedule];
                [self getCutoffs];
                if (_officeNamesArray.count != 0){
                }else{
                    [self getAllOffices];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
    if (alertView.tag == 00000){
        if  (buttonIndex == 0){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *urlInString;
                    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                    if([Port isEqualToString:@"-1"])
                    {
                        urlInString =[NSString stringWithFormat:@"%@://%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                    }
                    else
                    {
                        urlInString =[NSString stringWithFormat:@"%@://%@:%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                    NSLog(@"%@",userid);
                    
                    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
                    
                    long double currentTime = [[NSDate date] timeIntervalSince1970]*1000;
                    
                    NSString *date = [_allDatesArray objectAtIndex:0];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *convertedDate = [formatter dateFromString:date];
                    long double doubleValueOfDate = [convertedDate timeIntervalSince1970];
                    NSString *str1 = [NSString stringWithFormat:@"%.Lf",doubleValueOfDate];
                    long double mine = [str1 doubleValue]*1000;
                    NSDecimalNumber *finalValueOfDate = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
                    NSString *finalDate = [finalValueOfDate stringValue];
                    NSDictionary *dict = @{@"_employeeId":userid,@"date":finalDate,@"deploymentBand":@{@"_officeId":[_officeIdsFromRoster objectAtIndex:0],@"login":[NSNumber numberWithBool:NO],@"time":[NSString stringWithFormat:@"%.0Lf",currentTime]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:YES],@"emergency":[NSNumber numberWithBool:YES]};
                    [dataArray addObject:dict];
                    
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error_config];
                    [request setHTTPBody:jsonData];
                    
                    NSURLResponse *responce;
                    
                    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                    id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                    NSLog(@"%@",jsonresult);
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                    NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                    
                    if ([jsonresult isKindOfClass:[NSDictionary class]]){
                        if ([httpResponse statusCode] != 412){
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Emergency" message:@"Schedule successfully updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                            alert.tag = 2222;
                            
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Emergency" message:@"Can not update emergency schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Emergency" message:@"Can not update emergency schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
        }
    }
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
-(void)tripCompletedNotification:(NSNotification *)sender{
    NSDictionary *myDictionary = (NSDictionary *)sender.object;
    if ([sender.name isEqualToString:@"tripCompleted"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tripFeedbackForm"]){
                SomeViewController *some1 = [[SomeViewController alloc]init];
                [some1 getTripId:[myDictionary valueForKey:@"tripId"]];
                [self presentViewController:some1 animated:YES completion:nil];
            }else{
                
            }
            
        });
    }
    if ([sender.name isEqualToString:@"timeCompleted"]){
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getAllSchedule];
                [self getCutoffs];
                if (_officeNamesArray.count != 0){
                }else{
                    [self getAllOffices];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
    }
}
-(void)getCutoffs{
    if ([self connectedToInternet]){
        NSString *urlInString;
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        if([Port isEqualToString:@"-1"])
        {
            urlInString =[NSString stringWithFormat:@"%@://%@/getRosteringData?requestType=cutoffs",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
        }
        else
        {
            urlInString =[NSString stringWithFormat:@"%@://%@:%@/getRosteringData?requestType=cutoffs",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
        
        NSDictionary *json = @{@"employeeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"employeeId"]};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
        if (resultData != nil){
            id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
            NSLog(@"%@",result);
            _cutOffModel = result;
            _cutoffDay = [_cutOffModel valueForKey:@"day"];
            _cutoffTime = [_cutOffModel valueForKey:@"time"];
            //    _loginRivisionAllowed = [[_cutOffModel valueForKey:@"loginRevisionAllowed"] boolValue];
            //    _logoutRivisionAllowed = [[_cutOffModel valueForKey:@"logoutRevisionAllowed"] boolValue];
        }else{
            //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please check your connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //        [alert show];
        }
    }else{
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please check your connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //        [alert show];
    }
}
-(void)emergencyPressed:(UIButton *)sender{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Really want to schedule emergency Logout?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Cancel", nil];
    [alert show];
    alert.tag = 00000;
    
}
-(NSMutableArray *)getWeekDays{
    
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger weekNumber =  [[calendar components: NSWeekCalendarUnit fromDate:now] week];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comp = [gregorian components:NSYearCalendarUnit fromDate:now];
    [comp setWeek:weekNumber];  //Week number.
    [comp setWeekday:[_cutoffDay integerValue]]; //First day of the week. Change it to 7 to get the last date of the week
    
    
    NSDate *resultDate = [gregorian dateFromComponents:comp];
    
    NSDateComponents *offset = [[NSDateComponents alloc]init];
    [offset setSecond:([_cutoffTime integerValue]/1000)];
    
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:resultDate options:0];
    
    _cutoffDateAndTime = newDate;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *nowDate = [NSDate date];
    NSDate *startOfTheWeek;
    NSDate *endOfWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSWeekCalendarUnit
           startDate:&startOfTheWeek
            interval:&interval
             forDate:nowDate];
    
    endOfWeek = [startOfTheWeek dateByAddingTimeInterval:interval-1];
    NSDate *sundayDate = [endOfWeek dateByAddingTimeInterval:24*60*60];
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:nowDate
                                                          toDate:sundayDate
                                                         options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    //If -1 means dates are coming as one day before (yesterday)
    // If 0 means dates are coming as today to next week
    
    if ([[NSDate date] compare:newDate] == NSOrderedAscending){
        for (int i=0;i<8+[components day];i++){
            NSDate *newDate1 = [[NSDate date] dateByAddingTimeInterval:60*60*24*i];
            [array addObject:[formatter stringFromDate:newDate1]];
        }
    }else{
        for (int i=0;i<15+[components day];i++){
            NSDate *newDate1 = [[NSDate date] dateByAddingTimeInterval:60*60*24*i];
            [array addObject:[formatter stringFromDate:newDate1]];
        }
    }
    
    NSDate *yesterDayDate = [[NSDate date] dateByAddingTimeInterval:(-24*60*60)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yesterdayDateString = [dateFormatter stringFromDate:yesterDayDate];
    
    [array insertObject:yesterdayDateString atIndex:0];
    
    
    return array;
}
//-(BOOL)connectedToInternet
//{
//    Reachability *networkReachability = [Reachability reachabilityWithHostName:@"www.google.com"];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//    if (networkStatus == NotReachable) {
//        return NO;
//    } else {
//        return YES;
//    }
//}
-(IBAction)sos:(id)sender;
{
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }
    [self presentViewController:sosController animated:YES completion:nil];
}
@end
