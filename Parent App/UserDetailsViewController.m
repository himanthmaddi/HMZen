//
//  UserDetailsViewController.m
//  Safetrax
//
//  Created by Kumaran on 14/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import "UserDetailsViewController.h"
#import <Smooch/Smooch.h>

@interface UserDetailsViewController ()

@end

@implementation UserDetailsViewController
@synthesize Email,Name;

- (void)viewDidLoad {
    [super viewDidLoad];
    Email.delegate = self;
    Name.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)startChat:(id)sender
{
    
    if([Name.text length] >0 && [Email.text length] >0)
    {
        [SKTUser currentUser].firstName = Name.text;
        [SKTUser currentUser].email = Email.text;
        [self dismissViewControllerAnimated:NO completion:^{
           [Smooch show];
        }];
        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Details"
                                                        message:@"Please enter name and email id"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
