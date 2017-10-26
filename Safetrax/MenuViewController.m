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
#import <MBProgressHUD.h>


@interface MenuViewController (){
    UINavigationController *navigationVC2;
    UINavigationController *adminNavigation;
    NSMutableArray *textsArray;
    NSMutableArray *imagesArray;
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
        adminContacts = [story instantiateViewControllerWithIdentifier:@"AdminContactsViewController"];
        adminNavigation = [[UINavigationController alloc]initWithRootViewController:adminContacts];
    }
    //    7315158
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    textsArray = [[NSMutableArray alloc]init];
    imagesArray = [[NSMutableArray alloc]init];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    picLabel.layer.masksToBounds = YES;
    picLabel.layer.cornerRadius = 20;
    Name.text = [[NSUserDefaults standardUserDefaults]
                 stringForKey:@"name"];
    empId.text=[[NSUserDefaults standardUserDefaults]
                stringForKey:@"empid"];
    [_menuView setTableFooterView:[UIView new]];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"rosterVisible"]){
        NSNumber *transportUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"transportUser"];
        if (transportUser.boolValue == YES){
            [textsArray addObjectsFromArray:[NSArray arrayWithObjects:@"Home",@"My Schedule",@"Admin Help Desk",@"Settings",@"Support",@"Logout", nil]];
            [imagesArray addObjectsFromArray:[NSArray arrayWithObjects:[self image:[UIImage imageNamed:@"ic_home.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"_0009_schedule copy.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"helpdesk.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"settings.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"ic_support.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"logout.png"] scaledToSize:CGSizeMake(30, 30)], nil]];
        }else{
            [textsArray addObjectsFromArray:[NSArray arrayWithObjects:@"Home",@"Admin Help Desk",@"Settings",@"Support",@"Logout", nil]];
            [imagesArray addObjectsFromArray:[NSArray arrayWithObjects:[self image:[UIImage imageNamed:@"ic_home.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"helpdesk.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"settings.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"ic_support.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"logout.png"] scaledToSize:CGSizeMake(30, 30)], nil]];
        }
    }else{
        [textsArray addObjectsFromArray:[NSArray arrayWithObjects:@"Home",@"Admin Help Desk",@"Settings",@"Support",@"Logout", nil]];
        [imagesArray addObjectsFromArray:[NSArray arrayWithObjects:[self image:[UIImage imageNamed:@"ic_home.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"helpdesk.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"settings.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"ic_support.png"] scaledToSize:CGSizeMake(30, 30)],[self image:[UIImage imageNamed:@"LogOut.png"] scaledToSize:CGSizeMake(30, 30)], nil]];
    }
    
    picLabel.text = [Name.text substringToIndex:1];
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            home = nil;
            home = [[HomeViewController alloc]
                    initWithNibName:@"HomeViewController" bundle:nil];
            [self.menuContainerViewController setCenterViewController:home];
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}
-(IBAction)history:(id)sender
{
    //    [self.menuContainerViewController setCenterViewController:history];
    //    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
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
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
            NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (NSHTTPCookie *cookie in [cookieJar cookies]) {
                if ([cookie.name isEqualToString:@"MSISAuth"] ||
                    [cookie.name isEqualToString:@"MSISAuthenticated"] ||
                    [cookie.name isEqualToString:@"MSISLoopDetectionCookie"]) {
                    [cookieJar deleteCookie:cookie];
                }
            }
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
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
        }else{
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
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
}
-(IBAction)help:(id)sender{

}
-(IBAction)mySchedulePressed:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.menuContainerViewController setCenterViewController:navigationVC2];
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
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
-(IBAction)adminContactsPressed:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.menuContainerViewController setCenterViewController:adminNavigation];
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return textsArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    cell.imageView.image = [imagesArray objectAtIndex:indexPath.section];
    cell.backgroundColor = [UIColor colorWithRed:(81.0/255.0) green:(151.0/255.0) blue:(37.0/255.0) alpha:1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [textsArray objectAtIndex:indexPath.section];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.clipsToBounds = YES;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellText = [textsArray objectAtIndex:indexPath.section];
    if ([cellText isEqualToString:@"Home"]){
        [self home:nil];
    }else if ([cellText isEqualToString:@"My Schedule"]){
        [self mySchedulePressed:nil];
    }else if ([cellText isEqualToString:@"Admin Help Desk"]){
        [self adminContactsPressed:nil];
    }else if ([cellText isEqualToString:@"Settings"]){
        [self settings:nil];
    }else if ([cellText isEqualToString:@"Support"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [Smooch setUserFirstName:[[NSUserDefaults standardUserDefaults] valueForKey:@"name"] lastName:@""];
            [SKTUser currentUser].email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
            [[SKTUser currentUser] addProperties:@{@"Company":[[NSUserDefaults standardUserDefaults] valueForKey:@"company"],@"UserId":[[NSUserDefaults standardUserDefaults] valueForKey:@"empid"]}];
            [Smooch show];
        });
    }else if ([cellText isEqualToString:@"Logout"]){
        [self logout:nil];
    }
}
@end
