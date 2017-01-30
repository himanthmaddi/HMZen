//
//  MyChildrenViewController.m
//  Safetrax
//
//  Created by Kumaran on 10/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import "MyChildrenViewController.h"
#import "MFSideMenu.h"
#import <MapKit/MapKit.h>
#import "validateLogin.h"
#import "MyChildrenHelpViewController.h"
@interface MyChildrenViewController ()

@end
BOOL ChildrenRefreshInProgress = FALSE;
@implementation MyChildrenViewController
@synthesize child1,child2,child3,child4,child1Name,child2Name,child3Name,child4Name;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    self.view.frame = [[UIScreen mainScreen] bounds];
    NSLog(@"viewdidload");
    validateLogin *validate = [[validateLogin alloc] init];
    [validate setDelegate:self];
}
-(void)didFinishvalidation
{
    NSLog(@"did finish");
    [self SetChildrenImage];
}
-(void)refresh
{
    NSLog(@"refresh");
    if(!ChildrenRefreshInProgress){
        ChildrenRefreshInProgress = TRUE;
        [self SetChildrenImage];
    }
   
}
-(IBAction)moreButtonClicked
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                  @"Sync",
                                  nil];
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Sync"]) {
        [self refresh];
    }
}

-(void)SetChildrenImage
{
    NSString *childName = [NSString stringWithFormat:@"%@\n%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"name"],[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
    child1Name.text = childName;
    // NSString *child = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"name"]];
    //  [child1 setBackgroundImage:[UIImage imageNamed:@"http://www.projectsnext.com/wp-content/uploads/2015/07/nikola-tesla.jpg"] forState:UIControlStateNormal];
    NSString *ImageName = [[NSUserDefaults standardUserDefaults] stringForKey:@"imageLinkMainInfo"];
    if(!(ImageName == NULL || [ImageName isEqualToString:@""]))
    {
        UILabel *downloadLabel = (UILabel *)[self.view viewWithTag:400];
        downloadLabel.hidden = NO;
        [self ImageRequest:ImageName withId:600];
        
    }
    else
    {
        
        UILabel *downloadLabel = (UILabel *)[self.view viewWithTag:400];
        downloadLabel.hidden = YES;
        
        
    }
    NSArray *extras =  [[NSUserDefaults standardUserDefaults] arrayForKey:@"extras"];
    NSLog(@"extras %@",ImageName);
    UIButton *childbutton;
    UILabel *childrenNameLabel;
    int i=1;
    for(NSDictionary *dictionary in extras)
    {
        childbutton = (UIButton *)[self.view viewWithTag:600+i];
        ImageName = [dictionary objectForKey:@"imageLink"] ;
        childName = [NSString stringWithFormat:@"%@\n%@",[dictionary objectForKey:@"name"],[dictionary objectForKey:@"empid"]];
        childrenNameLabel = (UILabel *)[self.view viewWithTag:700+i];
        if(!(ImageName == NULL || [ImageName isEqualToString:@""]))
        {
            UILabel *downloadLabel = (UILabel *)[self.view viewWithTag:400+i];
            downloadLabel.hidden = NO;
            childbutton.hidden =  NO;
           [self ImageRequest:ImageName withId:600+i];
        }
        else
        {
            UILabel *downloadLabel = (UILabel *)[self.view viewWithTag:400+i];
            downloadLabel.hidden = YES;
            childbutton.hidden =  NO;
            
        }
        childrenNameLabel.text = childName;
        childrenNameLabel.hidden = NO;
        i++;
    }
    ChildrenRefreshInProgress = FALSE;

}
-(void)UpdateImage:(NSData *)ImageData withID:(int)buttonId
{
     UIButton *childbutton;
     UIImageView *pic = [[UIImageView alloc] init];
    childbutton = (UIButton *)[self.view viewWithTag:buttonId];
    
    if([ImageData length] >0){
       
        CGImageRef cgref = [[UIImage imageWithData:ImageData] CGImage];
        CIImage *cim = [[UIImage imageWithData:ImageData] CIImage];
        
        if (cim == nil && cgref == NULL)
        {
            NSLog(@"no underlying data");

        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // code here
           
        pic.image = [UIImage imageWithData:ImageData];
                [childbutton setBackgroundImage:pic.image forState: UIControlStateNormal];
                });
             childbutton.hidden = NO;
            NSLog(@"Image set");
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        UILabel *downloadLabel = (UILabel *)[self.view viewWithTag:buttonId-200];
        downloadLabel.hidden = YES;
    });

  
}
-(void)ImageRequest:(NSString *)filename withId:(int)buttonId
{
    
   
//http://10.10.100.185:8081/gridfsget/safetraxVidyashilp/trackables_files?filename=profile_I5839_1437643754335
    
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
        url =[NSString stringWithFormat:@"%@://%@/gridfsget/%@/helpfiles?filename=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],filename];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/gridfsget/%@/trackables_files?filename=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],filename];
    }
    
    NSMutableData *imageData= [[NSMutableData alloc] init];
    NSURL *urlString = [NSURL URLWithString:url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlString];
    NSLog(@"url-%@",urlString);
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             [imageData appendData:data];
             NSLog(@"downloaded image");
             [self UpdateImage:data withID:buttonId];
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
              [imageData appendData:data];
             [self UpdateImage:data withID:buttonId];
             
         }
         else if (error != nil){
             NSLog(@"Error = %@", error);
             UILabel *downloadLabel = (UILabel *)[self.view viewWithTag:buttonId-200];
             downloadLabel.hidden = YES;

         }
         
     }];
}
-(IBAction)MyChildrenHelp:(id)sender
{
    MyChildrenHelpViewController *MychildrenHelp = [[MyChildrenHelpViewController alloc] initWithNibName:@"MyChildrenHelpViewController" bundle:nil];
    [self presentViewController:MychildrenHelp animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Menu Event
- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[notification userInfo][@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose){
        NSLog(@"menu closed");
        blurView.dynamic = YES;
        [self dismiss];
    }
}
- (void)showOnVC {
   
    blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
    CGRect frameRect = blurView.frame;
    frameRect.origin.y = 60;
    blurView.frame = frameRect;
    blurView.underlyingView = self.view;
    blurView.tintColor = [UIColor clearColor];
    blurView.updateInterval = 1;
    blurView.blurRadius = 15.f;
    blurView.alpha = 0.f;
    [self.view addSubview:blurView];
    [UIView animateWithDuration:0.1 animations:^{
        blurView.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 1.0f;
        }];
    }];
}

-(IBAction)openMenu:(id)sender
{
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateLeftMenuOpen)
    {
        [self dismiss];
    }
    else
    {
        [self showOnVC];
    }
       [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    blurView.dynamic = NO;
    
}
#pragma mark Clear Screen
-(void)cleanInfoView {
    for (UIView *view in self.view.subviews) {
        if(!([view isKindOfClass:[UINavigationBar class]]||[view isKindOfClass:[MKMapView class]]||[view isKindOfClass:[FXBlurView class]])){
            [view removeFromSuperview];
        }
    }
}
- (void)dismiss {
    [UIView animateWithDuration:0.3
                     animations:^{
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1 animations:^{
                             blurView.alpha = 0.f;
                         } completion:^(BOOL finished) {
                             [blurView removeFromSuperview];
                         }];
                     }];
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
