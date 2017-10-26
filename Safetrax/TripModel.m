//
//  TripModel.m
//  Safetrax
//
//  Created by Kumaran on 31/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "TripModel.h"

@implementation TripModel
@synthesize driverId;
+(TripModel*) buildFromNSDictionary:(NSDictionary *)tripDictionary {
    NSLog(@"%@",tripDictionary);
    NSDateFormatter *dateFormatter123 = [[NSDateFormatter alloc]init];
    [dateFormatter123 setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    TripModel *tripModel = [[TripModel alloc] init];
    if ([[tripDictionary valueForKey:@"tripLabel"] isEqualToString:@"login"]){
        tripModel.tripType=@"Pickup";
    }
    else{
        tripModel.tripType=@"Drop";
    }
    tripModel.bufferStartDate = [NSDate dateWithTimeIntervalSince1970:([[tripDictionary valueForKey:@"bufferStartTime"] doubleValue]/1000.0)];
    NSLog(@"%@",tripModel.bufferStartDate);
    tripModel.tripBufferStartTime = [dateFormatter123 stringFromDate:tripModel.bufferStartDate];
    tripModel.stopsNames = [[NSMutableArray alloc]init];
    tripModel.stopTimes = [[NSMutableArray alloc]init];
    NSMutableArray *timeArray = [[NSMutableArray alloc]init];
    tripModel.vehicleId = [[[tripDictionary valueForKey:@"vehicle"] valueForKey:@"_id"]valueForKey:@"$oid"];
    tripModel.driverId=[[[tripDictionary valueForKey:@"driver"] valueForKey:@"_id"] valueForKey:@"$oid"];
    tripModel.driverName=[[tripDictionary valueForKey:@"driver"] valueForKey:@"fullName"];
    
    tripModel.tripid = [[tripDictionary valueForKey:@"_id"] valueForKey:@"$oid"];
    
    tripModel.driverLicence=[[tripDictionary valueForKey:@"driver"] valueForKey:@"licenseNumber"];
    tripModel.driverid=[[tripDictionary valueForKey:@"driver"] valueForKey:@"_id"];
    
    tripModel.driverPhone=[[tripDictionary valueForKey:@"driver"] valueForKey:@"mobile"];
    tripModel.cabId=[[tripDictionary valueForKey:@"vehicle"] valueForKey:@"_id"];
    tripModel.cabNumber = [[tripDictionary valueForKey:@"vehicle"] valueForKey:@"registrationNumber"];
    NSString *employeeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"];
    
    NSArray *stops = [tripDictionary valueForKey:@"stoppages"];
    tripModel.stoppagesArray = stops;
    for (NSDictionary *tempDict in stops)
    {
        
        if ([[tripDictionary valueForKey:@"tripLabel"] isEqualToString:@"login"]){
            NSDate *tripEndDate = [NSDate dateWithTimeIntervalSince1970:([[tripDictionary valueForKey:@"endTime"] doubleValue]/1000.0)];
            tripModel.tripEndTime = [dateFormatter123 stringFromDate:tripEndDate];
        }else{
            if ([[tempDict objectForKey:@"_drop"] containsObject:employeeId]){
                NSDate *tripEndDate = [NSDate dateWithTimeIntervalSince1970:([[tempDict valueForKey:@"time"] doubleValue]/1000.0)];
                tripModel.tripEndTime = [dateFormatter123 stringFromDate:tripEndDate];
            }else{
                
            }
        }
        if ([[tempDict valueForKey:@"type"] isEqualToString:@"office"]){
            tripModel.office = [tempDict valueForKey:@"name"];
        }
        [tripModel.stopsNames addObject:[tempDict valueForKey:@"name"]];
        [timeArray addObject:[tempDict valueForKey:@"time"]];
        NSArray *idsArrayForPickup = [tempDict valueForKey:@"_pickup"];
        NSArray *idsArrayForDrop = [tempDict valueForKey:@"_drop"];
        if (idsArrayForPickup.count != 0){
            if ([idsArrayForPickup containsObject:employeeId])
            {
                tripModel.pickup=tempDict[@"name"];
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:([[tempDict valueForKey:@"time"] doubleValue]/1000.0)];
                tripModel.scheduledTime=[dateFormatter123 stringFromDate:startDate];
                tripModel.pickupLngLat=tempDict[@"coordinates"];
                tripModel.actualStartDate = startDate;
                if ([tempDict valueForKey:@"entryTime"] || [tempDict valueForKey:@"exitTime"]){
                    tripModel.entryTime = YES;
                }else{
                    tripModel.entryTime = NO;
                }
            }
        }
        if (idsArrayForDrop.count != 0){
            if ([idsArrayForDrop containsObject:employeeId])
            {
                tripModel.drop=tempDict[@"name"];
                tripModel.dropLngLat=tempDict[@"coordinates"];
            }
        }
    }
    NSMutableArray *copassengersArray = [[NSMutableArray alloc]init];
    NSMutableArray *copassengetPhoneArray = [[NSMutableArray alloc]init];
    NSArray *employeesArray = [tripDictionary valueForKey:@"employees"];
    tripModel.employeeInfoAray = employeesArray;
    
    for (NSDictionary *employeeInfoDict in employeesArray){
        [copassengersArray addObject:[employeeInfoDict valueForKey:@"fullName"]];
        [copassengetPhoneArray addObject:[employeeInfoDict valueForKey:@"mobile"]];
        NSString *idString = [employeeInfoDict valueForKey:@"_employeeId"];
        if ([idString isEqualToString:employeeId]){
            
            
            if ([employeeInfoDict valueForKey:@"pin"] || [employeeInfoDict valueForKey:@"pin"] != nil){
                tripModel.employeePin = [employeeInfoDict valueForKey:@"pin"];
            }else{
                tripModel.employeePin = @"NA";
            }
            
            tripModel.deploymentBand = [employeeInfoDict valueForKey:@"deploymentBand"];
            
            
            if (([employeeInfoDict valueForKey:@"waiting"] && [employeeInfoDict valueForKey:@"boarded"] && [employeeInfoDict valueForKey:@"reached"]) || ([employeeInfoDict valueForKey:@"boarded"] && [employeeInfoDict valueForKey:@"reached"]) || [employeeInfoDict valueForKey:@"reached"]){
                
                if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"] containsObject:tripModel.tripid]){
                }else{
                    NSArray *userdefaultsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ratingCompletedTrips"];
                    userdefaultsArray = [NSArray arrayWithObject:tripModel.tripid];
                    [[NSUserDefaults standardUserDefaults] setObject:userdefaultsArray forKey:@"ratingCompletedTrips"];
                    NSDictionary *info = @{@"tripId":tripModel.tripid};
                    
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"tripCompleted" object:info];
                }
                
                tripModel.empstatus = @"reached";
            }
            else if (([employeeInfoDict valueForKey:@"waiting"] && [employeeInfoDict valueForKey:@"boarded"]) || [employeeInfoDict valueForKey:@"boarded"])
            {
                tripModel.empstatus=@"incab";
            }
            else if([employeeInfoDict valueForKey:@"waiting"]){
                tripModel.empstatus=@"waiting_cab";
            }
            else{
                tripModel.empstatus = @"bufferTime";
            }
        }
    }
    for (int i=0;i<copassengersArray.count;i++){
        
        [copassengersArray removeObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"name"]];
        [copassengetPhoneArray removeObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"phonenum"]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:copassengersArray forKey:@"copassengers"];
    [[NSUserDefaults standardUserDefaults] setObject:copassengetPhoneArray forKey:@"copassengerPhoneArray"];
    for (int i=0;i<timeArray.count;i++){
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([[timeArray objectAtIndex:i] doubleValue]/1000.0)];
        NSString *dateString = [dateFormatter123 stringFromDate:date];
        [tripModel.stopTimes addObject:dateString];
    }
    return tripModel;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.driverId forKey:@"driverid"];
    [encoder encodeObject:self.driverName forKey:@"driverPhone"];
    [encoder encodeObject:self.tripid forKey:@"tripid"];
    [encoder encodeObject:self.driverLicence forKey:@"driverLicence"];
    [encoder encodeObject:self.pickupLngLat forKey:@"pickupLngLat"];
    [encoder encodeObject:self.driverid forKey:@"driverid"];
    [encoder encodeObject:self.scheduledTime forKey:@"scheduledTime"];
    [encoder encodeObject:self.tripEndTime forKey:@"tripEndTime"];
    [encoder encodeObject:self.empstatus forKey:@"empstatus"];
    [encoder encodeObject:self.cabId forKey:@"cabId"];
    [encoder encodeObject:self.cabstops forKey:@"cabstops"];
    [encoder encodeObject:self.driverBluetooth forKey:@"driverBluetooth"];
    [encoder encodeObject:self.dropLngLat forKey:@"dropLngLat"];
    [encoder encodeObject:self.tripCabPictures forKey:@"tripCabPictures"];
    [encoder encodeObject:self.drop forKey:@"drop"];
    [encoder encodeObject:self.pickup forKey:@"pickup"];
    [encoder encodeObject:self.tripType forKey:@"tripType"];
    [encoder encodeObject:self.cabWaypoints forKey:@"cabWaypoints"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.driverId = [decoder decodeObjectForKey:@"driverid"];
        self.driverName =[decoder decodeObjectForKey:@"driverPhone"];
        self.tripid =[decoder decodeObjectForKey:@"tripid"];
        self.driverLicence =[decoder decodeObjectForKey:@"driverLicence"];
        self.pickupLngLat =[decoder decodeObjectForKey:@"pickupLngLat"];
        self.driverid =[decoder decodeObjectForKey:@"driverid"];
        self.scheduledTime= [decoder decodeObjectForKey:@"scheduledTime"];
        self.tripEndTime =[decoder decodeObjectForKey:@"tripEndTime"];
        self.empstatus =[decoder decodeObjectForKey:@"empstatus"];
        self.cabId= [decoder decodeObjectForKey:@"cabId"];
        self.cabstops =[decoder decodeObjectForKey:@"cabstops"];
        self.driverBluetooth= [decoder decodeObjectForKey:@"driverBluetooth"];
        self.dropLngLat= [decoder decodeObjectForKey:@"dropLngLat"];
        self.tripCabPictures= [decoder decodeObjectForKey:@"tripCabPictures"];
        self.drop= [decoder decodeObjectForKey:@"drop"];
        self.pickup =[decoder decodeObjectForKey:@"pickup"];
        self.tripType= [decoder decodeObjectForKey:@"tripType"];
        self.cabWaypoints= [decoder decodeObjectForKey:@"cabWaypoints"];
    }
    return self;
}


@end

