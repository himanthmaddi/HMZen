//
//  getEmgContacts.m
//  Safetrax
//
//  Created by Kumaran on 03/04/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "getEmgContacts.h"

@implementation getEmgContacts
- (id) init {
    self = [super init];
    if(self) {
        [self getEmgContacts];
    }
    return self;
}
-(void)getEmgContacts
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:userName, @"username", password, @"password",nil];
    GCMRequest *requestWraper =[[GCMRequest alloc]init];
    [requestWraper setPostParams:newDatasetInfo];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithGCM:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}
-(void)onResponseReceived:(NSData *)data
{
    NSDictionary *auth_dictionary= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([auth_dictionary objectForKey:@"email"]){
        [[NSUserDefaults standardUserDefaults] setObject:[auth_dictionary objectForKey:@"emgcontact"] forKey:@"emgcontact"];
    }
}
-(void)onFailure
{
    NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
}
@end
