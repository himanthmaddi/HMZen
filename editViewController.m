//
//  editViewController.m
//  Commuter
//
//  Created by Himanth Maddi on 21/12/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "editViewController.h"
#import <MBProgressHUD.h>
#import "SomeViewController.h"
#import "ScheduleViewController.h"
#import "SessionValidator.h"
#import "SomeViewController.h"
#import "AppDelegate.h"
#import <FirebaseMessaging/FirebaseMessaging.h>

@interface editViewController ()
{
    UIToolbar *loginToolBar;
    UIToolbar *logoutToolBar;
    UIToolbar *officeToolBar;
    
    UIPickerView *loginPickerView;
    UIPickerView *logoutPickerView;
    UIPickerView *officePickerView;
    
    NSInteger indexSelectedForLogin;
    
    
}

@end

@implementation editViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([_loginDoubleString isEqualToString:@"OFF"]){
        _loginTextField.text = @"OFF";
        [[NSUserDefaults standardUserDefaults] setObject:@"OFF" forKey:@"loginLabelText"];
        
    }else{
        long double millisecondsTime = [_loginDoubleString doubleValue];
        NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:(millisecondsTime/1000)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"dd MMMM HH:mm"];
        NSString *dateInString = [formatter stringFromDate:finalDate];
        
        _loginTextField.text = dateInString;
        [[NSUserDefaults standardUserDefaults] setObject:dateInString forKey:@"loginLabelText"];
    }
    
    if ([_logoutDoubleString isEqualToString:@"OFF"]){
        _logoutTextField.text = @"OFF";
        [[NSUserDefaults standardUserDefaults] setObject:@"OFF" forKey:@"logoutLabelText"];
        
    }else{
        
        long double millisecondsTime = [_logoutDoubleString doubleValue];
        NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:(millisecondsTime/1000)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"dd MMMM HH:mm"];
        NSString *dateInString = [formatter stringFromDate:finalDate];
        
        _logoutTextField.text = dateInString;
        [[NSUserDefaults standardUserDefaults] setObject:dateInString forKey:@"logoutLabelText"];
        
    }
    
    
    
    
    _loginCancelButton.hidden = YES;
    _logoutCancelButton.hidden = YES;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYY-MM-dd HH:mm:ss"];
    double expireTime = [[[NSUserDefaults standardUserDefaults]stringForKey:@"expiredTime"] doubleValue];
    NSTimeInterval seconds = expireTime / 1000;
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSDate *date = [NSDate date];
    NSComparisonResult result = [date compare:expireDate];
    
    if(result == NSOrderedDescending || result == NSOrderedSame)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"azureAuthType"]){
            for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fcmtokenpushed"];
            [[FIRMessaging messaging] unsubscribeFromTopic:@"/topics/global"];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ShowFeedbackForm"];
            AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate dismiss_delegate:nil];
            [self.view removeFromSuperview];
        }else{
            SessionValidator *validator = [[SessionValidator alloc]init];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                NSLog(@"%@",result);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"no refresh");
    }
    
    
    _officeTextField.text = _officeNameString;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [_scrollView addGestureRecognizer:tapRecognizer];
    
    loginToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *loginDone  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(loginDone:)];
    UIBarButtonItem *loginSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *loginCancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(loginCancel:)];
    loginToolBar.items = @[loginCancel,loginSpace,loginDone];
    
    logoutToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *logoutDone  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(logoutDone:)];
    UIBarButtonItem *logoutSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *logoutCancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(logoutCancel:)];
    logoutToolBar.items = @[logoutCancel,logoutSpace,logoutDone];
    
    officeToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *officeDone  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(officeDone:)];
    UIBarButtonItem *officeSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *officeCancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(officeCancel:)];
    officeToolBar.items = @[officeCancel,officeSpace,officeDone];
    
    loginPickerView = [[UIPickerView alloc]initWithFrame:CGRectZero];
    loginPickerView.delegate = self;
    loginPickerView.dataSource = self;
    
    logoutPickerView = [[UIPickerView alloc]initWithFrame:CGRectZero];
    logoutPickerView.delegate = self;
    logoutPickerView.dataSource = self;
    
    officePickerView = [[UIPickerView alloc]initWithFrame:CGRectZero];
    officePickerView.delegate = self;
    officePickerView.dataSource = self;
    
    _loginTextField.inputView = loginPickerView;
    _logoutTextField.inputView = logoutPickerView;
    _officeTextField.inputView = officePickerView;
    
    _loginTextField.inputAccessoryView = loginToolBar;
    _logoutTextField.inputAccessoryView = logoutToolBar;
    _officeTextField.inputAccessoryView = officeToolBar;
    
    [_loginTextField setTintColor:[UIColor clearColor]];
    [_logoutTextField setTintColor:[UIColor clearColor]];
    [_officeTextField setTintColor:[UIColor clearColor]];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated{
    [_loginTextField resignFirstResponder];
    [_logoutTextField resignFirstResponder];
    [_officeTextField resignFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripCompletedNotification:) name:@"tripCompleted" object:nil];
    
    self.title = @"Modify Schedule";
    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonClicked:)];
    self.navigationItem.rightBarButtonItem = deleteBarButtonItem;
}
-(void)barButtonClicked:(UIBarButtonItem *)sender{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option to delete schedule" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Login schedule",
                            @"Logout schedule",
                            nil];
    popup.tag = 1;
    [popup showInView:self.view];
    
}
-(void)tapped:(UIGestureRecognizer *)sender{
    [_loginTextField resignFirstResponder];
    [_logoutTextField resignFirstResponder];
    [_officeTextField resignFirstResponder];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == loginPickerView){
        return _loginTimesArray.count;
    }
    if (pickerView == officePickerView){
        return _officesArray.count;
    }
    if (pickerView == logoutPickerView){
        return _logoutTimesArray.count;
    }
    return nil;
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //    return waypointNamesArray[row];
    if (pickerView == loginPickerView){
        return _loginTimesArray[row];
    }
    if (pickerView == officePickerView){
        return _officesArray[row];
    }
    if (pickerView == logoutPickerView){
        return _logoutTimesArray[row];
    }
    return nil;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if (textField == _loginTextField){
        if (_canLoginRevised){
            if ([_loginDoubleString isEqualToString:@"OFF"]){
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit"];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getLoginTimes];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
                
            }else{
                NSDate *loginTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_loginDoubleString doubleValue]/1000)];
                NSLog(@"%@",loginTimeAsDate);
                
                NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:loginTimeAsDate];
                NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:loginTimeAsDate];
                NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
                NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:loginTimeAsDate];
                NSLog(@"%@",destinationDate);
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"dd MMMM HH:mm"];
                [formatter setTimeZone:[NSTimeZone systemTimeZone]];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSString *textfieldText = [formatter stringFromDate:destinationDate];
                
                NSDate *cutoffLoginTime = [destinationDate dateByAddingTimeInterval:(-([_loginCutoffTime doubleValue]/1000))];
                NSLog(@"%@",cutoffLoginTime);
                
                NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
                NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
                NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
                NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
                NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
                NSLog(@"%@",destinationDate1);
                
                if ([destinationDate1 compare:cutoffLoginTime] == NSOrderedAscending){
                    NSLog(@"yes can edit");
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit"];
                    
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getLoginTimes];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                }else{
                    NSLog(@"no");
                    _loginTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                    _loginTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                    _loginTextField.text = textfieldText;
                    _loginTextField.textColor = [UIColor grayColor];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit"];
                    [[NSUserDefaults standardUserDefaults] setValue:_loginDoubleString forKey:@"loginDoubleValue"];
                }
                
            }
            
        }else{
            NSLog(@"%@",[NSNumber numberWithBool:_isRevised]);
            
            if (_isRevised){
                _loginTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                _loginTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                _loginTextField.text = _loginTime;
                [[NSUserDefaults standardUserDefaults] setValue:_logoutDoubleString forKey:@"logoutDoubleValue"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit"];
                
                
            }else{
                if ([_loginDoubleString isEqualToString:@"OFF"]){
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit"];
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getLoginTimes];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                }else{
                    NSDate *loginTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_loginDoubleString doubleValue]/1000)];
                    NSLog(@"%@",loginTimeAsDate);
                    
                    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:loginTimeAsDate];
                    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:loginTimeAsDate];
                    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
                    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:loginTimeAsDate];
                    NSLog(@"%@",destinationDate);
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"dd MMMM HH:mm"];
                    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    NSString *textfieldText = [formatter stringFromDate:destinationDate];
                    
                    NSDate *cutoffLoginTime = [destinationDate dateByAddingTimeInterval:(-([_loginCutoffTime doubleValue]/1000))];
                    NSLog(@"%@",cutoffLoginTime);
                    
                    NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
                    NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
                    NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
                    NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
                    NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
                    NSLog(@"%@",destinationDate1);
                    
                    
                    if ([destinationDate1 compare:cutoffLoginTime] == NSOrderedAscending){
                        NSLog(@"yes can edit");
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit"];
                        
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self getLoginTimes];
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                            });
                        });
                        
                    }else{
                        NSLog(@"no");
                        _loginTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                        _loginTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                        _loginTextField.text = textfieldText;
                        _loginTextField.textColor = [UIColor grayColor];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit"];
                        [[NSUserDefaults standardUserDefaults] setValue:_loginDoubleString forKey:@"loginDoubleValue"];
                    }
                    
                }
                
            }
        }
        
    }
    
    if (textField == _logoutTextField){
        if (_canLogoutRevised){
            if ([_logoutDoubleString isEqualToString:@"OFF"])
            {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit1"];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getLogoutTimes];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
                
            }else{
                NSDate *loginTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_logoutDoubleString doubleValue]/1000)];
                NSLog(@"%@",loginTimeAsDate);
                
                NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:loginTimeAsDate];
                NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:loginTimeAsDate];
                NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
                NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:loginTimeAsDate];
                NSLog(@"%@",destinationDate);
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"dd MMMM HH:mm"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                
                NSString *textfieldText = [formatter stringFromDate:destinationDate];
                
                NSDate *cutoffLoginTime = [destinationDate dateByAddingTimeInterval:(-([_logoutCutoffTime doubleValue]/1000))];
                NSLog(@"%@",cutoffLoginTime);
                
                NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
                NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
                NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
                NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
                NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
                NSLog(@"%@",destinationDate1);
                
                if ([destinationDate1 compare:cutoffLoginTime] == NSOrderedAscending){
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit1"];
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getLogoutTimes];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                }else{
                    NSLog(@"no");
                    _logoutTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                    _logoutTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                    _logoutTextField.text = textfieldText;
                    _logoutTextField.textColor = [UIColor grayColor];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit1"];
                    [[NSUserDefaults standardUserDefaults] setValue:_logoutDoubleString forKey:@"logoutDoubleValue"];
                }
                
                
            }
            
        }else{
            if (_isRevised){
                _logoutTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                _logoutTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                _logoutTextField.text = _logoutTime;
                [[NSUserDefaults standardUserDefaults] setValue:_logoutDoubleString forKey:@"logoutDoubleValue"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit1"];
                
            }else{
                if ([_logoutDoubleString isEqualToString:@"OFF"])
                {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit1"];
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getLogoutTimes];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                }else{
                    NSDate *loginTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_logoutDoubleString doubleValue]/1000)];
                    NSLog(@"%@",loginTimeAsDate);
                    
                    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:loginTimeAsDate];
                    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:loginTimeAsDate];
                    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
                    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:loginTimeAsDate];
                    NSLog(@"%@",destinationDate);
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"dd MMMM HH:mm"];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    
                    NSString *textfieldText = [formatter stringFromDate:destinationDate];
                    
                    NSDate *cutoffLoginTime = [destinationDate dateByAddingTimeInterval:(-([_logoutCutoffTime doubleValue]/1000))];
                    NSLog(@"%@",cutoffLoginTime);
                    
                    NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
                    NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
                    NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
                    NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
                    NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
                    NSLog(@"%@",destinationDate1);
                    
                    if ([destinationDate1 compare:cutoffLoginTime] == NSOrderedAscending){
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit1"];
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self getLogoutTimes];
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                            });
                        });
                        
                    }else{
                        NSLog(@"no");
                        _logoutTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                        _logoutTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                        _logoutTextField.text = textfieldText;
                        _logoutTextField.textColor = [UIColor grayColor];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit1"];
                        [[NSUserDefaults standardUserDefaults] setValue:_logoutDoubleString forKey:@"logoutDoubleValue"];
                        
                    }
                }
            }
        }
    }
    if (textField == _officeTextField){
        if ([_loginDoubleString isEqualToString:@"OFF"]){
            if ([_logoutDoubleString isEqualToString:@"OFF"]){
                
            }else{
                NSDate *logoutDate = [NSDate dateWithTimeIntervalSince1970:([_logoutDoubleString doubleValue]/1000)];
                NSDate *twoHoursBeforeDate = [logoutDate dateByAddingTimeInterval:(-([_logoutCutoffTime doubleValue]/1000))];
                if ([[NSDate date] compare:twoHoursBeforeDate] == NSOrderedAscending){
                    
                }else{
                    _officeTextField.textColor = [UIColor grayColor];
                    _officeTextField.text = _officeNameString;
                    _logoutTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                    _logoutTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
                }
                
            }
        }else{
            NSDate *loginDate = [NSDate dateWithTimeIntervalSince1970:([_loginDoubleString doubleValue]/1000)];
            NSDate *eightHoursBeforeDate = [loginDate dateByAddingTimeInterval:(-([_loginCutoffTime doubleValue]/1000))];
            if ([[NSDate date] compare:eightHoursBeforeDate] == NSOrderedAscending){
                
            }else{
                _officeTextField.textColor = [UIColor grayColor];
                _officeTextField.text = _officeNameString;
                _officeTextField.inputView = [[UIView alloc]initWithFrame:CGRectZero];
                _officeTextField.inputAccessoryView = [[UIView alloc]initWithFrame:CGRectZero];
            }
            
            
        }
    }
}


