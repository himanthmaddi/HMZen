//
//  RequestParams.h
//  Safetrax
//
//  Created by Kumaran on 29/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestParams : NSObject
{
 NSURL *URL;
 NSString *HTTPMethod;
}
- (id)initWithName:(NSURL *)Url andtype:(NSString *)Methodtype;
- (void)print;
@end
