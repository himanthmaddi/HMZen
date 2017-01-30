//
//  MongoRequest.m
//  Safetrax
//
//  Created by Kumaran on 29/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "MongoRequest.h"

@implementation MongoRequest

-(id)initWithQuery:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column
{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
     if([Port isEqualToString:@"-1"])
     {
        url =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],query,[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],column];
     }
    else
        {
        url =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],query,[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],column];
         }
    URL =[NSURL URLWithString:url];
    HTTPMethod =method;
    return self;
}
-(id)initWithQueryForTrips:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column;
{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
        url =[NSString stringWithFormat:@"%@://%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/markconfirmation?mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
    }
    URL =[NSURL URLWithString:url];
    HTTPMethod =method;
    return self;
}
-(id)initWithNewTripStructure:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column
{
    NSString *url;
    url =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@&mode=app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],query,[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],column];
    URL =[NSURL URLWithString:url];
    HTTPMethod =method;
    return self;
}
-(id)initWithQueryUpsert:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column
{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
      url =[NSString stringWithFormat:@"%@://%@/%@?dbname=%@&colname=%@&upsert=true",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],query,[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],column];
    }
        else
        {
             url =[NSString stringWithFormat:@"%@://%@:%@/%@?dbname=%@&colname=%@&upsert=true",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"],query,[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoDbName"],column];
        }
    URL =[NSURL URLWithString:url];
    HTTPMethod =method;
    return self;
}
-(id)initWithSos;
{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
        url =[NSString stringWithFormat:@"%@://%@/triggersosapp?mode=ios-app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/triggersosapp?mode=ios-app",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
    }
    URL =[NSURL URLWithString:url];
    NSLog(@"%@",URL);
    HTTPMethod =@"POST";
    return self;
}
- (id)initWithTrips {
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
      url =[NSString stringWithFormat:@"%@://%@/trips",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"]];
    }
    else
    {
         url =[NSString stringWithFormat:@"%@://%@:%@/trips",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"]];
    }
    URL =[NSURL URLWithString:url];
    HTTPMethod =@"POST";
    return self;
}
- (void)setPostParamFromString:(NSString *)paramString
{
    NSData* finalJson = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    MongoPostParams =finalJson;
}
- (void)setPostParams:(NSDictionary *)GCMDictionary
{
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:GCMDictionary options:kNilOptions error:&error];
//    MongoPostParams =jsonData;
}
- (void)print{
    NSLog(@"url: %@", URL);
    NSLog(@"type: %@", HTTPMethod);
}
-(NSURL *)getURL
{
    NSLog(@"%@",URL);
    return URL;
}
-(NSString *)getHTTPMethod
{
    return HTTPMethod;
}
-(NSData *)getPostParams
{
    return MongoPostParams;
}
-(NSString *)getAuthString
{
    return authString;
}
-(void)setBody:(NSDictionary *)parameters{
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:@"tempData"];
    NSString *finalStrin = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",finalStrin);
    MongoPostParams = jsonData;
}
-(void)setAuthString:(NSString *)authorization{
    
    authString = authorization;
}
-(void)setBodyFromArray:(NSArray *)params{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
    NSString *finalStrin = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",finalStrin);
    MongoPostParams = jsonData;
}
@end