-(IBAction)saveButtonClicked:(id)sender{
    
    if ([_loginTextField.text isEqualToString:_loginTime] && [_logoutTextField.text isEqualToString:_logoutTime] && [_officeTextField.text isEqualToString:_officeNameString]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"No changes from your existing schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        
        if ((![_loginTextField.text isEqualToString:@"OFF"] && ![_loginTextField.text isEqualToString:@""]) && [_logoutTextField.text isEqualToString:@"OFF"]){
            if (![_logoutDoubleString isEqualToString:@"OFF"]){
                NSLog(@"%f",[[[NSUserDefaults standardUserDefaults] stringForKey:@"loginDoubleValue"] doubleValue]);
                NSLog(@"%f",[_logoutDoubleString doubleValue]);
                if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"loginDoubleValue"] doubleValue] > [_logoutDoubleString doubleValue]){
                    [self goAheadToSaveRoster];
                }else{
                    NSLog(@"Cannot save these");
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Login cannot be greater than logout time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }else{
                [self goAheadToSaveRoster];
            }
        }
        else if ((![_logoutTextField.text isEqualToString:@"OFF"] && ![_logoutTextField.text isEqualToString:@""]) && [_loginTextField.text isEqualToString:@"OFF"]){
            if (![_loginDoubleString isEqualToString:@"OFF"]){
                NSLog(@"%f",[[[NSUserDefaults standardUserDefaults] stringForKey:@"logoutDoubleValue"] doubleValue]);
                NSLog(@"%f",[_loginDoubleString doubleValue]);
                if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"logoutDoubleValue"] doubleValue] < [_loginDoubleString doubleValue]){
                    [self goAheadToSaveRoster];
                }else{
                    NSLog(@"Cannot save these");
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Logout cannot be less than login time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }else{
                [self goAheadToSaveRoster];
            }
        }
        else if ((![_loginTextField.text isEqualToString:@"OFF"] && ![_loginTextField.text isEqualToString:@""]) && (![_logoutTextField.text isEqualToString:@"OFF"] && ![_logoutTextField.text isEqualToString:@""])){
            NSLog(@"%f",[[[NSUserDefaults standardUserDefaults] stringForKey:@"logoutDoubleValue"] doubleValue]);
            NSLog(@"%f",[[[NSUserDefaults standardUserDefaults] stringForKey:@"loginDoubleValue"] doubleValue]);
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"logoutDoubleValue"] doubleValue] < [[[NSUserDefaults standardUserDefaults] stringForKey:@"loginDoubleValue"] doubleValue]){
                NSLog(@"Cannot Save the values");
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Login cannot be greater than logout time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                [self goAheadToSaveRoster];
            }
            
        }else{
            [self goAheadToSaveRoster];
        }
    }
    
}
/////////////////////////////////////////actions for toolbar items//////////////////////////////////

