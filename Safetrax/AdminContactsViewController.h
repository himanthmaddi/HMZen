//
//  AdminContactsViewController.h
//  Commuter
//
//  Created by Himanth Maddi on 26/04/17.
//  Copyright © 2017 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdminContactsViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>

@property (nonatomic , strong) IBOutlet UITableView *contactsTableView;
@property (nonatomic , strong) IBOutlet UILabel *noContactsLabel;

@end
