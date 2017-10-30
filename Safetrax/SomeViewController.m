//
//  SomeViewController.m
//  Commuter
//
//  Created by Himanth Maddi on 15/01/17.
//  Copyright © 2017 Mtap. All rights reserved.
//

#import "SomeViewController.h"
#import <MBProgressHUD.h>

@interface SomeViewController ()

@end

@implementation SomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _employeeIdLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    _employeeNameLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    _punctuationString = @"1";
    _vehicleConditionString = @"1";
    _driverBehaviourString = @"1";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)submitTripRating:(id)sender;
{

        [self dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *urlInString;
            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
            NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];

            if([Port isEqualToString:@"-1"])
            {
                urlInString =[NSString stringWithFormat:@"%@://%@/tripRating?tripId=%@&employeeId=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],_tripIdString,employeeId];
            }
            else
            {
                urlInString =[NSString stringWithFormat:@"%@://%@:%@/tripRating?tripId=%@&employeeId=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],_tripIdString,employeeId];
//            urlInString =[NSString stringWithFormat:@"https://10.21.11.153:8081/tripRating?tripId=%@",@"subro"];
            }
            NSLog(@"%@",urlInString);
            NSURL *scheduleURL = [NSURL URLWithString:urlInString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:scheduleURL];
            [request setHTTPMethod:@"POST"];
            
            NSError *error_config;
            
            NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
            NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
            NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
            [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
            
            NSDictionary *bodyDict = @{@"q1":_punctuationString,@"q2":_driverBehaviourString,@"q3":_vehicleConditionString,@"comments":_commentsTextField.text};
            NSLog(@"%@",bodyDict);
            NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error_config];
            
            [request setHTTPBody:bodyData];
            
            NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
            id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
            NSLog(@"%@",result);
            });
        }];
}

-(IBAction)puctualityGood:(id)sender;
{
    if (_punctualityGoodButton.currentImage == [UIImage imageNamed:@"radiobutton_selected.png"]){
    }else{
        [_punctualityGoodButton setBackgroundImage:[UIImage imageNamed:@"radiobutton_selected.png"] forState:UIControlStateNormal];
        [_punctualityBadButton setBackgroundImage:[UIImage imageNamed:@"Radiobutton_deslected.png"] forState:UIControlStateNormal];
    }
    _punctuationString = @"1";
}
-(IBAction)puctualityBad:(id)sender;
{
    if (_punctualityBadButton.currentImage == [UIImage imageNamed:@"radiobutton_selected.png"]){
    }else{
        [_punctualityBadButton setBackgroundImage:[UIImage imageNamed:@"radiobutton_selected.png"] forState:UIControlStateNormal];
        [_punctualityGoodButton setBackgroundImage:[UIImage imageNamed:@"Radiobutton_deslected.png"] forState:UIControlStateNormal];
    }
    _punctuationString = @"2";

}
-(IBAction)driverBehavingGood:(id)sender;
{
    if (_driverBehavingGoodButton.currentImage == [UIImage imageNamed:@"radiobutton_selected.png"]){
        
    }else{
        [_driverBehavingGoodButton setBackgroundImage:[UIImage imageNamed:@"radiobutton_selected.png"] forState:UIControlStateNormal];
        [_driverBehavingBadButton setBackgroundImage:[UIImage imageNamed:@"Radiobutton_deslected.png"] forState:UIControlStateNormal];
    }
    _driverBehaviourString = @"1";

}
-(IBAction)driverBehavingBad:(id)sender;
{
    if (_driverBehavingBadButton.currentImage == [UIImage imageNamed:@"radiobutton_selected.png"]){
        
    }else{
        [_driverBehavingBadButton setBackgroundImage:[UIImage imageNamed:@"radiobutton_selected.png"] forState:UIControlStateNormal];
        [_driverBehavingGoodButton setBackgroundImage:[UIImage imageNamed:@"Radiobutton_deslected.png"] forState:UIControlStateNormal];
    }
    _driverBehaviourString = @"2";

}

-(IBAction)vehicleConditionGood:(id)sender;
{
    
    if (_vehicleConditionGoodButton.currentImage == [UIImage imageNamed:@"radiobutton_selected.png"]){
        
    }else{
        [_vehicleConditionGoodButton setBackgroundImage:[UIImage imageNamed:@"radiobutton_selected.png"] forState:UIControlStateNormal];
        [_vehicleConditionBadButton setBackgroundImage:[UIImage imageNamed:@"Radiobutton_deslected.png"] forState:UIControlStateNormal];
    }
    _vehicleConditionString = @"1";

}
-(IBAction)vehicleConditionBad:(id)sender;
{
    
    if (_vehicleConditionBadButton.currentImage == [UIImage imageNamed:@"radiobutton_selected.png"]){
        
    }else{
        [_vehicleConditionBadButton setBackgroundImage:[UIImage imageNamed:@"radiobutton_selected.png"] forState:UIControlStateNormal];
        [_vehicleConditionGoodButton setBackgroundImage:[UIImage imageNamed:@"Radiobutton_deslected.png"] forState:UIControlStateNormal];
    }
    _vehicleConditionString = @"2";

}
-(void)getTripId:(NSString *)tripID;
{
    _tripIdString = tripID;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
