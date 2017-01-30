//
//  ScheduleTableViewCell.h
//  Commuter
//
//  Created by Himanth Maddi on 20/12/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell

@property (nonatomic , strong) IBOutlet UILabel *dateLabel;
@property (nonatomic , strong) IBOutlet UILabel *loginLabel;
@property (nonatomic , strong) IBOutlet UILabel *logoutLabel;
@property (nonatomic , strong) IBOutlet UILabel *officeLabel;

@end
