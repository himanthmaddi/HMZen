//
//  HistoryViewController.h
//  Safetrax
//
//  Created by Kumaran on 26/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import "RestClientTask.h"
#import "tripSummaryViewController.h"
@interface HistoryViewController : UIViewController< UITableViewDelegate,UITableViewDataSource,RestCallBackDelegate>
{
    
    NSArray *tripDetails;
    NSMutableData *_responseData;
    FXBlurView *infoView;
    NSDictionary *tripDropHistory;
    NSDictionary *tripPickupHistory;
    NSMutableArray *uniqueHistory ;
    NSMutableArray *tripsSection1History;
    NSMutableArray *tripsSection2History;
    tripSummaryViewController *tripSummary;
}
@property (nonatomic, retain) IBOutlet UITableView *historyTable;


@end
