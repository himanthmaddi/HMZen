//
//  MenuViewControllerParent.m
//  Safetrax
//
//  Created by Kumaran on 10/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import "MenuViewControllerParent.h"
#import "AppDelegate.h"
#import "MFSideMenu.h"
#import <Smooch/Smooch.h>

@interface MenuViewControllerParent ()

@end
int backStack;
@implementation MenuViewControllerParent
@synthesize Name,empId,picLabel,CompanyCode;
- (void)viewDidLoad {
    self.view.frame = [[UIScreen mainScreen] bounds];
    MyChildren = nil;
    picLabel.layer.masksToBounds = YES;
    picLabel.layer.cornerRadius = 20;
    Name.text = [NSString stringWithFormat:@"%@-%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"name"],[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
   
    //empId.text=[[NSUserDefaults standardUserDefaults]
                //stringForKey:@"empid"];
    CompanyCode.text=[[[NSUserDefaults standardUserDefaults]
                stringForKey:@"companycode"] capitalizedString];
    picLabel.text = [Name.text substringToIndex:1];
    backStack = 1;
    UIButton *MytripButton = (UIButton *)[self.view viewWithTag:200];
    MytripButton.selected = NO;
    [MytripButton setBackgroundColor:[UIColor clearColor]];
    
    UIButton *MyChild = (UIButton *)[self.view viewWithTag:100];
    MyChild.selected = YES;
    [MyChild setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *Help = (UIButton *)[self.view viewWithTag:300];
    Help.selected = NO;
    [Help setBackgroundColor:[UIColor clearColor]];
    
    UIButton *Logout = (UIButton *)[self.view viewWithTag:400];
    Logout.selected = NO;
    [Logout setBackgroundColor:[UIColor clearColor]];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction)Help:(id)sender
{
    if(backStack == 2)
    {
        UIButton *MytripButton = (UIButton *)[self.view viewWithTag:200];
        MytripButton.selected = YES;
        [MytripButton setBackgroundColor:[UIColor lightGrayColor]];
        
        UIButton *MyChild = (UIButton *)[self.view viewWithTag:100];
        MyChild.selected = NO;
        [MyChild setBackgroundColor:[UIColor clearColor]];
        
        UIButton *Help = (UIButton *)[self.view viewWithTag:300];
        Help.selected = NO;
        [Help setBackgroundColor:[UIColor clearColor]];
        
        UIButton *Logout = (UIButton *)[self.view viewWithTag:400];
        Logout.selected = NO;
        [Logout setBackgroundColor:[UIColor clearColor]];
        MyTrip = nil;
        MyTrip = [[MyTripParentViewController alloc]
                  initWithNibName:@"MyTripParentViewController" bundle:nil];
        [self.menuContainerViewController setCenterViewController:MyTrip];
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{ [Smooch show];}];
        
    }
    else if(backStack == 1)
    {
        UIButton *MytripButton = (UIButton *)[self.view viewWithTag:200];
        MytripButton.selected = NO;
        [MytripButton setBackgroundColor:[UIColor clearColor]];
        
        UIButton *MyChild = (UIButton *)[self.view viewWithTag:100];
        MyChild.selected = YES;
        [MyChild setBackgroundColor:[UIColor lightGrayColor]];
        
        UIButton *Help = (UIButton *)[self.view viewWithTag:300];
        Help.selected = NO;
        [Help setBackgroundColor:[UIColor clearColor]];
        
        UIButton *Logout = (UIButton *)[self.view viewWithTag:400];
        Logout.selected = NO;
        [Logout setBackgroundColor:[UIColor clearColor]];
        MyChildren = nil;
        MyChildren = [[MyChildrenViewController alloc]
                      initWithNibName:@"MyChildrenViewController" bundle:nil];
        [self.menuContainerViewController setCenterViewController:MyChildren];
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{[Smooch show];}];
    }
}
-(IBAction)MyTrip:(id)sender
{
    backStack = 2;
    UIButton *MytripButton = (UIButton *)[self.view viewWithTag:200];
    MytripButton.selected = YES;
    [MytripButton setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *MyChild = (UIButton *)[self.view viewWithTag:100];
    MyChild.selected = NO;
    [MyChild setBackgroundColor:[UIColor clearColor]];
    
    UIButton *Help = (UIButton *)[self.view viewWithTag:300];
    Help.selected = NO;
    [Help setBackgroundColor:[UIColor clearColor]];
    
    UIButton *Logout = (UIButton *)[self.view viewWithTag:400];
    Logout.selected = NO;
    [Logout setBackgroundColor:[UIColor clearColor]];
    
    MyTrip = nil;
    MyTrip = [[MyTripParentViewController alloc]
            initWithNibName:@"MyTripParentViewController" bundle:nil];
    [self.menuContainerViewController setCenterViewController:MyTrip];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}
-(IBAction)MyChildren:(id)sender
{
    backStack = 1;
    UIButton *MytripButton = (UIButton *)[self.view viewWithTag:200];
    MytripButton.selected = NO;
    [MytripButton setBackgroundColor:[UIColor clearColor]];
    
    UIButton *MyChild = (UIButton *)[self.view viewWithTag:100];
    MyChild.selected = YES;
    [MyChild setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *Help = (UIButton *)[self.view viewWithTag:300];
    Help.selected = NO;
    [Help setBackgroundColor:[UIColor clearColor]];
    
    UIButton *Logout = (UIButton *)[self.view viewWithTag:400];
    Logout.selected = NO;
    [Logout setBackgroundColor:[UIColor clearColor]];
    MyChildren = nil;
    MyChildren = [[MyChildrenViewController alloc]
                  initWithNibName:@"MyChildrenViewController" bundle:nil];
    [self.menuContainerViewController setCenterViewController:MyChildren];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];

}
-(IBAction)logout:(id)sender
{
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:@""
                            message:@"Do You Want To Logout?"
                            delegate:self
                            cancelButtonTitle:@"No"
                            otherButtonTitles:@"Yes",nil];
    [myAlert show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"LastTrip"];
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate dismiss_delegate:nil];
        [SKTUser currentUser].firstName = @"";
        [SKTUser currentUser].email = @"";
    }
}

@end
