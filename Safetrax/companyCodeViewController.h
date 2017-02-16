//
//  companyCodeViewController.h
//  Safetrax
//
//  Created by Kumaran on 03/04/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface companyCodeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *companyCodeText;
- (IBAction)nextClicked:(id)sender;
- (IBAction)SmoochHelp:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *HelpTextButton;
-(void)downloadConfig:(NSString *)code;
-(void)refreshCompanyConfig:(NSString *)companyCodeString;
@end
