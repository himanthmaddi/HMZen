//
//  Connection.h
//  Safetrax
//
//  Created by Rahul Shivkumar on 7/11/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    NSURLConnection * internalConnection;
    NSMutableData * container;
}
-(id)initWithURLString:(NSString *)urlString;

@property (nonatomic,copy)NSURLConnection * internalConnection;
@property (nonatomic,copy)NSURLRequest *request;
@property (nonatomic,copy)void (^completitionBlock) (id obj, NSError * err);


-(void)start;
@end
