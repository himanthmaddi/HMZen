//
//  FeedbackViewController.m
//  Safetrax
//
//  Created by Kumaran on 25/01/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CheckFeedbackViewController.h"
CGRect keyboardSize;
@interface FeedbackViewController ()

@end

@implementation FeedbackViewController
@synthesize FeedbackText,CabDriverInfoSegment,CabReportedOntimeSegment,CabTrackingSegment,AccessCardSegment,DriverKnowledgeSegment;
- (void)viewDidLoad {
    [super viewDidLoad];
    FeedbackText.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    keyboardSize = [self.view convertRect:rawFrame fromView:nil];
}
-(void)dismissKeyboard {
    [FeedbackText resignFirstResponder];
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return true;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [self.view endEditing:YES];
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSLog(@"keyonscreen");
    [self.view setFrame:CGRectMake(0,-keyboardSize.size.height,self.view.frame.size.width,self.view.frame.size.height)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
}
-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
}

-(IBAction)Submit:(id)sender
{
    NSString *feedbackString;
    NSString *CabOnTime;
    NSString *CabTrackRating;
    NSString *CorrectInfo;
    NSString *AccessCardRating;
    NSString *DriverKnowledge;
    NSString *userid = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"empid"];
    if([FeedbackText.text length] > 0)
        feedbackString = FeedbackText.text;
    else
        feedbackString = @"";
    CabTrackRating = [CabTrackingSegment titleForSegmentAtIndex:[CabTrackingSegment selectedSegmentIndex]];
    AccessCardRating = [AccessCardSegment titleForSegmentAtIndex:[AccessCardSegment selectedSegmentIndex]];
    DriverKnowledge = [DriverKnowledgeSegment titleForSegmentAtIndex:[DriverKnowledgeSegment selectedSegmentIndex]];
     CorrectInfo = [CabDriverInfoSegment titleForSegmentAtIndex:[CabDriverInfoSegment selectedSegmentIndex]];
     CabOnTime = [CabReportedOntimeSegment titleForSegmentAtIndex:[CabReportedOntimeSegment selectedSegmentIndex]];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:currDate];
    
    NSLog(@"Feedback--->%@\n%@\n%@\n%@\n%@\n%@",feedbackString,CabOnTime,CorrectInfo,AccessCardRating,CabTrackRating,DriverKnowledge);

    NSDictionary *feedback = [NSDictionary dictionaryWithObjectsAndKeys:CorrectInfo,@"cabInfoValidity",CabOnTime,@"timesCalled",AccessCardRating,@"swipeAccessibility",DriverKnowledge,@"driverKnowledge",CabTrackRating,@"cabTracking",feedbackString,@"addnlFeedback",@"iOS-app",@"from",currentTime,@"savedOn",nil];
     // NSDictionary *feedback
    //  NSLog(@"%@--%@---join %@",mutableContactArray,addConntacts,joinContact);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:feedback options:0 error:NULL];
    NSString *feedbackJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json-- %@",feedbackJsonString);
    NSDictionary *review = [NSDictionary dictionaryWithObjectsAndKeys:userid,@"empid",feedback,@"feedback",nil];
    NSData *reviewJsonData = [NSJSONSerialization dataWithJSONObject:review options:0 error:NULL];
    NSString *reviewJsonString = [[NSString alloc] initWithData:reviewJsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json-- %@",reviewJsonString);
    [self SendFeedbackData:reviewJsonString];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)SendFeedbackData:(NSString*)review
{
    
//Sai:  curl -i "http://182.72.184.213:3004/write?dbname=safetrexMeteor&colname=feedback" -XPOST -d $'{"username": "vikki", "password": "83e9ceeba85f1fa9b31e87656c3b260c"}\n{"tripId": "1167","$upsert": "true"}\n{"addToSet":{"reviews": {empid: "009", "feedback": {"cabtracking":"false"}}}'//

    
    NSString *userName = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"password"];
    NSString *userid = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"empid"];
    NSString *tripId = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"LastTripId"];
   
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSString *findParam =[NSString stringWithFormat:@"{\"tripId\":\"%@\"}",tripId];
    NSString *postParam =[NSString stringWithFormat:@"{\"$addToSet\":{\"reviews\":%@}}",review];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@\n%@", newStr2,findParam,postParam];
    NSLog(@"final str %@",str);
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQueryUpsert:@"write" withMethod:@"POST" andColumnName:@"feedback"];
    [requestWraper setPostParamFromString:str];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient execute];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
    [self dismissViewControllerAnimated:YES completion:nil];
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
