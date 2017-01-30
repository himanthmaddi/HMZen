//
//  MyTripHelpViewController.m
//  Safetrax
//
//  Created by Kumaran on 14/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import "MyTripHelpViewController.h"
#import <Smooch/Smooch.h>

@interface MyTripHelpViewController ()

@end

@implementation MyTripHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)LiveChatSupport:(id)sender
{
    [Smooch show];
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
