//
//  StateManager.m
//  Safetrax
//
// 
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "StateManager.h"

@implementation StateManager

-(void)start{
    //Launch Loading Screen, most likely wont be seen 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *state = [defaults stringForKey:appState];
    //First check if the state is error or trip ended
    if(state == error || state == tripEnded || state == noTrip){
        //If so, send a request asking for current state
        //Update state and view accordingly
    }
  else{
      }
    //If so, send a request asking for current state
    //Update state and view accordingly
    //If the state is any of the map states, start the car updating system
    //When buttons are pressed send state changes to server and update view and local state
}
-(void)stateAttendingScreen{
    
}
-(void)stateWaitingForCab{
    
}
-(void)stateBoardedCab{
    
}
-(void)stateReachedDestination{
    
}
-(void)stateError{
    
}
-(void)stateTripEnded{
    
}
@end
