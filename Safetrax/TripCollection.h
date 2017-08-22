//
//  TripCollection.h
//  Safetrax
//
//  Created by Kumaran on 31/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripCollection : NSObject
{
     //NSMutableArray *tripObjIds;
}
+(TripCollection *)buildFromdata:(NSMutableArray*) data;
+(void)initArray;
+(void)initArrayWithOldTrips;
-(void)print;
-(void)sortTrip;
-(void)saveTripArray;
-(NSMutableArray *)getTrip;
-(NSMutableArray *)getTripList;
-(NSDictionary *)getPickup;
-(NSMutableDictionary *)getDrop;
-(void)getTripStartDate;
-(NSMutableArray *)getTripBufferDates;

@property (nonatomic , strong) NSMutableArray *myArray;

@end