-(void)loginCancel:(UIBarButtonItem *)sender{
    [_loginTextField resignFirstResponder];
}
-(void)loginDone:(UIBarButtonItem *)sender{
    indexSelectedForLogin = [loginPickerView selectedRowInComponent:0];
    NSLog(@"%li",(long)indexSelectedForLogin);
    [[NSUserDefaults standardUserDefaults] setValue:[_loginDoubleValues objectAtIndex:indexSelectedForLogin] forKey:@"loginDoubleValue"];
    _loginTextField.text = [_loginTimesArray objectAtIndex:indexSelectedForLogin];
    //    _logoutTextField.text = @"";
    [_loginTextField resignFirstResponder];
}
-(void)logoutCancel:(UIBarButtonItem *)sender{
    [_logoutTextField resignFirstResponder];
}
-(void)logoutDone:(UIBarButtonItem *)sender{
    NSInteger path = [logoutPickerView selectedRowInComponent:0];
    NSLog(@"%li",(long)path);
    [[NSUserDefaults standardUserDefaults] setValue:[_logoutDoubleValues objectAtIndex:path] forKey:@"logoutDoubleValue"];
    _logoutTextField.text = [_logoutTimesArray objectAtIndex:path];
    [_logoutTextField resignFirstResponder];
}
-(void)officeCancel:(UIBarButtonItem *)sender{
    [_officeTextField resignFirstResponder];
}
-(void)officeDone:(UIBarButtonItem *)sender{
    
    NSInteger path = [officePickerView selectedRowInComponent:0];
    NSLog(@"%li",(long)path);
    _officeTextField.text = [_officesArray objectAtIndex:path];
    [_officeTextField resignFirstResponder];
    
    NSString *defaultOfficeName = [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeName"];
    
    NSString *officeTextFieldText = _officeTextField.text;
    
    
    
    if ([officeTextFieldText isEqualToString:_officeNameString]){
        _loginTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"loginLabelText"];
        _logoutTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"logoutLabelText"];
        [[NSUserDefaults standardUserDefaults] setValue:_officeTextField.text forKey:@"defaultOfficeName"];
        int index = [_officesArray indexOfObject:_officeTextField.text];
        NSString *officeId = [_officeIdsArray objectAtIndex:index];
        [[NSUserDefaults standardUserDefaults] setValue:officeId forKey:@"defaultOfficeId"];
    }
    else if (![defaultOfficeName isEqualToString:officeTextFieldText]){
        _logoutTextField.text = @"";
        _loginTextField.text = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_officeTextField.text forKey:@"defaultOfficeName"];
        int index = [_officesArray indexOfObject:_officeTextField.text];
        NSString *officeId = [_officeIdsArray objectAtIndex:index];
        [[NSUserDefaults standardUserDefaults] setValue:officeId forKey:@"defaultOfficeId"];
        
    }
}


//////////////////////////////////////////Getting schedule timings here////////////////////////////


