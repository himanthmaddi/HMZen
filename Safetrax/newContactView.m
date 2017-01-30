//
//  newContactView.m
//  Safetrax
//
//  Created by Kumaran on 12/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "newContactView.h"
#import "addContactsView.h"

@interface newContactView ()

@end

@implementation newContactView
@synthesize Name,Mobile;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withString:(NSString *)type  withObject:(addContactsView *)addContactObject {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        contactType =type;
        addContact =addContactObject;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)newContact:(id)sender
{
    NSArray *emgContactArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"emgcontact"];
    NSMutableArray *mutableContactArray = [emgContactArray mutableCopy];
    NSDictionary *addConntacts = [NSDictionary dictionaryWithObjectsAndKeys:Name.text,@"name",Mobile.text,@"phone",contactType,@"type",nil];
    [mutableContactArray addObject:addConntacts];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableContactArray options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:mutableContactArray forKey:@"emgcontact"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self sendContacts:jsonString];
    [self dismissViewControllerAnimated:YES completion:nil];
    [addContact removeView:[NSString stringWithFormat:@"%@\n%@",Name.text,Mobile.text]];
}
-(void)sendContacts:(NSString *)contacts
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSString *findAttendance =[NSString stringWithFormat:@"{\"empid\":\"%@\"}",userid];
    NSString *setAttendance =[NSString stringWithFormat:@"{\"$set\":{\"emgcontact\":%@}}",contacts];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@\n%@", newStr2,findAttendance,setAttendance];
    NSLog(@"emg %@",str);
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:@"empinfo"];
    [requestWraper setPostParamFromString:str];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received----%@",newStr);
}
-(void)onFailure
{
    NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    NSLog(@"emg contact finished");
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
