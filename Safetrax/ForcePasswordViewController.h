//
//  ForcePasswordViewController.h
//  Safetrax
//
//  Created by Kumaran on 24/09/15.
//  Copyright © 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestClientTask.h"

@interface ForcePasswordViewController : UIViewController<RestCallBackDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordFieldOld;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldOne;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldTwo;
@property (weak, nonatomic) IBOutlet UILabel *invalidCredentials;
-(IBAction)changePassword:(id)sender;
@end
