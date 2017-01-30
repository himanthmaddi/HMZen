//
//  GCMRequest.m
//  Safetrax
//
//  Created by Kumaran on 29/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "GCMRequest.h"
@implementation GCMRequest
- (id)init{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {

      url =[NSString stringWithFormat:@"%@://%@/auth",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"]];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/auth",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"]];

    }
    URL =[NSURL URLWithString:url];
    HTTPMethod = @"POST";
    return self;
}
-(id)initColumnName:(NSString *)column withMethod:(NSString *)method
{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
       url =[NSString stringWithFormat:@"%@://%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],column];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"],column];
    }
    URL =[NSURL URLWithString:url];
    HTTPMethod =method;
    return self;
}
-(id)initGcmId:(NSString *)query withMethod:(NSString *)method
{
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"];
    NSString *url;
    if([Port isEqualToString:@"-1"])
    {
      url =[NSString stringWithFormat:@"%@://%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],query];
    }
    else
    {
        url =[NSString stringWithFormat:@"%@://%@:%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"gcmPort"],query];
    }
    URL =[NSURL URLWithString:url];
    HTTPMethod =method;
    return self;
}
- (void)setPostParamFromString:(NSString *)paramString
{
    NSData* finalJson = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    GCMPostParams =finalJson;
}
- (void)setPostParamFromData:(NSData *)paramData
{
   GCMPostParams =paramData;
}
- (void)setPostParams:(NSDictionary *)GCMDictionary
{
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:GCMDictionary options:kNilOptions error:&error];
    GCMPostParams =jsonData;
}
- (void)print{
    NSLog(@"url: %@", URL);
    NSString *newStr = [[NSString alloc] initWithData:GCMPostParams encoding:NSUTF8StringEncoding];
    NSLog(@"param:----%@",newStr);
}
-(NSURL *)getURL
{
    return URL;
}
-(NSString *)getHTTPMethod
{
    return HTTPMethod;
}
-(NSData *)getPostParams
{
    return GCMPostParams;
}

@end
