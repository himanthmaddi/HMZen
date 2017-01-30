//
//  MenuViewController.m
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <Smooch/Smooch.h>
#import "ScheduleViewController.h"

@interface MenuViewController (){
    UINavigationController *navigationVC2;
}

@end
@import FirebaseInstanceID;
MFSideMenuContainerViewController *rootViewControllerParent_delegate;
@implementation MenuViewController
@synthesize Name,empId,picLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        settings = [[SettingsViewController alloc]
                    initWithNibName:@"SettingsViewController" bundle:nil];
        history = [[HistoryViewController alloc]
                   initWithNibName:@"HistoryViewController" bundle:nil];
        //        schedule = [[ScheduleViewController alloc]initWithNibName:@"ScheduleViewController" bundle:nil];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
        schedule = [story instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
        navigationVC2 = [[UINavigationController alloc]initWithRootViewController:schedule];
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    picLabel.layer.masksToBounds = YES;
    picLabel.layer.cornerRadius = 20;
    Name.text = [[NSUserDefaults standardUserDefaults]
                 stringForKey:@"name"];
    empId.text=[[NSUserDefaults standardUserDefaults]
                stringForKey:@"empid"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"rosterVisible"]){
        _underlineView.hidden = NO;
        _roasterButton.hidden = NO;
        _roasterImageView.hidden = NO;
    }else{
        _underlineView.hidden = YES;
        _roasterImageView.hidden = YES;
        _roasterButton.hidden = YES;
    }
    
    //    picLabel.text = [Name.text substringToIndex:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)settings:(id)sender
{
    [self.menuContainerViewController setCenterViewController:settings];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}
-(IBAction)home:(id)sender
{
    home = nil;
    home = [[HomeViewController alloc]
            initWithNibName:@"HomeViewController" bundle:nil];
    [self.menuContainerViewController setCenterViewController:home];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}
-(IBAction)history:(id)sender
{
    [self.menuContainerViewController setCenterViewController:history];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}
-(IBAction)logout:(id)sender
{
    [[self presentedViewController] dismissViewControllerAnimated:NO completion:nil];
    
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:@""
                            message:@"Really Want To Logout?"
                            delegate:self
                            cancelButtonTitle:@"No"
                            otherButtonTitles:@"Yes",nil];
    [myAlert show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
        [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
        
        home.view.backgroundColor = [UIColor clearColor];
        [home.view removeFromSuperview];
        home = nil;
        settings.view.backgroundColor = [UIColor clearColor];
        [settings.view removeFromSuperview];
        settings = nil;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate dismiss_delegate:nil];
        [self.view removeFromSuperview];
        
    }
}
-(IBAction)help:(id)sender{
    [Smooch show];
}
-(IBAction)mySchedulePressed:(id)sender
{
    [self.menuContainerViewController setCenterViewController:navigationVC2];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
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

@end
