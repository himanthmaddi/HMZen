//
//  Connection.m
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "Connection.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation Connection
@synthesize request,completitionBlock,internalConnection;
-(id)initWithURLString:(NSString *)urlString {
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    self = [super init];
    if (self) {
        [self setRequest:req];
    }
    return self;
}
-(void)start {
    container = [[NSMutableData alloc]init];
    internalConnection = [[NSURLConnection alloc]initWithRequest:[self request] delegate:self startImmediately:YES];
    if(!sharedConnectionList)
        sharedConnectionList = [[NSMutableArray alloc] init];
    [sharedConnectionList addObject:self];
}
#pragma mark NSURLConnectionDelegate methods
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [container appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
        if([self completitionBlock])
        [self completitionBlock](container,nil);
     [sharedConnectionList removeObject:self];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if([self completitionBlock])
        [self completitionBlock](nil,error);
    [sharedConnectionList removeObject:self];
}
@end
