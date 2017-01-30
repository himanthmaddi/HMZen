//
//  SessionValidator.m
//  Safetrax
//
//  Created by Himanth on 28/06/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "SessionValidator.h"
#import <CommonCrypto/CommonDigest.h>
#import "HeadBundlerClass.h"


@implementation SessionValidator
@synthesize refreshesAccessToken;

-(void)validateAccessToken:(NSString *)userToken;
{
    HeadBundlerClass *head = [[HeadBundlerClass alloc]init];

    NSLog(@"%@",userToken);
    SessionValidator *validator = [[SessionValidator alloc]init];
    NSString *finalNonceString = [[NSUserDefaults standardUserDefaults] stringForKey:@"nonceValue"];
    NSLog(@"%@",finalNonceString);
    NSString *ha1encrypt = [NSString stringWithFormat:@"%@:%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"secretKey"],finalNonceString];
    NSString *ha1 = [self md5:ha1encrypt];
    NSString *requestEncrypt = [NSString stringWithFormat:@"%@:%@",userToken,ha1];
    NSString *refreshRequest = [self md5:requestEncrypt];
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_nonce",finalNonceString,@"oauth_token",userToken,@"oauth_refresh",refreshRequest];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    NSLog(@"%@",finalAuthString);
    NSString *url =[NSString stringWithFormat:@"%@://%@:%@/auth?type=refresh",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
    NSLog(@"%@",url);
    NSURL *finlaUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finlaUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}
- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response %@",response);

}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary *forDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",forDict);
    if ([forDict valueForKey:@""]){
        [[NSUserDefaults standardUserDefaults] setObject:[forDict valueForKey:@"accessToken"] forKey:@"userAccessToken"];
        [[NSUserDefaults standardUserDefaults] setObject:[forDict valueForKey:@"expiresAt"] forKey:@"expiredTime"];
    }
    else if ([forDict valueForKey:@"status"]){
        [self validateAccessToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"]];
    }
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"]);
}
@end
