//
//  SosViewController.h
//  Safetrax
//
//  Created by Kumaran on 02/02/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
@interface SosViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *tableTitles;
    NSMutableArray *subarray;
    int currentExpandedIndex;
    NSIndexPath *currentIndex;
     TripModel *tripModel;
    NSMutableDictionary *DataDictionary;
    NSMutableArray *flattenArray;

}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *currentLocation;
@property (weak, nonatomic) IBOutlet UILabel *bloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;
@property (weak, nonatomic) IBOutlet UILabel *empId;
@property (weak, nonatomic) IBOutlet UITableView *SOStable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model withDataDictionary:(NSMutableDictionary *)data;
-(void)loadTable;
@end
