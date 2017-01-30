//
//  RestClientTask.m
//  Safetrax
//
//  Created by Kumaran on 30/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//
#import "RestClientTask.h"
#import "GCMRequest.h"
#import "TripCollection.h"
#import "MongoRequest.h"
#import "Reachability.h"
#import "AppDelegate.h"
extern BOOL refreshInProgress;
@implementation RestClientTask
//offlineAlertView = [[UIAlertView alloc] initWithTitle:@"Device Offline" message:@"Device Not Connected To Internet!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
- (id)initWithGCM:(GCMRequest *)Request{
     NSRequest = [[NSMutableURLRequest alloc] init];
    [NSRequest setURL:[Request getURL]];
    [NSRequest setHTTPMethod:[Request getHTTPMethod]];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [NSRequest setHTTPBody:[Request getPostParams]];
    [NSRequest setHTTPBody:[[NSUserDefaults standardUserDefaults] objectForKey:@"tempData"]];
    self = [super init];
    return self;
}
- (id)initWithMongo:(MongoRequest *)Request{
     NSRequest = [[NSMutableURLRequest alloc] init];
    [NSRequest setURL:[Request getURL]];
    NSLog(@"%@",[Request getURL]);
    [NSRequest setHTTPMethod:[Request getHTTPMethod]];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [NSRequest setValue:[Request getAuthString] forHTTPHeaderField:@"Authorization"];
    [NSRequest setHTTPBody:[Request getPostParams]];
    self = [super init];
    return self;
}
- (void)setDelegate:(id)newDelegate{
    delegate = newDelegate;
}
-(BOOL)connectedToInternet
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}
-(BOOL)execute
{
    if([self connectedToInternet]){
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:NSRequest delegate:self];
    [connection start];
        return TRUE;
    }
    else
    {
        refreshInProgress = FALSE;
        AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showAlert:YES];
        return FALSE;
    }
}
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response %@",response);
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode == 404)
        {
            [connection cancel];  // stop connecting; no more delegate messages
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            [delegate onFailure];
        }
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary *forDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",forDict);
    [delegate onResponseReceived:data];
    id info_array= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([info_array isKindOfClass:[NSDictionary class]]){
        if([info_array objectForKey:@"error_code"]){
           NSNumber *error=[info_array objectForKey:@"error_code"];
            NSLog(@"%@",error);
            if(error.integerValue == -1){
               UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Not a Valid Current Trip! Please Refresh trips!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [calert show];
            }
        }
    }
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [delegate onFinishLoading];
   
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Error:%@",error);
    [delegate onFailure];
    AppDelegate *appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showAlert:NO];
}
@end
