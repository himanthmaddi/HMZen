//
//  TripCollection.m
//  Safetrax
//
//  Created by Kumaran on 31/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "TripCollection.h"
#import "TripModel.h"
static NSMutableArray *tripList;
@implementation TripCollection

+ (void)initArray
{
    
    static dispatch_once_t onceToken;
    tripList = [[NSMutableArray alloc] init];
    
}
+ (void)initArrayWithOldTrips
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *myDecodedObject = [userDefault objectForKey: [NSString stringWithFormat:@"tripList"]];
    NSArray *decodedArray =[NSKeyedUnarchiver unarchiveObjectWithData: myDecodedObject];
    NSLog(@"%@",decodedArray);
    tripList = [NSMutableArray arrayWithArray:decodedArray];
}
+(TripCollection *)buildFromdata:(NSMutableArray*) data{
    NSLog(@"%@",data);
    //    tripList =[[NSMutableArray alloc] init];
    TripCollection *tripCollection = [[TripCollection alloc] init];
    //    NSArray *tripsArray= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //    NSMutableArray *myTripsArray = [tripsArray mutableCopy];
    
    NSMutableArray *myTripsArray = data;
    
    for (NSDictionary *tripFields in myTripsArray) {
        TripModel * tripmodel = [TripModel buildFromNSDictionary:tripFields];
        [tripCollection addTrip:tripmodel];
    }
    
    //    for (NSDictionary *dict in [myTripsArray copy]){
    //        if ([[dict valueForKey:@"stateOfTrip"] isEqualToString:@"deployed"] && ![[dict valueForKey:@"runningStatus"] isEqualToString:@"completed"]){
    //            NSArray *employees = [dict valueForKey:@"employees"];
    //            for (NSDictionary *eachEmployee in employees){
    //                if ([[eachEmployee valueForKey:@"_employeeId"] isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeId"]]){
    //                    if (![[eachEmployee valueForKey:@"cancelled"] boolValue]){
    //                        for (NSDictionary *tripFields in myTripsArray) {
    //                            TripModel * tripmodel = [TripModel buildFromNSDictionary:tripFields];
    //                            [tripCollection addTrip:tripmodel];
    //                        }
    //                    }else{
    //                        int index = [myTripsArray indexOfObject:dict];
    //                        [myTripsArray removeObjectAtIndex:index];
    //                    }
    //                }
    //            }
    //            }else{
    //                int index = [myTripsArray indexOfObject:dict];
    //                [myTripsArray removeObjectAtIndex:index];
    //        }
    //    }
    
    return tripCollection;
}

