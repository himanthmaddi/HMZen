//
//  FloatingLabel.m
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "FloatingLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation FloatingLabel
-(void)setupFLabel:(CGFloat)yPos withText:(NSString *)text{
    [self setText:text];
    
    CGFloat width;
    //Check for ios 7 or below and use appropriate methods
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        width = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10.0 ]].width;
    }
    else
    {
        width = ceil([text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:10.0]}].width);
    }
    //If the text is too long, we can cut off a part of it
    if(width > 300) width = 300;
    //Get the xposition
    CGFloat xPos = (320-width)/2.0;
    //Create label frame assuming height is 20
    [self setFrame:CGRectMake(xPos, yPos, width, 20)];
    [self addEffects];
}
-(void)addEffects{
    [self setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
    [self.layer setCornerRadius:8.0];
    [self setAlpha:0.7];
    [self setBackgroundColor:[UIColor blackColor]];
    [self setTextColor:[UIColor whiteColor]];
}
@end
