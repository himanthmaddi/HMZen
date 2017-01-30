//
//  MyTripParentViewController.h
//  Safetrax
//
//  Created by Kumaran on 10/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import "RestClientTask.h"
#import "TripSummaryParentViewController.h"

@interface MyTripParentViewController : UIViewController <NSURLConnectionDelegate, UIAlertViewDelegate,RestCallBackDelegate,UITableViewDelegate,UITableViewDataSource>
{
     FXBlurView *blurView;
     TripSummaryParentViewController *tripSummary;
     NSMutableData *_responseData;
     NSMutableData *CompletedTrip;
     UIRefreshControl *refreshControl;
     NSDictionary *tripDrop;
     NSDictionary *tripPickup;
     NSMutableArray *unique ;
     NSMutableArray *tripsSection1;
     NSMutableArray *tripsSection2;
    NSMutableArray *tripsSection3;

     NSMutableArray *ChildrenIDs;

}
@property (nonatomic, retain) IBOutlet UITableView *tripTable;
@property (weak, nonatomic) IBOutlet UIButton *TripsHelpButton;
-(void)didFinishvalidation;
@end