- (void)addTrip:(TripModel*) tripModel
{
    NSLog(@"triplist %@ - %@",tripList,tripModel);
    NSLog(@"%@",tripModel);
    NSLog(@"%@",tripList);
    tripList = [tripList mutableCopy];
    [tripList addObject:tripModel];
    NSLog(@"%@",tripList);
    NSLog(@"trip added %@",tripList);
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:tripList];
    [userDefault setObject:myEncodedObject forKey:[NSString stringWithFormat:@"tripList"]];
    // [[NSUserDefaults standardUserDefaults] setObject:tripList forKey:@"tripList"];
}
-(void)sortTrip
{
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scheduledTime" ascending:YES];
    NSMutableArray *descriptors = [NSMutableArray arrayWithObject:valueDescriptor];
    NSMutableArray *sortedArray = [tripList sortedArrayUsingDescriptors:descriptors];
    tripList = sortedArray;
}
-(NSMutableDictionary *)getDrop {
    NSString *tripStr;
    NSMutableDictionary *tripdetails = [[NSMutableDictionary alloc] init];
    NSInteger count =[tripList count];
    for(int i=0;i<count;i++)
    {
        TripModel *model =[tripList objectAtIndex:i];
        NSString *dateString = model.scheduledTime;
        NSLog(@"%@",model.scheduledTime);
        NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
        [dateFormatters setDateFormat:@"yyyy/MM/DD--HH:mm:ss"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatters dateFromString:dateString];
        NSString * deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        dateFormatters = [NSDateFormatter new];
        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguage];
        [dateFormatters setDateFormat:@"EEEE dd MMMM"];
        [dateFormatters setLocale:locale];
        dateString = [dateFormatters stringFromDate:dateFromString];
        [dateFormatters setDateFormat:@"yyyy/MM/DD--HH:mm"];
        NSString *stringFromDate = [dateFormatters stringFromDate:dateFromString];
        NSInteger integerDate = [stringFromDate integerValue];
        tripStr =@"";
        NSString *drop=@"";
        if([model.drop length] >20)
            drop = [[model.drop substringToIndex:20] stringByAppendingString:@"..."];
        else
            drop = model.drop;
        
#if Parent
        if([model.tripType isEqualToString:@"Drop"])
        {
            
            tripStr = [NSString stringWithFormat:@"%@ trip @ %@\n%@\nVehicle No: %@\nDriver: %@ &&%@&&%@", model.tripType,[model.tripEndTime substringWithRange:NSMakeRange(12, 5)],drop,model.driverLicence,model.driverName,model.tripEndTime,model.scheduledTime];
            [tripdetails setValue:tripStr forKey:model.scheduledTime];
        }
#else
        if([model.tripType isEqualToString:@"Drop"])
        {
            tripStr = [NSString stringWithFormat:@"%@ trip @ %@\n%@\n%@\nVehicle No: %@\nDriver: %@&&%@&&%@&&%@", model.tripType,model.scheduledTime,[NSString stringWithFormat:@"From: %@",model.office],[NSString stringWithFormat:@"To: %@",model.drop],model.cabNumber,model.driverName,model.tripEndTime,model.scheduledTime,model.tripid];
            [tripdetails setValue:tripStr forKey:model.scheduledTime];
            NSLog(@"%@",tripStr);
        }
#endif
    }
    return tripdetails;
}
-(NSMutableDictionary *)getPickup {
    NSString *tripStr;
    NSMutableDictionary *tripdetails = [[NSMutableDictionary alloc] init];
    NSInteger count =[tripList count];
    for(int i=0;i<count;i++)
    {
        TripModel *model =[tripList objectAtIndex:i];
        NSString *dateString = model.scheduledTime;
        NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
        [dateFormatters setDateFormat:@"yyyy/MM/DD--HH:mm:ss"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatters dateFromString:dateString];
        NSString * deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        dateFormatters = [NSDateFormatter new];
        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguage];
        [dateFormatters setDateFormat:@"EEEE dd MMMM"];
        [dateFormatters setLocale:locale];
        dateString = [dateFormatters stringFromDate:dateFromString];
        [dateFormatters setDateFormat:@"yyyy/MM/DD--HH:mm"];
        NSString *stringFromDate = [dateFormatters stringFromDate:dateFromString];
        NSInteger integerDate = [stringFromDate integerValue];
        tripStr =@"";
        NSString *pickup=@"";
        if([model.pickup length] >20)
            pickup = [[model.pickup substringToIndex:20] stringByAppendingString:@"..."];
        else
            pickup = model.pickup;
#if Parent
        if([model.tripType isEqualToString:@"Pickup"]){
            NSLog(@"pickup id %@",model.tripid);
            tripStr = [NSString stringWithFormat:@"%@ trip @ %@\n%@\nVehicle No: %@\nDriver: %@ &&%@&&%@", model.tripType,[model.scheduledTime substringWithRange:NSMakeRange(12, 5)],pickup,model.driverLicence,model.driverName,model.tripEndTime,model.scheduledTime];
            [tripdetails setValue:tripStr forKey:model.scheduledTime];
        }
#else
        if([model.tripType isEqualToString:@"Pickup"]){
            NSLog(@"pickup id %@",model.tripid);
            tripStr = [NSString stringWithFormat:@"%@ trip @ %@\n%@\n%@\nVehicle No: %@\nDriver: %@&&%@&&%@&&%@", model.tripType,model.scheduledTime,[NSString stringWithFormat:@"From: %@",model.pickup],[NSString stringWithFormat:@"To: %@",model.drop],model.cabNumber,model.driverName,model.tripEndTime,model.scheduledTime,model.tripid];
            [tripdetails setValue:tripStr forKey:model.scheduledTime];
        }
#endif
    }
    return tripdetails;
}
-(NSMutableArray *)getTripList
{
    return tripList;
}
-(void)saveTripArray
{
    /*NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
     NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:tripList];
     [userDefault setObject:myEncodedObject forKey:[NSString stringWithFormat:@"sample"]];
     NSData *myDecodedObject = [userDefault objectForKey: [NSString stringWithFormat:@"sample"]];
     NSArray *decodedArray =[NSKeyedUnarchiver unarchiveObjectWithData: myDecodedObject];
     for (TripModel *item in decodedArray) {
     //  NSLog(@"name=%@",item.driverName);
     }*/
}
//-(void)getTripStartDate;
//{
//    NSInteger count =[tripList count];
//    for(int i=0;i<count;i++)
//    {
//        TripModel *model =[tripList objectAtIndex:i];
//        NSLog(@"%@",model.tripBufferStartTime);
//    }
//}
-(NSMutableArray *)getTripBufferDates;
{
    NSMutableArray *timesArray = [[NSMutableArray alloc]init];
    NSInteger count =[tripList count];
    for(int i=0;i<count;i++)
    {
        TripModel *model =[tripList objectAtIndex:i];
        NSLog(@"%@",model.tripBufferStartTime);
        [timesArray addObject:model.tripBufferStartTime];
    }
    return timesArray;
}
@end
