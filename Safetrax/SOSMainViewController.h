//
//  SOSMainViewController.h
//  Safetrax
//
//  Created by Kumaran on 03/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "RestClientTask.h"
#import "SosViewController.h"
@interface SOSMainViewController : UIViewController<RestCallBackDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    TripModel *tripModel;
    NSMutableDictionary *DataDictionary;
    NSMutableArray *flattenArray;
    NSMutableData *_responseData;
    SosViewController *sosController ;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model ;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
- (NSString *) dateString;
-(void)sendSosMessage:(NSString *)message withFileAttached:(BOOL)fileAttached fileName:(NSString *)fileName;

@end
