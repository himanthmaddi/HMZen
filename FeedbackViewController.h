//
//  FeedbackViewController.h
//  Safetrax
//
//  Created by Kumaran on 25/01/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestClientTask.h"

@interface FeedbackViewController : UIViewController<RestCallBackDelegate>


@property (weak, nonatomic) IBOutlet UITextField *FeedbackText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *CabDriverInfoSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *CabReportedOntimeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *DriverKnowledgeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *CabTrackingSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *AccessCardSegment;
@end
