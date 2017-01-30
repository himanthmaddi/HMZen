//
//  MenuViewControllerParent.h
//  Safetrax
//
//  Created by Kumaran on 10/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTripParentViewController.h"
#import "MyChildrenViewController.h"

@interface MenuViewControllerParent : UIViewController
{
    MyTripParentViewController *MyTrip;
    MyChildrenViewController *MyChildren;
}
@property (weak, nonatomic) IBOutlet UILabel *picLabel;
@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *CompanyCode;
@property (weak, nonatomic) IBOutlet UITextField *empId;
@end
