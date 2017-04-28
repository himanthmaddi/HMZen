//
//  validateLogin.h
//  Safetrax
//
//  Created by Kumaran on 23/03/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestClientTask.h"
@interface validateLogin : NSObject<NSURLConnectionDataDelegate>
{
    NSMutableData *_responseData;
    id homeObject;
}
-(void)validate;
- (void)setDelegate:(id)newDelegate;
@end
