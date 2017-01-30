//
//  StoppagesViewController.h
//  Safetrax
//
//  Created by Himanth on 30/06/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoppagesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *namesArray;
    NSArray *userIdsArray;
}

@property (nonatomic,strong) IBOutlet UITableView *employeeDetailsTable;
-(void)getUsernameArray:(NSMutableArray *)usernameArray forAppropriateIdarray:(NSMutableArray *)idsArray;
@end
