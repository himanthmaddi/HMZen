//
//  MyChildrenViewController.h
//  Safetrax
//
//  Created by Kumaran on 10/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface MyChildrenViewController : UIViewController
{
    FXBlurView *blurView;
}
@property (weak, nonatomic) IBOutlet UIButton *child1;
@property (weak, nonatomic) IBOutlet UILabel *child1Name;
@property (weak, nonatomic) IBOutlet UIButton *child2;
@property (weak, nonatomic) IBOutlet UILabel *child2Name;
@property (weak, nonatomic) IBOutlet UIButton *child3;
@property (weak, nonatomic) IBOutlet UILabel *child3Name;
@property (weak, nonatomic) IBOutlet UIButton *child4;
@property (weak, nonatomic) IBOutlet UILabel *child4Name;
-(void)didFinishvalidation;
@end
