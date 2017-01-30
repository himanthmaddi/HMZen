//
//  SomeViewController.h
//  Commuter
//
//  Created by Himanth Maddi on 15/01/17.
//  Copyright © 2017 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SomeViewController : UIViewController<UITextFieldDelegate>



@property IBOutlet UILabel *employeeIdLabel;
@property IBOutlet UILabel *employeeNameLabel;
@property (nonatomic , strong) NSString *punctuationString;
@property (nonatomic , strong) NSString *driverBehaviourString;
@property (nonatomic , strong) NSString *vehicleConditionString;

@property IBOutlet UIButton *punctualityGoodButton;
@property IBOutlet UIButton *punctualityBadButton;
@property IBOutlet UIButton *driverBehavingGoodButton;
@property IBOutlet UIButton *driverBehavingBadButton;
@property IBOutlet UIButton *vehicleConditionGoodButton;
@property IBOutlet UIButton *vehicleConditionBadButton;

@property IBOutlet UITextField *commentsTextField;

@property (nonatomic , strong) NSString *tripIdString;

-(IBAction)submitTripRating:(id)sender;

-(IBAction)puctualityGood:(id)sender;
-(IBAction)puctualityBad:(id)sender;
-(IBAction)driverBehavingGood:(id)sender;
-(IBAction)driverBehavingBad:(id)sender;
-(IBAction)vehicleConditionGood:(id)sender;
-(IBAction)vehicleConditionBad:(id)sender;

-(void)getTripId:(NSString *)tripID;

@end
