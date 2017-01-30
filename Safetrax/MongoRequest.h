//
//  MongoRequest.h
//  Safetrax
//
//  Created by Kumaran on 29/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "RequestParams.h"

@interface MongoRequest : RequestParams
{
    NSData *MongoPostParams;
    NSString *authString;
}
-(id)initWithTrips;
-(id)initWithQuery:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column;
-(id)initWithQueryUpsert:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column;
-(id)initWithQueryForTrips:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column;
-(id)initWithNewTripStructure:(NSString *)query withMethod:(NSString *)method andColumnName:(NSString *)column;
-(id)initWithSos;
- (void)setPostParams:(NSMutableDictionary *)Username with:(NSMutableDictionary*)codedictionary;
-(NSURL *)getURL;
-(NSString *)getHTTPMethod;
-(NSData *)getPostParams;
-(NSString *)getAuthString;
- (void)setPostParams:(NSDictionary *)GCMDictionary;
- (void)setPostParamFromString:(NSString *)paramString;
-(void)setBody:(NSDictionary *)parameters;
-(void)setAuthString:(NSString *)authorization;
-(void)setBodyFromArray:(NSArray *)params;

@end
