//
//  HelpContactsViewController.h
//  Safetrax
//
//  Created by Kumaran on 09/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addContactsView.h"
#import "SOSMainViewController.h"
@interface HelpContactsViewController : UIViewController<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *contactList;
   
    __weak IBOutlet UITableView *contactTable;
    addContactsView *addContacts;
     SOSMainViewController *sosController;
}
-(IBAction)Back:(id)sender;
-(void)loadContacts:(NSString *)selectedType;
-(IBAction)addContacts:(id)sender;
-(void)removeView:(NSString*)contactString;
@end
