//
//  AdminContactsViewController.m
//  Commuter
//
//  Created by Himanth Maddi on 26/04/17.
//  Copyright © 2017 Mtap. All rights reserved.
//

#import "AdminContactsViewController.h"
#import "MFSideMenu.h"
#import "FXBlurView.h"
#import "AFNetworking.h"
#import <MBProgressHUD.h>

@interface AdminContactsViewController (){
    FXBlurView *infoView;
    NSArray *allContacts;
}
@end

@implementation AdminContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAllContacts];
    // Do any additional setup after loading the view.
}
-(void)getAllContacts{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_HIGH), ^{
        
        //ObjectId("58b6d1c01a12952000e09b3c")
        
        NSString *urlInString;
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        if([Port isEqualToString:@"-1"])
        {
            urlInString =[NSString stringWithFormat:@"%@://%@/getadmincontacts?employeeId=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] valueForKey:@"employeeId"]];
        }
        else
        {
            urlInString =[NSString stringWithFormat:@"%@://%@:%@/getadmincontacts?employeeId=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],[[NSUserDefaults standardUserDefaults] valueForKey:@"employeeId"]];
        }
        
        NSURL *scheduleURL = [NSURL URLWithString:urlInString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:scheduleURL];
        [request setHTTPMethod:@"POST"];
        
        NSError *error_config;
        
        NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
        NSString *headerString;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
            headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString,@"oauth_type",@"azure"];
        }else{
            headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
        }
        NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
        [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
        
        NSDictionary *json = @{};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30.0;
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
        
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response , id jsonObject , NSError *error){
            if (error){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                _contactsTableView.hidden = YES;
                _noContactsLabel.hidden = NO;
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"The Internet connection appears to be offline." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        alertView.tag = 001;
                        [alertView show];
                    });
                }
                else if ([error.localizedDescription isEqualToString:@"The request timed out."]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"The requste timed out. Please try again" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
                        alertView.tag = 001;
                        [alertView show];
                    });
                }
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([jsonObject count] > 0){
                    allContacts = jsonObject;
                    _contactsTableView.hidden = NO;
                    _noContactsLabel.hidden = YES;
                    _contactsTableView.delegate = self;
                    _contactsTableView.dataSource = self;
                    [_contactsTableView reloadData];
                }else{
                    _contactsTableView.hidden = YES;
                    _noContactsLabel.hidden = NO;
                }
            }
        }];
        
        [task resume];
    });
    
}
-(IBAction)menuButtonPressed:(id)sender{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    infoView.dynamic = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return allContacts.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [[allContacts objectAtIndex:indexPath.section] objectForKey:@"phone"];
    cell.detailTextLabel.text = [[allContacts objectAtIndex:indexPath.section] objectForKey:@"name"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *number = cell.textLabel.text;
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",number]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        [[UIApplication sharedApplication] openURL:phoneUrl];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call Facility Is Not Available!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [calert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}
@end
