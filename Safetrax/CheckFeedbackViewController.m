//
//  CheckFeedbackViewController.m
//  Safetrax
//
//  Created by Kumaran on 25/01/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "CheckFeedbackViewController.h"
#import "HomeViewController.h"
@interface CheckFeedbackViewController ()

@end

@implementation CheckFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setDelegate:(id)newDelegate{
    homeObject = newDelegate;
   
}
-(void)downloadConfig
{
    NSString *userName = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"password"];
    NSString *tripId = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"LastTripId"];
    NSLog(@"tripid %@",tripId);
   if([tripId length] < 1 )
   {
       NSLog(@"tripid");
       tripId =  @"1";
   }
    else
    {
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSMutableDictionary *code_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tripId, @"tripId",nil];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSData* config_json2 = [NSJSONSerialization dataWithJSONObject:code_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *newStr4 = [[NSString alloc] initWithData:config_json2 encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@", newStr2, newStr4];
    NSLog(@"checkfeedback %@",str);
    NSData* finalJson = [str dataUsingEncoding:NSUTF8StringEncoding];
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"query" withMethod:@"POST" andColumnName:@"feedback"];
    [requestWraper setPostParamFromString:str];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    _responseData = [[NSMutableData alloc] init];
    [RestClient execute];
  
   }
   

}
-(void)onResponseReceived:(NSData *)data
{
    NSMutableArray *empIds = [[NSMutableArray alloc] init];
    NSString *userid = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"empid"];
    NSDictionary *auth_dictionary= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    id config_array= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSLog(@"AUTH %@",auth_dictionary);
    if([config_array isKindOfClass:[NSDictionary class]]){
        if([config_array objectForKey:@"status"]){
            NSLog(@"no config data");
             [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
        }
    }
    else
    {
        for(NSDictionary *config in auth_dictionary){
        NSArray *feedbackArray = [config objectForKey:@"reviews"];
        for(NSDictionary *employee in feedbackArray)
        {
            if(employee[@"empid"])
            {
                [empIds addObject:employee[@"empid"]];
            }
          }
        }
        if([empIds containsObject:userid])
            
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
            
        }
        else
        {
             [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
             [homeObject ShowFeedback];
        }
    
    }
}
-(void)onFailure
{
    NSLog(@"Failure callback");
    //if([[NSUserDefaults standardUserDefaults] setObject:tripID forKey:@"LastTripId"])
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ShowFeedbackForm"];
    [homeObject ShowFeedback];
}
-(void)onConnectionFailure
{
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    
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
