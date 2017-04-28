//
//  MenuViewController.h
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "HomeViewController.h"
#import "HistoryViewController.h"
#import "ScheduleViewController.h"
#import "AdminContactsViewController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    UITableView *menuView;
    UIImageView *profilePic;
    UILabel *employeeName;
    SettingsViewController *settings;
    HomeViewController *home;
    HistoryViewController *history;
    ScheduleViewController *schedule;
    AdminContactsViewController *adminContacts;
}

-(IBAction)settings:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *picLabel;
@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *empId;
@property (weak, nonatomic) IBOutlet UIButton *logout;

@property (nonatomic , strong) IBOutlet UIView *underlineView;
@property (nonatomic , strong) IBOutlet UIImageView *roasterImageView;
@property (nonatomic , strong) IBOutlet UIButton *roasterButton;

@end