-(void)getLoginTimes;
{
    if ([self connectedToInternet]){
        _loginTimesArray = [[NSMutableArray alloc]init];
        _loginDoubleValues = [[NSMutableArray alloc]init];
        
        NSString *urlInString;
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        if([Port isEqualToString:@"-1"])
        {
            urlInString =[NSString stringWithFormat:@"%@://%@/getRosteringData?requestType=loginTimes",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
        }
        else
        {
            urlInString =[NSString stringWithFormat:@"%@://%@:%@/getRosteringData?requestType=loginTimes",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
        
        NSDictionary *bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"revised":[NSNumber numberWithBool:_isRevised]};
        NSLog(@"%@",bodyDict);
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
        if (resultData != nil){
            id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
            NSLog(@"%@",result);
            if ([result isKindOfClass:[NSArray class]]){
                NSArray *allTimesArray = result;
                if (allTimesArray.count != 0){
                    _loginDoubleValues = [NSMutableArray arrayWithArray:allTimesArray];
                    for (NSString *eachTime in allTimesArray){
                        long double millisecondsTime = [eachTime doubleValue];
                        NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:(millisecondsTime/1000)];
                        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                        [formatter setTimeZone:[NSTimeZone localTimeZone]];
                        [formatter setDateFormat:@"dd MMMM HH:mm"];
                        NSString *dateInString = [formatter stringFromDate:finalDate];
                        [_loginTimesArray addObject:dateInString];
                    }
                }else{
                    
                }
            }else{
                
            }
            NSLog(@"%@",_loginTimesArray);
            if (_loginTimesArray.count != 0){
                [loginPickerView reloadAllComponents];
            }else{
                [_loginTextField resignFirstResponder];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Schedule timings for login not found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }else{
            [_loginTextField resignFirstResponder];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Schedule timings for login not found. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else{
        [_loginTextField resignFirstResponder];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection problem" message:@"Please check your data connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
-(void)getLogoutTimes;
{
    if ([self connectedToInternet]){
        _logoutDoubleValues = [[NSMutableArray alloc]init];
        _logoutTimesArray = [[NSMutableArray alloc]init];
        
        NSString *urlInString;
        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
        if([Port isEqualToString:@"-1"])
        {
            urlInString =[NSString stringWithFormat:@"%@://%@/getRosteringData?requestType=logoutTimes",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
        }
        else
        {
            urlInString =[NSString stringWithFormat:@"%@://%@:%@/getRosteringData?requestType=logoutTimes",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
        
        NSDictionary *bodyDict;
        
        if ((![_loginTextField.text isEqualToString:@""] && ![_loginTextField.text isEqualToString:@"OFF"]) && _loginTextField.text.length > 0){
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cantEdit"]){
                if (_canLoginRevised){
                    bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"loginTime":_loginDoubleString,@"revised":[NSNumber numberWithBool:_isRevised]};
                }else{
                    bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"revised":[NSNumber numberWithBool:_isRevised]};
                }
            }else{
                //                if (!_canLoginRevised){
                //                    bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"loginTime":[_loginDoubleValues objectAtIndex:indexSelectedForLogin],@"revised":[NSNumber numberWithBool:_isRevised]};
                //                }else{
                if (_isRevised){
                    bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"loginTime":[[NSUserDefaults standardUserDefaults]valueForKey:@"loginDoubleValue"],@"revised":[NSNumber numberWithBool:_isRevised]};
                    NSLog(@"%@",bodyDict);
                }else{
                    bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"loginTime":[_loginDoubleValues objectAtIndex:indexSelectedForLogin],@"revised":[NSNumber numberWithBool:_isRevised]};
                }
                //                }
            }
        }else{
            if ([_loginDoubleString isEqualToString:@"OFF"]){
                bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"revised":[NSNumber numberWithBool:_isRevised]};
            }else{
                bodyDict = @{@"employeeId":userid,@"date":_dateString,@"officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"loginTime":_loginDoubleString,@"revised":[NSNumber numberWithBool:_isRevised]};
            }
        }
        NSLog(@"%@",bodyDict);
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&error_config];
        [request setHTTPBody:jsonData];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error_config];
        if (resultData != nil){
            id result = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error_config];
            NSLog(@"%@",result);
            if ([result isKindOfClass:[NSArray class]]){
                NSArray *allTimesArray = result;
                if (allTimesArray.count != 0){
                    _logoutDoubleValues = [NSMutableArray arrayWithArray:allTimesArray];
                    for (NSString *eachTime in allTimesArray){
                        long double millisecondsTime = [eachTime doubleValue];
                        NSLog(@"%Lf",millisecondsTime);
                        NSDate *finalDate = [NSDate dateWithTimeIntervalSince1970:(millisecondsTime/1000)];
                        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                        [formatter setTimeZone:[NSTimeZone localTimeZone]];
                        NSLog(@"%@",finalDate);
                        [formatter setDateFormat:@"dd MMMM HH:mm"];
                        NSString *dateString = [formatter stringFromDate:finalDate];
                        [_logoutTimesArray addObject:dateString];
                    }
                }else{
                    
                }
            }else{
                
            }
            NSLog(@"%@",_logoutTimesArray);
            if (_logoutTimesArray.count != 0){
                [logoutPickerView reloadAllComponents];
            }else{
                [_logoutTextField resignFirstResponder];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Schedule timings for Logout not found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }else{
            [_logoutTextField resignFirstResponder];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Schedule timings for logout not found. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else{
        [_logoutTextField resignFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Schedule timings for logout not found. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
-(void)getOffices;
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
-(void)getLoginTime:(NSString *)login withLogoutTime:(NSString *)logout withOffice:(NSString *)office withDate:(NSString *)date withOfficeName:(NSString *)officeName withCutoffDateAndTime:(NSDate *)cutoffDate;
{
    NSLog(@"%@",login);
    _loginTime = login;
    _logoutTime = logout;
    _officeIdString = office;
    NSLog(@"%@",office);
    [[NSUserDefaults standardUserDefaults] setValue:office forKey:@"defaultOfficeId"];
    
    _officeNameString = officeName;
    _cutoffDateAndTime = cutoffDate;
    NSLog(@"%@",_cutoffDateAndTime);
    NSLog(@"%@",cutoffDate);
    
    
    _selectedDate = date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *convertedDate = [formatter dateFromString:_selectedDate];
    long double doubleValueOfDate = [convertedDate timeIntervalSince1970];
    NSString *str1 = [NSString stringWithFormat:@"%.Lf",doubleValueOfDate];
    long double mine = [str1 doubleValue]*1000;
    NSDecimalNumber *finalValueOfDate = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.7Lf", mine]];
    _dateString = [finalValueOfDate stringValue];
    
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:convertedDate options:0];
    
    
    NSLog(@"%@",_cutoffDateAndTime);
    NSLog(@"%@",newDate);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd:HH-mm"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *newDateInString = [dateFormatter stringFromDate:newDate];
    NSString *cutoffDateInString = [dateFormatter stringFromDate:_cutoffDateAndTime];
    NSDate *newDateDate = [dateFormatter dateFromString:newDateInString];
    NSDate *cutoffDateDate = [dateFormatter dateFromString:cutoffDateInString];
    
    NSLog(@"%@",newDateDate);
    NSLog(@"%@",cutoffDateDate);
    
    if ([newDateDate compare:cutoffDateDate] == NSOrderedAscending){
        _isRevised = YES;
    }else{
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        unsigned unitFlags = NSCalendarUnitYearForWeekOfYear | NSCalendarUnitWeekOfYear;
        
        NSDateComponents *components = [calendar components:unitFlags fromDate:newDateDate];
        NSDateComponents *otherComponents = [calendar components:unitFlags fromDate:cutoffDateDate];
        
        if (([components yearForWeekOfYear] == [otherComponents yearForWeekOfYear]) && ([components weekOfYear] == [otherComponents weekOfYear])){
            _isRevised = YES;
        }else{
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                fromDate:cutoffDateDate
                                                                  toDate:newDateDate
                                                                 options:0];
            if ([components day] == 1){
                _isRevised = YES;
            }else{
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                    fromDate:cutoffDateDate
                                                                      toDate:[NSDate date]
                                                                     options:0];
                
                NSDateComponents *components2 = [gregorianCalendar components:NSCalendarUnitDay
                                                                     fromDate:cutoffDateDate
                                                                       toDate:newDateDate
                                                                      options:0];
                
                
                //                NSLog(@"%d",[components day]);
                //                NSLog(@"%d",[components2 day]);
                if ([components day] == 0){
                    // Check the time here for current time and cutoff time.
                    NSLog(@"%@",[NSDate date]);
                    NSLog(@"%@",_cutoffDateAndTime);
                    
                    if ([components2 day] > 8){
                        _isRevised = NO;
                    }else{
                        if ([[NSDate date] compare:_cutoffDateAndTime] == NSOrderedAscending){
                            _isRevised = NO;
                        }else{
                            _isRevised = YES;
                        }
                    }
                    
                }else if ([components day] == 1){
                    if ([components2 day] > 7){
                        _isRevised = NO;
                    }else{
                        _isRevised = YES;
                    }
                }else{
                    _isRevised = NO;
                }
            }
        }
    }
    
    
    NSLog(@"%@",[NSNumber numberWithBool:_isRevised]);
    
    if (![_officeIdString isEqualToString:@"NA"]){
        [[NSUserDefaults standardUserDefaults] setValue:_officeIdString forKey:@"defaultOfficeId"];
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:[_officeIdsArray firstObject] forKey:@"defaultOfficeId"];
    }
    if (![_officeNameString isEqualToString:@"NA"]){
        [[NSUserDefaults standardUserDefaults] setValue:_officeNameString forKey:@"defaultOfficeName"];
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:[_officesArray firstObject] forKey:@"defaultOfficeName"];
    }
    
}
-(void)getAllOfficeNames:(NSMutableArray *)officeNames withAllOfficeIds:(NSMutableArray *)officeIds;
{
    NSLog(@"%@",officeNames);
    NSLog(@"%@",officeIds);
    
    _officesArray = officeNames;
    _officeIdsArray = officeIds;
    
    
    //    [[NSUserDefaults standardUserDefaults] setValue:[officeIds firstObject] forKey:@"defaultOfficeId"];
    //    [[NSUserDefaults standardUserDefaults] setValue:[_officesArray firstObject] forKey:@"defaultOfficeName"];
}
-(BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    return ([response statusCode]==200)?YES:NO;
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2002){
        if (buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                SomeViewController *some = [[SomeViewController alloc]init];
                [self presentViewController:some animated:YES completion:nil];
            });
        }
    }
    
    if (alertView.tag == 2222){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    
    if (alertView.tag == 3333){
        if (buttonIndex == 1){
            UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option to delete schedule" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                    @"Login schedule",
                                    @"Logout schedule",
                                    nil];
            popup.tag = 1;
            [popup showInView:self.view];
        }
    }
    
    if (alertView.tag == 0000){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    
    if (alertView.tag == 12345){
        if (buttonIndex == 1){
            NSString *rivisionComments = [alertView textFieldAtIndex:0].text;
            if ([rivisionComments isEqualToString:@""] || rivisionComments.length == 0){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Rivision comments are mandatory for modify schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self connectedToInternet]){
                            NSString *urlInString;
                            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                            if([Port isEqualToString:@"-1"])
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                            }
                            else
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@:%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                            NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                            
                            NSMutableArray *dataArray = [[NSMutableArray alloc]init];
                            
                            if (_canLoginRevised && _canLogoutRevised){
                                //                            for (int i=0;i<2;i++){
                                //                                if (i == 0){
                                //                                    if ([_loginTextField.text isEqualToString:@""] || _loginTextField.text.length == 0){
                                //                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                                //                                        [dataArray addObject:dict];
                                //                                    }else{
                                //                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised]};
                                //                                        [dataArray addObject:dict];
                                //                                    }
                                //
                                //                                }
                                //                                if (i == 1){
                                //                                    if ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0){
                                //                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                                //                                        [dataArray addObject:dict];
                                //                                    }else{
                                //                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised]};
                                //                                        [dataArray addObject:dict];
                                //                                    }
                                //                                }
                                //                            }
                                
                                if ((![_loginTextField.text isEqualToString:@""] && ![_loginTextField.text isEqualToString:@"OFF"]) && (![_logoutTextField.text isEqualToString:@""] && ![_logoutTextField.text isEqualToString:@"OFF"])){
                                    for (int i=0;i<2;i++){
                                        if (i == 0){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                            [dataArray addObject:dict];
                                        }if (i == 1){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                            [dataArray addObject:dict];
                                        }
                                    }
                                }else if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || [_logoutTextField.text isEqualToString:@"OFF"])){
                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                    [dataArray addObject:dict];
                                }else{
                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                    [dataArray addObject:dict];
                                }
                                
                            }else if (_canLogoutRevised){
                                if (_isRevised){
                                    if ([_logoutTextField.text isEqualToString:@"OFF"] || _logoutTextField.text.length == 0){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"transportRequired":[NSNumber numberWithBool:YES],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }
                                    
                                }else{
                                    //                                for (int i=0;i<2;i++){
                                    //                                    if (i == 0){
                                    //                                        if ([_loginTextField.text isEqualToString:@""] || _loginTextField.text.length == 0){
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }else{
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }
                                    //
                                    //                                    }
                                    //                                    if (i == 1){
                                    //                                        if ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0){
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }else{
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }
                                    //                                    }
                                    //                                }
                                    if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && (![_logoutTextField.text isEqualToString:@"OFF"] && _logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@"OFF"] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }
                                    
                                    
                                }
                            }else if (_canLoginRevised){
                                if (_isRevised){
                                    if ([_loginTextField.text isEqualToString:@"OFF"] || _loginTextField.text.length == 0){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }
                                    
                                }else{
                                    //                                for (int i=0;i<2;i++){
                                    //                                    if (i == 0){
                                    //                                        if ([_loginTextField.text isEqualToString:@""] || _loginTextField.text.length == 0){
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }else{
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }
                                    //
                                    //                                    }
                                    //                                    if (i == 1){
                                    //                                        if ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0){
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }else{
                                    //                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:YES],@"revised":[NSNumber numberWithBool:_isRevised]};
                                    //                                            [dataArray addObject:dict];
                                    //                                        }
                                    //                                    }
                                    //                                }
                                    if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && (![_logoutTextField.text isEqualToString:@"OFF"] && _logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@"OFF"] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }
                                }
                            }
                            else if (!_canLoginRevised && !_canLogoutRevised){
                                if (_isRevised){
                                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can't modify your schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alertView show];
                                    alertView.tag = 1234567;
                                }else{
                                    if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && (![_logoutTextField.text isEqualToString:@"OFF"] && _logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((![_loginTextField.text isEqualToString:@"OFF"] && _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@"OFF"] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised],@"revisionComment":rivisionComments};
                                        [dataArray addObject:dict];
                                    }
                                }
                            }
                            
                            NSLog(@"%@",dataArray);
                            
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error_config];
                            [request setHTTPBody:jsonData];
                            
                            NSURLResponse *responce;
                            
                            NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                            if (result != nil){
                                id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                                
                                NSLog(@"%@",jsonresult);
                                if ([httpResponse statusCode] != 412){
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Schedule successfully updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                    alert.tag = 2222;
                                }
                                else{
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Clash happens due to other schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                            }else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Update schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection problem" message:@"Please check your data connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
            }
        }
    }
    if (alertView.tag == 1234567){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = [popup buttonTitleAtIndex:buttonIndex];
            if ([title isEqualToString:@"Login schedule"]){
                if ([_loginDoubleString isEqualToString:@"OFF"]){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Your login schedule is already OFF" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    //                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cantEdit"]){
                    //                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"can not delete schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    //                        [alert show];
                    //                    }else{
                    if (_loginCancellationAllowed){
                        NSString *urlInString;
                        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                        if([Port isEqualToString:@"-1"])
                        {
                            urlInString =[NSString stringWithFormat:@"%@://%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                        }
                        else
                        {
                            urlInString =[NSString stringWithFormat:@"%@://%@:%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                        
                        NSDictionary *dict = @{@"rosterId":_loginRosterIdString};
                        
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error_config];
                        [request setHTTPBody:jsonData];
                        NSURLResponse *responce;
                        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                        if (result != nil){
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                            
                            id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                            NSLog(@"%@",jsonresult);
                            if ([httpResponse statusCode] == 200){
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Schedule deleted successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                                alert.tag = 0000;
                            }else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Clash happens due to other schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                                alert.tag = 0000;
                            }
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Delete schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }else{
                        long double cutoffTimeinDouble = [_loginDoubleString doubleValue] - [_loginCancellationCutoffTime doubleValue];
                        NSDate *cutoffTime = [NSDate dateWithTimeIntervalSince1970:(cutoffTimeinDouble/1000)];
                        NSLog(@"%@",cutoffTime);
                        
                        NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                        NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
                        
                        NSInteger sourceGMToffset = [sourceTimeZone secondsFromGMTForDate:cutoffTime];
                        NSInteger destinationGMToffset = [destinationTimeZone secondsFromGMTForDate:cutoffTime];
                        
                        NSTimeInterval interval = destinationGMToffset - sourceGMToffset;
                        
                        NSDate *resultDate = [[NSDate alloc]initWithTimeInterval:interval sinceDate:cutoffTime];
                        
                        NSInteger sourceOffset = [sourceTimeZone secondsFromGMTForDate:[NSDate date]];
                        NSInteger destinationOffset = [destinationTimeZone secondsFromGMTForDate:[NSDate date]];
                        
                        NSTimeInterval timeInterval = destinationOffset - sourceOffset;
                        NSDate *resultCurrentDate = [[NSDate alloc]initWithTimeInterval:timeInterval sinceDate:[NSDate date]];
                        
                        NSLog(@"%@",resultCurrentDate);
                        
                        if ([resultCurrentDate compare:resultDate] == NSOrderedAscending){
                            NSLog(@"Can delete schedule");
                            NSString *urlInString;
                            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                            if([Port isEqualToString:@"-1"])
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                            }
                            else
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@:%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                            
                            NSDictionary *dict = @{@"rosterId":_loginRosterIdString};
                            
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error_config];
                            [request setHTTPBody:jsonData];
                            NSURLResponse *responce;
                            NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                            if (result != nil){
                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                                NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                NSLog(@"%@",responce);
                                id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                                NSLog(@"%@",jsonresult);
                                if ([httpResponse statusCode] == 200){
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Schedule deleted successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                    alert.tag = 0000;
                                }else{
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Cannot delete schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                    alert.tag = 0000;
                                }
                            }else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Delete schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancel roster" message:@"Cannot perform cancel after cutoff time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }
                    //                    }
                    
                }
            }
            else if ([title isEqualToString:@"Logout schedule"]){
                if ([_logoutDoubleString isEqualToString:@"OFF"]){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Your logout schedule is already OFF" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    //                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cantEdit1"]){
                    //                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Cannot perform cancel after cutoff time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    //                        [alert show];
                    //                    }else{
                    if (_logoutCancellationAllowed){
                        NSString *urlInString;
                        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                        if([Port isEqualToString:@"-1"])
                        {
                            urlInString =[NSString stringWithFormat:@"%@://%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                        }
                        else
                        {
                            urlInString =[NSString stringWithFormat:@"%@://%@:%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                        
                        
                        NSDictionary *dict = @{@"rosterId":_logoutRoasterIdString};
                        
                        
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error_config];
                        [request setHTTPBody:jsonData];
                        
                        NSURLResponse *responce;
                        
                        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                        if (result != nil){
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                            
                            id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                            NSLog(@"%@",jsonresult);
                            if ([httpResponse statusCode] == 200){
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Schedule deleted successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                                alert.tag = 0000;
                            }
                            else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Clash happens due to other schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                                alert.tag = 0000;
                            }
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Delete schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }else{
                        NSLog(@"%@",_logoutCancellationCutoffTime);
                        long double cutoffTimeinDouble = [_logoutDoubleString doubleValue] - [_logoutCancellationCutoffTime doubleValue];
                        NSDate *cutoffTime = [NSDate dateWithTimeIntervalSince1970:(cutoffTimeinDouble/1000)];
                        NSLog(@"%@",cutoffTime);
                        
                        NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                        NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
                        
                        NSInteger sourceGMToffset = [sourceTimeZone secondsFromGMTForDate:cutoffTime];
                        NSInteger destinationGMToffset = [destinationTimeZone secondsFromGMTForDate:cutoffTime];
                        
                        NSTimeInterval interval = destinationGMToffset - sourceGMToffset;
                        
                        NSDate *resultDate = [[NSDate alloc]initWithTimeInterval:interval sinceDate:cutoffTime];
                        NSLog(@"%@",resultDate);
                        
                        NSInteger sourceOffset = [sourceTimeZone secondsFromGMTForDate:[NSDate date]];
                        NSInteger destinationOffset = [destinationTimeZone secondsFromGMTForDate:[NSDate date]];
                        
                        NSTimeInterval timeInterval = destinationOffset - sourceOffset;
                        NSDate *resultCurrentDate = [[NSDate alloc]initWithTimeInterval:timeInterval sinceDate:[NSDate date]];
                        
                        NSLog(@"%@",resultCurrentDate);
                        
                        if ([resultCurrentDate compare:resultDate] == NSOrderedAscending){
                            NSString *urlInString;
                            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                            if([Port isEqualToString:@"-1"])
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                            }
                            else
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@:%@/removeroster?type=single",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                            
                            
                            NSDictionary *dict = @{@"rosterId":_logoutRoasterIdString};
                            
                            
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error_config];
                            [request setHTTPBody:jsonData];
                            
                            NSURLResponse *responce;
                            
                            NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                            if (result != nil){
                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                                
                                id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                                NSLog(@"%@",jsonresult);
                                if ([httpResponse statusCode] == 200){
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Schedule deleted successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                    alert.tag = 0000;
                                }
                                else{
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Cannot delete schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                    alert.tag = 0000;
                                }
                            }else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Delete schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancel roster" message:@"Cannot perform cancel after cutoff time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }
                    //                    }
                }
            }
            else if ([title isEqualToString:@"Full schedule"]){
                //                if ([_logoutDoubleString isEqualToString:@"OFF"] && [_loginDoubleString isEqualToString:@"OFF"]){
                //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Your schedule is already OFF" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                    [alert show];
                //                }else if ([_loginDoubleString isEqualToString:@"OFF"]){
                //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Your Login schedule is already OFF , please delete schedule for only Logout" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                    [alert show];
                //                }else if ([_logoutDoubleString isEqualToString:@"OFF"]){
                //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Your Logout schedule is already OFF , please delete schedule for only Login" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                    [alert show];
                //                }else{
                //                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cantEdit"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"cantEdit1"]){
                //                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"can not delete schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                        [alert show];
                //                    }else{
                //                        NSString *urlInString;
                //                        NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                //                        if([Port isEqualToString:@"-1"])
                //                        {
                //                            urlInString =[NSString stringWithFormat:@"%@://%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                //                        }
                //                        else
                //                        {
                //                            urlInString =[NSString stringWithFormat:@"%@://%@:%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
                //                        }
                //
                //                        NSURL *scheduleURL = [NSURL URLWithString:urlInString];
                //                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:scheduleURL];
                //                        [request setHTTPMethod:@"POST"];
                //
                //                        NSError *error_config;
                //
                //                        NSString *tokenString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"];
                //                        NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@",@"oauth_realm",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],@"oauth_token",tokenString];
                //                        NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
                //                        [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
                //                        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                //
                //                        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
                //
                //                        for (int i=0;i<2;i++){
                //                            if (i == 0){
                //                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":_loginDoubleString,@"login":[NSNumber numberWithBool:YES]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                //                                [dataArray addObject:dict];
                //                            }
                //                            if (i == 1){
                //                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":_logoutDoubleString,@"login":[NSNumber numberWithBool:NO]},@"transportRequired":[NSNumber numberWithBool:NO],@"revised":[NSNumber numberWithBool:_isRevised]};
                //                                [dataArray addObject:dict];
                //                            }
                //                        }
                //
                //                        NSLog(@"%@",dataArray);
                //
                //                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error_config];
                //                        [request setHTTPBody:jsonData];
                //
                //                        NSURLResponse *responce;
                //                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                //                        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                //                        if ([httpResponse statusCode] != 412){
                //                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Schedule deleted successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                            [alert show];
                //                            alert.tag = 0000;
                //                        }
                //                        else{
                //                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Clash happens due to other schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //                            [alert show];
                //                            alert.tag = 0000;
                //                        }
                //                    }
                //                }
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    //    }else{
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection problem" message:@"Please check your data connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
    
}
-(void)getDoubleValuesForLogin:(NSString *)login withLogout:(NSString *)logout;
{
    NSLog(@"%@",login);
    NSLog(@"%@",logout);
    _logoutDoubleString = logout;
    _loginDoubleString = login;
    
    [[NSUserDefaults standardUserDefaults] setObject:login forKey:@"loginDoubleValue"];
    [[NSUserDefaults standardUserDefaults] setObject:logout forKey:@"logoutDoubleValue"];
    
    
    NSString *loginTime = login;
    NSLog(@"%@",loginTime);
    
    
    if ([_loginDoubleString isEqualToString:@"OFF"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit"];
    }else{
        NSDate *loginTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_loginDoubleString doubleValue]/1000)];
        NSLog(@"%@",loginTimeAsDate);
        
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:loginTimeAsDate];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:loginTimeAsDate];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:loginTimeAsDate];
        NSLog(@"%@",destinationDate);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd MMMM HH:mm"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        
        NSDate *cutoffLoginTime = [destinationDate dateByAddingTimeInterval:(-([_loginCutoffTime doubleValue]/1000))];
        NSLog(@"%@",cutoffLoginTime);
        
        NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
        NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
        NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
        NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
        NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
        NSLog(@"%@",destinationDate1);
        
        
        if ([destinationDate1 compare:cutoffLoginTime] == NSOrderedAscending){
            NSLog(@"yes can edit");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit"];
        }else{
            NSLog(@"no");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit"];
        }
    }
    
    if ([_logoutDoubleString isEqualToString:@"OFF"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit1"];
    }else{
        NSDate *loginTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_logoutDoubleString doubleValue]/1000)];
        NSLog(@"%@",loginTimeAsDate);
        
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:loginTimeAsDate];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:loginTimeAsDate];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:loginTimeAsDate];
        NSLog(@"%@",destinationDate);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd MMMM HH:mm"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        
        
        NSDate *cutoffLoginTime = [destinationDate dateByAddingTimeInterval:(-([_logoutCutoffTime doubleValue]/1000))];
        NSLog(@"%@",cutoffLoginTime);
        
        NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
        NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
        NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
        NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
        NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
        NSLog(@"%@",destinationDate1);
        
        if ([destinationDate1 compare:cutoffLoginTime] == NSOrderedAscending){
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cantEdit1"];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cantEdit1"];
        }
        
    }
    
    
}
-(void)getCutoffsModel:(NSDictionary *)cutoffValues;
{
    NSLog(@"%@",cutoffValues);
    
    //    _canLoginRevised = [[cutoffValues valueForKey:@"loginRevisionAllowed"] boolValue];
    //    _canLogoutRevised = [[cutoffValues valueForKey:@"logoutRevisionAllowed"] boolValue];
    
    _canLoginRevised = YES;
    _canLogoutRevised = YES;
    
    
    _loginCutoffTime = [cutoffValues valueForKey:@"revisedLogin"];
    _logoutCutoffTime = [cutoffValues valueForKey:@"revisedLogout"];
    
    _loginCancellationAllowed = [[cutoffValues valueForKey:@"cancellationPostCutoffLogin"] boolValue];
    _logoutCancellationAllowed = [[cutoffValues valueForKey:@"cancellationPostCutoffLogout"] boolValue];
    _loginCancellationCutoffTime = [cutoffValues valueForKey:@"cancellationLogin"];
    _logoutCancellationCutoffTime = [cutoffValues valueForKey:@"cancellationLogout"];
}
-(void)getLoginRosterId:(NSString *)loginRoasterId withLogoutRosterId:(NSString *)logoutRoasterId;
{
    _loginRosterIdString = loginRoasterId;
    _logoutRoasterIdString = logoutRoasterId;
    NSLog(@"%@ %@",_logoutRoasterIdString,_loginRosterIdString);
}

