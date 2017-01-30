//
//  SettingsViewController.h
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h" 
#import "AboutViewController.h"
#import "ChangePasswordViewController.h"
#import "HelpContactsViewController.h"
#import "SOSMainViewController.h"
@interface SettingsViewController : UIViewController
{
    HelpContactsViewController *helpContacts;
    FXBlurView *infoView;
    ChangePasswordViewController *changePasswordView;
    AboutViewController *aboutView;
    SOSMainViewController *sosController;
}
- (IBAction)help:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *trackSwitch;

@end
