//
//  Constants.m
//  Safetrax
//
// 
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "Constants.h"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@implementation Constants
-(int)adjust:(int)height{
    if(!IS_WIDESCREEN){
        
        height = height - 88;
    }
    return height;
}
@end
