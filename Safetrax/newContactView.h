//
//  newContactView.h
//  Safetrax
//
//  Created by Kumaran on 12/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestClientTask.h"

@class addContactsView;
@interface newContactView : UIViewController<RestCallBackDelegate>{
    NSString *contactType;
    addContactsView *addContact;
}
@property (nonatomic, retain) IBOutlet UITextField *Name;
@property (nonatomic, retain) IBOutlet UITextField *Mobile;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withString:(NSString *)type  withObject:(addContactsView *)addContactObject;
@end
