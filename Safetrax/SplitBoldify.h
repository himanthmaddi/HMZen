//
//  SplitBoldify.h
//  Safetrax
//
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//
//  This class was created to split a string to boldify a substring
//  thereby limiting the number of labels used. 
//
//

#import <Foundation/Foundation.h>

@interface UILabel (Boldify)
- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;
@end
