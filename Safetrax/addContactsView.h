//
//  addContactsView.h
//  Safetrax
//
//  Created by Kumaran on 09/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "newContactView.h"
@class HelpContactsViewController;
@interface addContactsView : UIViewController<RestCallBackDelegate>

{
    HelpContactsViewController *help;
    newContactView *addNewContact;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedType;
- (IBAction)segmentedTypeChanged:(id)sender;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(HelpContactsViewController *)helpObject;
-(void)removeView:(NSString*)contactString;
-(IBAction)newContacts:(id)sender;
@end
