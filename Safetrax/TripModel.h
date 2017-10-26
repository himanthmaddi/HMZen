//
//  TripModel.h
//  Safetrax
//
//  Created by Kumaran on 31/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripModel : NSObject

{
    
}
@property (nonatomic, retain)  NSString * driverId;
@property (nonatomic, retain)  NSString * driverName;
@property (nonatomic, retain)  NSString * tripid;
@property (nonatomic, retain)  NSString * driverLicence;
@property (nonatomic, retain)  NSArray * pickupLngLat;
@property (nonatomic, retain)  NSString * driverid;
@property (nonatomic, retain)  NSString * scheduledTime;
@property (nonatomic, retain)  NSString * tripEndTime;
@property (nonatomic, retain)  NSString * driverPhone;
@property (nonatomic, retain)  NSString * empstatus;
@property (nonatomic, retain)  NSString * cabId;
@property (nonatomic, retain)  NSString * cabstops;
@property (nonatomic, retain)  NSString * driverBluetooth;
@property (nonatomic, retain)  NSArray * dropLngLat;
@property (nonatomic, retain)  NSString * drop;
@property (nonatomic, retain)  NSString * tripCabPictures;
@property (nonatomic, retain)  NSString * pickup;
@property (nonatomic, retain)  NSString * tripType;
@property (nonatomic, retain)  NSArray * cabWaypoints;
@property (nonatomic, retain)  NSDictionary * pickupDictionary;
@property (nonatomic, retain)  NSDictionary * dropDictionary;
@property (nonatomic , retain) NSString *vehicleId;
@property (nonatomic , retain) NSMutableArray *stopsNames;
@property (nonatomic , retain) NSMutableArray *stopTimes;
@property (nonatomic, retain)  NSString * cabNumber;
@property (nonatomic , retain) NSArray *stoppagesArray;
@property (nonatomic , retain) NSArray *employeeInfoAray;
@property (nonatomic , retain) NSDate *bufferStartDate;
@property (nonatomic , retain) NSDate *actualStartDate;
@property (nonnull , retain) NSString *tripBufferStartTime;
@property (nonatomic , assign) BOOL entryTime;
@property (nonatomic , assign) BOOL exitTime;
@property (nonatomic , retain) NSString *employeePin;
@property (nonnull , strong) NSDictionary *deploymentBand;
@property (nonatomic, retain)  NSString * office;

+(TripModel*) buildFromNSDictionary:(NSDictionary *)tripDictionary;
@end

