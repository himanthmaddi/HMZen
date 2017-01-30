//
//  SettingsViewController.m
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "SettingsViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "SomeViewController.h"

extern NSArray *tripList;
@interface SettingsViewController ()
@end
@implementation SettingsViewController
@synthesize trackSwitch;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        helpContacts = [[HelpContactsViewController alloc] initWithNibName:@"HelpContactsViewController"  bundle:Nil];
        aboutView =  [[AboutViewController alloc] initWithNibName:@"AboutViewController"  bundle:Nil];
        changePasswordView = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController"  bundle:Nil];
        
        if (!tripList || !tripList.count){
            sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
        }
        else{
            sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
        }
        
    }
    return self;
}
- (void)viewDidLoad
{
    self.view.frame = [[UIScreen mainScreen] bounds];
    [super viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"trackOnlyOnSoS"])
        [trackSwitch setOn:YES animated:YES];
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark Menu Event
- (void)menuStateEventOccurred:(NSNotification *)notification {
    //When menu is closed, make the blurred view dynamic again
    MFSideMenuStateEvent event = [[notification userInfo][@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose){
        infoView.dynamic = YES;
    }
}
- (IBAction)help:(id)sender {
    [self presentViewController:helpContacts animated:YES completion:nil];
}
-(IBAction)openSettingsMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    infoView.dynamic = NO;
}
- (IBAction)changeSwitch:(id)sender
{
    if([sender isOn]){
        NSLog(@"Switch is ON");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"trackOnlyOnSoS"];
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate stopUpdateLocation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Track Only On SOS"
                                                        message:@"Tracking will be done on sos alerts only!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Switch is OFF");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Track Only On SOS"
                                                        message:@"Tracking will be done during trips!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate updateLocation];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"trackOnlyOnSoS"];
    }
}
-(IBAction)setNewPassword:(id)sender
{
    changePasswordView.modalPresentationStyle = UIModalPresentationFormSheet;
    changePasswordView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:changePasswordView animated:YES completion:nil];
}
-(IBAction)aboutView:(id)sender
{
    aboutView.modalPresentationStyle = UIModalPresentationFormSheet;
    aboutView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:aboutView animated:YES completion:nil];
}
-(IBAction)sos:(id)sender {
    sosController = nil;
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }    [self presentViewController:sosController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tripCompletedNotification:(NSNotification *)sender{
    NSDictionary *myDictionary = (NSDictionary *)sender.object;
    NSLog(@"%@",myDictionary);
    if ([sender.name isEqualToString:@"tripCompleted"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            SomeViewController *some = [[SomeViewController alloc]init];
            [some getTripId:[myDictionary valueForKey:@"tripId"]];
            [self presentViewController:some animated:YES completion:nil];
        });
        
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2002){
        if (buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                SomeViewController *some = [[SomeViewController alloc]init];
                [self presentViewController:some animated:YES completion:nil];
            });
        }
    }
}
@end