-(void)goAheadToSaveRoster{
    NSDate *logoutTimeAsDate = [NSDate dateWithTimeIntervalSince1970:([_logoutDoubleString doubleValue]/1000)];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:logoutTimeAsDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:logoutTimeAsDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:logoutTimeAsDate];
    
    NSDate *cutoffLogoutTime = [destinationDate dateByAddingTimeInterval:(-([_logoutCutoffTime doubleValue]/1000))];
    
    NSTimeZone* sourceTimeZone1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone1 = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset1 = [sourceTimeZone1 secondsFromGMTForDate:[NSDate date]];
    NSInteger destinationGMTOffset1 = [destinationTimeZone1 secondsFromGMTForDate:[NSDate date]];
    NSTimeInterval interval1 = destinationGMTOffset1 - sourceGMTOffset1;
    NSDate* destinationDate1 = [[NSDate alloc] initWithTimeInterval:interval1 sinceDate:[NSDate date]];
    
    
    if ([destinationDate1 compare:cutoffLogoutTime] == NSOrderedAscending){
        if ([_loginTextField.text isEqualToString:@""] && [_logoutTextField.text isEqualToString:@""]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select any schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            NSLog(@"%@",[NSNumber numberWithBool:_isRevised]);
            if (_isRevised){
                UIAlertView *rivisionAlert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Please enter comments for revising schedule" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                rivisionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [rivisionAlert textFieldAtIndex:0].delegate = self;
                [rivisionAlert textFieldAtIndex:0].placeholder = @"Comments";
                rivisionAlert.tag = 12345;
                [rivisionAlert show];
            }else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self connectedToInternet]){
                            NSString *urlInString;
                            NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                            if([Port isEqualToString:@"-1"])
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                            }
                            else
                            {
                                urlInString =[NSString stringWithFormat:@"%@://%@:%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                            NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                            
                            NSMutableArray *dataArray = [[NSMutableArray alloc]init];
                            
                            if (_canLoginRevised && _canLogoutRevised){
                                
                                if ((_loginTextField.text.length >0) && (_logoutTextField.text.length >0)){
                                    for (int i=0;i<2;i++){
                                        if (i == 0){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }if (i == 1){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }
                                    }
                                }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                    [dataArray addObject:dict];
                                }else{
                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                    [dataArray addObject:dict];
                                }
                                
                            }else if (_canLogoutRevised){
                                if (_isRevised){
                                    if ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }
                                    
                                }else{
                                    if ((_loginTextField.text || _loginTextField.text.length >0) && (_logoutTextField.text || _logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }
                                    
                                    
                                }
                            }else if (_canLoginRevised){
                                if (_isRevised){
                                    if ([_loginTextField.text isEqualToString:@""] || _loginTextField.text.length == 0){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }
                                    
                                }else{
                                    if ((_loginTextField.text || _loginTextField.text.length >0) && (_logoutTextField.text || _logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }
                                }
                            }
                            else if (!_canLoginRevised && !_canLogoutRevised){
                                if (_isRevised){
                                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can't modify your schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alertView show];
                                    alertView.tag = 1234567;
                                }else{
                                    if ((_loginTextField.text || _loginTextField.text.length >0) && (_logoutTextField.text || _logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }
                                }
                            }
                            
                            NSLog(@"%@",dataArray);
                            
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error_config];
                            [request setHTTPBody:jsonData];
                            
                            NSURLResponse *responce;
                            
                            NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                            id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                            if (jsonresult != nil){
                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                                if ([jsonresult isKindOfClass:[NSDictionary class]]){
                                    if ([httpResponse statusCode] == 200){
                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Schedule successfully updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                        [alert show];
                                        alert.tag = 2222;
                                    }else{
                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Clash happens due to other schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                        [alert show];
                                    }
                                }else{
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Update schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                            }else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Update schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection problem" message:@"Please check your data connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
            }
            
        }
        
    }else{
        if ([_logoutDoubleString isEqualToString:@"OFF"]){
            if ([_loginTextField.text isEqualToString:@""] && [_logoutTextField.text isEqualToString:@""]){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select any schedule" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                NSLog(@"%@",[NSNumber numberWithBool:_isRevised]);
                if (_isRevised){
                    UIAlertView *rivisionAlert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Please enter coments for revising schedule" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                    rivisionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [rivisionAlert textFieldAtIndex:0].delegate = self;
                    [rivisionAlert textFieldAtIndex:0].placeholder = @"Comments";
                    rivisionAlert.tag = 12345;
                    [rivisionAlert show];
                }else{
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self connectedToInternet]){
                                NSString *urlInString;
                                NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                                if([Port isEqualToString:@"-1"])
                                {
                                    urlInString =[NSString stringWithFormat:@"%@://%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                                }
                                else
                                {
                                    urlInString =[NSString stringWithFormat:@"%@://%@:%@/saverosters",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
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
                                NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
                                
                                NSMutableArray *dataArray = [[NSMutableArray alloc]init];
                                
                                if (_canLoginRevised && _canLogoutRevised){
                                    
                                    if ((_loginTextField.text.length >0) && (_logoutTextField.text.length >0)){
                                        for (int i=0;i<2;i++){
                                            if (i == 0){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }if (i == 1){
                                                NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                [dataArray addObject:dict];
                                            }
                                        }
                                    }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }else{
                                        NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                        [dataArray addObject:dict];
                                    }
                                    
                                }else if (_canLogoutRevised){
                                    if (_isRevised){
                                        if ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }else{
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }
                                        
                                    }else{
                                        if ((_loginTextField.text || _loginTextField.text.length >0) && (_logoutTextField.text || _logoutTextField.text.length >0)){
                                            for (int i=0;i<2;i++){
                                                if (i == 0){
                                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                    [dataArray addObject:dict];
                                                }if (i == 1){
                                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                    [dataArray addObject:dict];
                                                }
                                            }
                                        }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }else{
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }
                                        
                                        
                                    }
                                }else if (_canLoginRevised){
                                    if (_isRevised){
                                        if ([_loginTextField.text isEqualToString:@""] || _loginTextField.text.length == 0){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }else{
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }
                                        
                                    }else{
                                        if ((_loginTextField.text || _loginTextField.text.length >0) && (_logoutTextField.text || _logoutTextField.text.length >0)){
                                            for (int i=0;i<2;i++){
                                                if (i == 0){
                                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                    [dataArray addObject:dict];
                                                }if (i == 1){
                                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                    [dataArray addObject:dict];
                                                }
                                            }
                                        }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }else{
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }
                                    }
                                }
                                else if (!_canLoginRevised && !_canLogoutRevised){
                                    if (_isRevised){
                                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can't modify your schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                        [alertView show];
                                        alertView.tag = 1234567;
                                    }else{
                                        if ((_loginTextField.text || _loginTextField.text.length >0) && (_logoutTextField.text || _logoutTextField.text.length >0)){
                                            for (int i=0;i<2;i++){
                                                if (i == 0){
                                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                    [dataArray addObject:dict];
                                                }if (i == 1){
                                                    NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                                    [dataArray addObject:dict];
                                                }
                                            }
                                        }else if ((_loginTextField.text || _loginTextField.text.length >0) && ([_logoutTextField.text isEqualToString:@""] || _logoutTextField.text.length == 0)){
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"loginDoubleValue"],@"login":[NSNumber numberWithBool:YES]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }else{
                                            NSDictionary *dict = @{@"_employeeId":userid,@"date":_dateString,@"deploymentBand":@{@"_officeId":[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultOfficeId"],@"time":[[NSUserDefaults standardUserDefaults] valueForKey:@"logoutDoubleValue"],@"login":[NSNumber numberWithBool:NO]},@"revised":[NSNumber numberWithBool:_isRevised]};
                                            [dataArray addObject:dict];
                                        }
                                    }
                                }
                                
                                NSLog(@"%@",dataArray);
                                
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error_config];
                                [request setHTTPBody:jsonData];
                                
                                NSURLResponse *responce;
                                
                                NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error_config];
                                if (result != nil){
                                    id jsonresult = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error_config];
                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
                                    if ([jsonresult isKindOfClass:[NSDictionary class]]){
                                        if ([httpResponse statusCode] == 200){
                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Schedule successfully updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                            [alert show];
                                            alert.tag = 2222;
                                        }else{
                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Clash happens due to other schedule" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                            [alert show];
                                        }
                                    }else{
                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Update schedule failed. Try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                        [alert show];
                                    }
                                }else{
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Modify Schedule" message:@"Update schedule failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                            }else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection problem" message:@"Please check your data connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                }
                
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Schedule can not change" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
@end
