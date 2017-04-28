//
//  editViewController.h
//  Commuter
//
//  Created by Himanth Maddi on 21/12/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface editViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate>

@property (nonatomic , strong) IBOutlet UITextField *loginTextField;
@property (nonatomic , strong) IBOutlet UITextField *logoutTextField;
@property (nonatomic , strong) IBOutlet UITextField *officeTextField;
@property (nonatomic , strong) IBOutlet UIButton *saveButton;
@property (nonatomic , strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic , strong) NSMutableArray *loginTimesArray;
@property (nonatomic , strong) NSMutableArray *logoutTimesArray;

@property (nonatomic , strong) NSMutableArray *officesArray;
@property (nonatomic , strong) NSMutableArray *officeIdsArray;

@property (nonatomic , strong) NSMutableArray *loginDoubleValues;
@property (nonatomic , strong) NSMutableArray *logoutDoubleValues;

@property (nonatomic , assign) BOOL loginCancellationAllowed;
@property (nonatomic , assign) BOOL logoutCancellationAllowed;
@property (nonatomic , assign) NSString *loginCancellationCutoffTime;
@property (nonatomic , assign) NSString *logoutCancellationCutoffTime;

@property (nonatomic , strong) NSString *loginTime;
@property (nonatomic , strong) NSString *logoutTime;
@property (nonatomic , strong) NSString *officeIdString;
@property (nonatomic , strong) NSString *dateString;
@property (nonatomic , strong) NSString *officeNameString;
@property (nonatomic , strong) NSString *loginRosterIdString;
@property (nonatomic , strong) NSString *logoutRoasterIdString;

@property (nonatomic , strong) NSString *loginDoubleString;
@property (nonatomic , strong) NSString *logoutDoubleString;

@property (nonatomic , strong) NSString *selectedDate;

@property (nonatomic , strong) NSDate *cutoffDateAndTime;
@property (nonatomic , strong) NSString *loginCutoffTime;
@property (nonatomic , strong) NSString *logoutCutoffTime;

@property (nonatomic ,assign) BOOL isRevised;
@property (nonatomic ,assign) BOOL canLoginRevised;
@property (nonatomic ,assign) BOOL canLogoutRevised;

@property (nonatomic , strong) NSString *cutoffLoginTime;
@property (nonatomic , strong) NSString *cutoffLogoutTime;

@property (nonatomic ,strong) IBOutlet UIButton *loginCancelButton;
@property (nonatomic ,strong) IBOutlet UIButton *logoutCancelButton;

//@property (nonatomic, strong) IBOutlet UILabel *loginLabel;
//@property (nonatomic, strong) IBOutlet UILabel *logoutLabel;


-(IBAction)loginCancelAction:(id)sender;
-(IBAction)logoutCancelAction:(id)sender;
-(IBAction)saveButtonClicked:(id)sender;

-(void)getLoginTimes;
-(void)getLogoutTimes;
-(void)getOffices;

-(void)getLoginTime:(NSString *)login withLogoutTime:(NSString *)logout withOffice:(NSString *)office withDate:(NSString *)date withOfficeName:(NSString *)officeName withCutoffDateAndTime:(NSDate *)cutoffDate;

-(void)getAllOfficeNames:(NSMutableArray *)officeNames withAllOfficeIds:(NSMutableArray *)officeIds;

-(void)getDoubleValuesForLogin:(NSString *)login withLogout:(NSString *)logout;
-(void)getCutoffsModel:(NSDictionary *)cutoffValues;
-(void)getLoginRosterId:(NSString *)loginRoasterId withLogoutRosterId:(NSString *)logoutRoasterId;
@end
