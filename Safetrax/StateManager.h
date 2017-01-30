//
//  StateManager.h
//  Safetrax
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//  Manages state of the app. Sends requests and alerts view controller that state has changed.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

NSString const *error = @"error";
NSString const *tripEnded = @"tripended";
NSString const *noTrip = @"notrip";
NSString const *attendace = @"attendance";
NSString const *waitingForCab = @"waitingforcab";
NSString const *boardedCab = @"boardedcab";
NSString const *reachedDestination = @"reacheddestination";
NSString const *notAttending = @"notattending";
NSString *appState= @"appstate";

@interface StateManager : NSObject {
    NSString *employeeID;
    Connection *connection;
}
@property(nonatomic)NSString *state;
-(void)start;
-(void)stateAttendingScreen;
-(void)stateWaitingForCab;
-(void)stateBoardedCab;
-(void)stateReachedDestination;
-(void)stateError;
-(void)stateTripEnded;
-(void)notAttending;
@end
