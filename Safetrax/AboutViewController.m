//
//  AboutViewController.m
//  Safetrax
//
//  Created by Kumaran on 02/03/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "AboutViewController.h"
#import "SOSMainViewController.h"
#import "SomeViewController.h"

extern NSArray *tripList;
@interface AboutViewController ()
@end
@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
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
-(IBAction)sos:(id)sender{
    SOSMainViewController *sosController;
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }
    //    SOSMainViewController *sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    [self presentViewController:sosController animated:YES completion:nil];
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
