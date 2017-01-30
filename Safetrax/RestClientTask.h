//
//  RestClientTask.h
//  Safetrax
//
//  Created by Kumaran on 30/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GCMRequest.h"
#import "MongoRequest.h"
@protocol RestCallBackDelegate

- (void)onResponseReceived:(NSData *)data;
-(void)onFailure;
-(void)onConnectionFailure;
-(void)onFinishLoading;

@end
@interface RestClientTask : UIViewController<UIAlertViewDelegate>
{
    NSMutableURLRequest *NSRequest;
    id delegate;
}
@property (nonatomic, retain) UIAlertView *offlineAlertView;
- (void)setDelegate:(id)newDelegate;
- (id)initWithGCM:(GCMRequest *)Request;
- (id)initWithMongo:(MongoRequest *)Request;
-(BOOL)execute;
- (BOOL)connectedToInternet;
@end
