//
//  CheckFeedbackViewController.h
//  Safetrax
//
//  Created by Kumaran on 25/01/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestClientTask.h"
#import "HomeViewController.h"
@interface CheckFeedbackViewController : UIViewController <RestCallBackDelegate>
{
    NSMutableData *_responseData;
    HomeViewController *homeObject;
}
-(void)downloadConfig;
-(void)ShowFeedback;
- (void)setDelegate:(id)newDelegate;

@end
