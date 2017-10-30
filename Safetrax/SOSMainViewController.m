//
//  SOSMainViewController.m
//  Safetrax
//
//  Created by Kumaran on 03/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "SOSMainViewController.h"
#import "SosViewController.h"
#import "RestClientTask.h"
#import "GCMRequest.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "AppDelegate.h"
#import "SomeViewController.h"
#import <MBProgressHUD.h>


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
NSString *recorderFilePath;
CGRect keyboardFrame;
@interface SOSMainViewController ()
{
    NSURL *temporaryRecFile;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSURLConnection *addressConnection;
    NSURLConnection *sosConnection;
}
@end
@implementation SOSMainViewController
@synthesize messageTextField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tripModel = model;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"``" object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"addressGot"];
    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate updateLocation];
}
-(BOOL)connectedToInternet
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}
- (void)viewDidLoad {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    messageTextField.delegate = self;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    [recorder setDelegate:self];
    [[NSUserDefaults standardUserDefaults] setObject:tripModel.tripid forKey:@"tripid"];
    DataDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary* waypointdict;
    NSArray *SOSWaypointsDetails = tripModel.cabWaypoints;
    NSArray *colleague;
    flattenArray = [[NSMutableArray alloc] init];
    NSMutableArray *allEmployees = [[NSMutableArray alloc] init];
    for(int i=0;i<[SOSWaypointsDetails count];i++)
    {
        waypointdict =[tripModel.cabWaypoints objectAtIndex:i];
        colleague =waypointdict[@"employeesAssigned"];
        [allEmployees addObject:waypointdict[@"employeesAssigned"]];
    }
    for(NSArray *array in allEmployees)
    {
        [flattenArray addObjectsFromArray: array];
    }
    [flattenArray removeObject: @""];
    [flattenArray removeObject: [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
    NSArray *nameArray = [[[NSUserDefaults standardUserDefaults]
                           arrayForKey:@"emgcontact"] valueForKeyPath:@"name"];
    NSArray *phoneArray = [[[NSUserDefaults standardUserDefaults]
                            arrayForKey:@"emgcontact"] valueForKeyPath:@"phone"];
    NSMutableArray *contacts =[[NSMutableArray alloc] init];
    for(int i=0;i<[nameArray count];i++)
    {
        NSString *emgcontact =[NSString stringWithFormat:@"%@\n%@",nameArray[i],phoneArray[i]];
        [contacts addObject:emgcontact];
    }
    [DataDictionary setObject:contacts forKey:@"Emergency Info"];
    NSArray* noPassengers = [NSArray arrayWithObjects: @"", nil];
    [DataDictionary setObject:noPassengers forKey:@"Co Passengers"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    [flattenArray removeObject: @""];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:flattenArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *new = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *ids =[NSString stringWithFormat:@"{\"empid\":{\"$in\":%@}}",new];
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSMutableDictionary *code_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:ids, @"empid",nil];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSData* config_json2 = [NSJSONSerialization dataWithJSONObject:code_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *jsonStr= [NSString stringWithFormat:@"%@\n%@", newStr2, ids];
    NSLog(@"%@",jsonStr);
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"query" withMethod:@"POST" andColumnName:@"empinfo"];
    [requestWraper setPostParamFromString:jsonStr];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    _responseData = [[NSMutableData alloc] init];
    //    [RestClient execute];
    [super viewDidLoad];
    sosController = [[SosViewController alloc] initWithNibName:@"SosViewController" bundle:nil model:tripModel withDataDictionary:DataDictionary];
    
}
//Declare a delegate, assign your textField to the delegate and then include these methods
-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
}
-(void)dismissKeyboard {
    [messageTextField resignFirstResponder];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
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
    [self.view setFrame:CGRectMake(0,-keyboardFrame.size.height,self.view.frame.size.width,self.view.frame.size.height)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
}
-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender
{
    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate stopUpdateLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [messageTextField resignFirstResponder];
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self sendSosMessage:textField.text withFileAttached:NO fileName:@""];
    textField.text = @"";
    //    [self presentViewController:sosController animated:YES completion:nil];
    return YES;
}
-(IBAction)messageOne:(id)sender
{
    if ([self connectedToInternet]){
        NSString *message =@"Driver Misbehaving";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageTwo:(id)sender
{
    if ([self connectedToInternet]){
        NSString *message =@"Unknown People in Cab";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageThree:(id)sender
{
    if ([self connectedToInternet]){
        NSString *message =@"Cab Taking Different Route";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageFour:(id)sender
{
    if ([self connectedToInternet]){
        NSString *message =@"Drunken Driving";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageFive:(id)sender{
    if ([self connectedToInternet]){
        NSString *message =@"Met with an Accident";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageSix:(id)sender{
    if ([self connectedToInternet]){
        NSString *message =@"Feeling unsafe , stay on call with me";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageSeven:(id)sender{
    if ([self connectedToInternet]){
        NSString *message =@"Companion Misbehaving";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)messageEight:(id)sender{
    if ([self connectedToInternet]){
        NSString *message =@"Medical Emergency";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendSosMessage:message withFileAttached:NO fileName:@""];
        //        [self presentViewController:sosController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)sendSosMessage:(NSString *)message withFileAttached:(BOOL)fileAttached fileName:(NSString *)fileName
{
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
        double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
        NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",[[NSNumber numberWithDouble:latitude] stringValue],[[NSNumber numberWithDouble:longitude] stringValue]];
        NSURL *url = [NSURL URLWithString:strin];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        addressConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        if ([self connectedToInternet]){
            [addressConnection start];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"message"];
        [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"fileName"];
        [[NSUserDefaults standardUserDefaults] setBool:fileAttached forKey:@"fileAttached"];
    }else{
        NSLog(@"denied");
        [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"latitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"longitude"];
        NSString *title;
        title = @"Location Services Not Enabled!";
        NSString *messageTitle = @"Please Turn On Location Services to 'While using the app' In The Location Services Settings";
        
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:title  message:messageTitle  preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Send anyway" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
            double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
            ////    NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",longitude,latitude];
            NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",[[NSNumber numberWithDouble:latitude] stringValue],[[NSNumber numberWithDouble:longitude] stringValue]];
            NSURL *url = [NSURL URLWithString:strin];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            addressConnection = [NSURLConnection connectionWithRequest:request delegate:self];
            if ([self connectedToInternet]){
                [addressConnection start];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"message"];
            [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"fileName"];
            [[NSUserDefaults standardUserDefaults] setBool:fileAttached forKey:@"fileAttached"];        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Turn On" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
    //    locationManager = nil;
    //    locationManager = [[CLLocationManager alloc] init];
    //    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    //    locationManager.distanceFilter=kCLDistanceFilterNone;
    //    if(![CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    //    {
    //        NSLog(@"denied");
    //        [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"latitude"];
    //        [[NSUserDefaults standardUserDefaults] setDouble:0.0f forKey:@"longitude"];
    //        NSString *title;
    //        title = @"Location Services Not Enabled!";
    //        NSString *message = @"Please  Turn On Location Services In The Location Services Settings";
    //
    //        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:title  message:message  preferredStyle:UIAlertControllerStyleAlert];
    //
    //        [alertController addAction:[UIAlertAction actionWithTitle:@"Send anyway" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //            double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    //            double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
    //            ////    NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",longitude,latitude];
    //            NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",[[NSNumber numberWithDouble:latitude] stringValue],[[NSNumber numberWithDouble:longitude] stringValue]];
    //            NSURL *url = [NSURL URLWithString:strin];
    //            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    //            [request setHTTPMethod:@"POST"];
    //            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //
    //            addressConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    //            if ([self connectedToInternet]){
    //                [addressConnection start];
    //            }else{
    //                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //                [alert show];
    //            }
    //
    //            [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"message"];
    //            [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"fileName"];
    //            [[NSUserDefaults standardUserDefaults] setBool:fileAttached forKey:@"fileAttached"];        }]];
    //        [alertController addAction:[UIAlertAction actionWithTitle:@"Turn On" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    //            [[UIApplication sharedApplication] openURL:settingsURL];
    //        }]];
    //
    //        [self presentViewController:alertController animated:YES completion:nil];
    //    }
    //    else
    //    {
    //    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    //    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
    //    ////    NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",longitude,latitude];
    //    NSString *strin = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",[[NSNumber numberWithDouble:latitude] stringValue],[[NSNumber numberWithDouble:longitude] stringValue]];
    //    NSURL *url = [NSURL URLWithString:strin];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    //    [request setHTTPMethod:@"POST"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //
    //    addressConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    //    if ([self connectedToInternet]){
    //        [addressConnection start];
    //    }else{
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
    //
    //    [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"message"];
    //    [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"fileName"];
    //    [[NSUserDefaults standardUserDefaults] setBool:fileAttached forKey:@"fileAttached"];
    //    }
}
-(IBAction)startRecording:(id)sender
{
    //#ifndef __IPHONE_7_0
    //    typedef void (^PermissionBlock)(BOOL granted);
    //#endif
    //    PermissionBlock permissionBlock = ^(BOOL granted) {
    //        if (granted)
    //        {
    //            NSLog(@"permission granted for recording");
    //            [self record];
    //        }
    //        else
    //        {
    //            // Warn no access to microphone
    //            UIAlertView *myAlert = [[UIAlertView alloc]
    //                                    initWithTitle:@"Permission needed"
    //                                    message:@"Enable microphone access in settings"
    //                                    delegate:self
    //                                    cancelButtonTitle:@"Cancel"
    //                                    otherButtonTitles:@"Settings",nil];
    //            myAlert.tag = 3333;
    //            [myAlert show];
    //
    //        }
    //    };
    //    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    //    {
    //        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
    //                                              withObject:permissionBlock];
    //    }
    //    else
    //    {
    //        [self record];
    //    }
}
-(IBAction)stopRecording:(id)sender
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Voice Message" message:@"Recording....Send SoS Voice Message ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
            myAlert.tag = 11;
            [myAlert show];
            [self record];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Permission needed"
                                    message:@"Enable microphone access in settings"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Settings",nil];
            myAlert.tag = 3333;
            [myAlert show];
            });
        }
    }];
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11){
        if (buttonIndex == 1) {
            [recorder stop];
            [self playBack];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSData *audioData = [[NSData alloc] initWithContentsOfURL:[prefs URLForKey:@"safetrackAudio"]];
            [self sendAudio:audioData];
        }
    }
}
- (IBAction) record
{
    NSError *error;
    AudioFileID mRecordFile;
    AudioStreamBasicDescription audioFormat;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue: [NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [settings setValue:  [NSNumber numberWithInt: AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    NSString *pathToSave = [documentPath_ stringByAppendingPathComponent:[self dateString]];
    NSURL *url = [NSURL fileURLWithPath:pathToSave];//FILEPATH];
    NSLog(@"url path to saving %@",url);
    OSStatus status = AudioFileCreateWithURL((__bridge CFURLRef)url, kAudioFileAIFFType, &audioFormat, kAudioFileFlags_EraseFile, &mRecordFile);
    error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                code:status
                            userInfo:nil];
    NSLog(@"Error: %@", [error description]);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setURL:url forKey:@"safetrackAudio"];
    [prefs synchronize];
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    [recorder prepareToRecord];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:NULL];
    [recorder record];
}
-(IBAction)playBack
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    temporaryRecFile = [prefs URLForKey:@"safetrackAudio"];
    NSData *audioData = [[NSData alloc] initWithContentsOfURL:[prefs URLForKey:@"safetrackAudio"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:temporaryRecFile error:nil];
    player.delegate = self;
    [player setNumberOfLoops:0];
    player.volume = 3;
    [player prepareToPlay];
}
- (NSString *) dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".wav"];
}
- (NSString *) dateStringJPG
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".jpg"];
}
-(IBAction)takePictureWithCamera {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusAuthorized) {
                // do your logic
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:NULL];
            } else if(authStatus == AVAuthorizationStatusDenied){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Permision needed" message:@"Go to settings and enable camera" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                [alert show];
                [alert setTag:3333];
            } else if(authStatus == AVAuthorizationStatusRestricted){
                // restricted
            } else if(authStatus == AVAuthorizationStatusNotDetermined){
                // not determined
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){
                        NSLog(@"Granted access");
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:picker animated:YES completion:NULL];
                        
                    } else {
                        NSLog(@"Not granted access");
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Permision needed" message:@"Go to settings and enable camera" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                        [alert show];
                        [alert setTag:3333];
                    }
                }];
            }
        });
    });
    
    
}
-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* image = [info objectForKey: UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self sendimage:image];
}
-(void)sendimage:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *Datestr = [self dateStringJPG];
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        NSString *str;
        if ([Port isEqualToString:@"-1"]){
            str =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@&filename=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],@"gridfs",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"sos_files",Datestr];
        }else{
            str =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@&filename=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],@"gridfs",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"sos_files",Datestr];
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
        //    NSString* FileParamConstant = @"file";
        NSURL* requestURL = [NSURL URLWithString:str];
        request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:60];
        [request setHTTPMethod:@"PUT"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        
        NSMutableData *body = [NSMutableData data];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        if (imageData) {
            //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            //        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            //        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [request setHTTPBody:body];
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setURL:requestURL];
        
        NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
        NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
        NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
        [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(data.length > 0)
            {
                NSLog(@"success jpg %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            else
            {
                NSLog(@"---xxerror %@-%@",data,error);
            }
        }];
        [self sendSosMessage:@"Image" withFileAttached:YES fileName:Datestr];
        [self presentViewController:sosController animated:YES completion:nil];
    });
}
-(void)sendAudio:(NSData *)audioData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *Datestr = [self dateString];
        
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        NSString *str;
        if ([Port isEqualToString:@"-1"]){
            str =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@&filename=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],@"gridfs",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"sos_files",Datestr];
        }else{
            str =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@&filename=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],@"gridfs",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"sos_files",Datestr];
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
        NSURL* requestURL = [NSURL URLWithString:str];
        request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setHTTPMethod:@"PUT"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        if (audioData) {
            //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"audio.mp3\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            //        [body appendData:[@"Content-Type: audio/mpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:audioData];
            //        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setURL:requestURL];
        NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
        NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
        NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
        [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(data.length > 0)
            {
                NSLog(@"success wav %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            else
            {
                NSLog(@"error %@-%@",data,error);
            }
        }];
        [self sendSosMessage:@"AudioFile" withFileAttached:YES fileName:Datestr];
        [self presentViewController:sosController animated:YES completion:nil];
    });
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
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
    NSMutableArray *coPassenger =[[NSMutableArray alloc] init];
    NSArray *info_array= [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    for (NSDictionary *info in info_array) {
        for(int i=0;i<[flattenArray count];i++)
        {
            if([info[@"empid"]isEqualToString:flattenArray[i]]){
                NSString *strName =info[@"name"];
                NSString *strPhnone =info[@"phonenum"];
                [coPassenger addObject:[NSString stringWithFormat:@"%@\n%@",strName,strPhnone]];
            }
        }
    }
    if([coPassenger count] >0){
        [DataDictionary setObject:coPassenger forKey:@"Co Passengers"];
        [sosController loadTable];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([CLLocationManager locationServicesEnabled]){
        NSError *error;
        //    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]);
        if (data != nil){
            NSDictionary *resultsDictoinary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"%@",resultsDictoinary);
            if ([resultsDictoinary valueForKey:@"results"]){
                NSArray *adressArray = [resultsDictoinary valueForKey:@"results"];
                if (adressArray.count){
                    NSDictionary *firstComponent = [adressArray objectAtIndex:0];
                    NSString *exactAddress = [firstComponent valueForKey:@"formatted_address"];
                    [[NSUserDefaults standardUserDefaults] setValue:exactAddress forKey:@"address"];
                }else{
                    [[NSUserDefaults standardUserDefaults] setValue:@"NA" forKey:@"address"];
                }
            }
            if (connection == addressConnection){
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"addressGot"]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"addressGot"];
                    [self sendSOSFile:[[NSUserDefaults standardUserDefaults] valueForKey:@"message"] withFileAttached:[[NSUserDefaults standardUserDefaults] boolForKey:@"fileAttached"] fileName:[[NSUserDefaults standardUserDefaults] valueForKey:@"fileName"] withAddress:[[NSUserDefaults standardUserDefaults] valueForKey:@"address"]];
                }
            }
            if (connection == sosConnection){
                NSLog(@"raised sos");
                NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"message"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                [self presentViewController:sosController animated:YES completion:nil];
            }
        }else{
            [[NSUserDefaults standardUserDefaults] setValue:@"NA" forKey:@"address"];
            if (connection == addressConnection){
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"addressGot"]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"addressGot"];
                    [self sendSOSFile:[[NSUserDefaults standardUserDefaults] valueForKey:@"message"] withFileAttached:[[NSUserDefaults standardUserDefaults] boolForKey:@"fileAttached"] fileName:[[NSUserDefaults standardUserDefaults] valueForKey:@"fileName"] withAddress:[[NSUserDefaults standardUserDefaults] valueForKey:@"address"]];
                }
            }
        }
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"NA" forKey:@"address"];
        if (connection == addressConnection){
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"addressGot"]){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"addressGot"];
                [self sendSOSFile:[[NSUserDefaults standardUserDefaults] valueForKey:@"message"] withFileAttached:[[NSUserDefaults standardUserDefaults] boolForKey:@"fileAttached"] fileName:[[NSUserDefaults standardUserDefaults] valueForKey:@"fileName"] withAddress:[[NSUserDefaults standardUserDefaults] valueForKey:@"address"]];
            }
        }
        if (connection == sosConnection){
            NSLog(@"raised sos");
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"message"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self presentViewController:sosController animated:YES completion:nil];
        }
    }
}
-(void)sendSOSFile:(NSString *)message withFileAttached:(BOOL)fileAttached fileName:(NSString *)fileName withAddress:(NSString *)address{
    
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
    
    NSLog(@"%f%f",[[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"],[[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"]);
    long double today = [[NSDate date] timeIntervalSince1970];
    NSString *str1 = [NSString stringWithFormat:@"%.Lf",today];
    long double mine = [str1 doubleValue]*1000;
    NSDecimalNumber *todayTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
    NSString *colName;
    colName = @"sosmessages";
    NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    NSDictionary *finalDictionary;
    NSArray *coordinatesArray;
    coordinatesArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:longitude],[NSNumber numberWithDouble:latitude], nil];
    if (fileAttached){
        finalDictionary= @{@"employeeId":employeeId,@"message":@"File",@"mode":@"ios-app",@"time":todayTime,@"coordinates":coordinatesArray,@"address":address,@"filename":fileName};
    }else{
        finalDictionary= @{@"employeeId":employeeId,@"message":message,@"mode":@"ios-app",@"time":todayTime,@"coordinates":coordinatesArray,@"address":address};
    }
    
    NSLog(@"sending connection");
    
    NSLog(@"%@",finalDictionary);
    
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
        url =[NSString stringWithFormat:@"%@://%@/triggersosapp?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/triggersosapp?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
    }
    NSURL *URL =[NSURL URLWithString:url];
    NSLog(@"%@",URL);
    NSMutableURLRequest *NSRequest = [[NSMutableURLRequest alloc]initWithURL:URL];
    [NSRequest setHTTPMethod:@"POST"];
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalDictionary options:kNilOptions error:&error];
    [NSRequest setHTTPBody:jsonData];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [NSRequest setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
    sosConnection = [NSURLConnection connectionWithRequest:NSRequest delegate:self];
    if ([self connectedToInternet]){
        [sosConnection start];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    [messageTextField resignFirstResponder];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3333){
        if (buttonIndex == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    if (alertView.tag == 2002){
        if (buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                SomeViewController *some = [[SomeViewController alloc]init];
                [self presentViewController:some animated:YES completion:nil];
            });
        }
    }
}

-(void)tripCompletedNotification:(NSNotification *)sender{
    NSDictionary *myDictionary = (NSDictionary *)sender.object;
    NSLog(@"%@",myDictionary);
    if ([sender.name isEqualToString:@"tripCompleted"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tripFeedbackForm"]){
                SomeViewController *some1 = [[SomeViewController alloc]init];
                [some1 getTripId:[myDictionary valueForKey:@"tripId"]];
                [self presentViewController:some1 animated:YES completion:nil];
            }else{
                
            }
        });
        
    }
}
-(void)sendSOS{
    
}
@end

