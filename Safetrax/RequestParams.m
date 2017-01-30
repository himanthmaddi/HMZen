//
//  RequestParams.m
//  Safetrax
//
//  Created by admin admin on 29/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "RequestParams.h"

@implementation RequestParams

- (id)initWithName:(NSURL *)Url andtype:(NSString *)Methodtype{
    URL =Url;
    HTTPMethod =Methodtype;
    return self;
}
- (void)print {
    NSLog(@"url: %@", URL);
    NSLog(@"type: %@", HTTPMethod);
}
@end

