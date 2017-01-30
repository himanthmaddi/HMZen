//
//  FloatingLabel.h
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//
//   Floating Label is a label that displays location details in the map
//  Floating Label automatically increases width with text
#import <Foundation/Foundation.h>


@interface FloatingLabel : UILabel
-(void)setupFLabel:(CGFloat)yPos withText:(NSString *)text;
-(void)addEffects;
@end
