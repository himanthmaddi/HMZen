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
#import <MBProgressHUD.h>

@implementation SessionValidator
@synthesize refreshesAccessToken;

-(void)getNoncewithToken:(NSString *)tokenFrom :(void(^)(NSDictionary *))completionHandler
{
    NSString *oldAcccessToken = tokenFrom;
    __block NSDictionary *resultDictionary;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://72.52.65.142:8083/auth"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"%@",httpResponse);
                if ([response respondsToSelector:@selector(allHeaderFields)]) {
                    resultDictionary = [httpResponse allHeaderFields];
                    HeadBundlerClass *head = [[HeadBundlerClass alloc]init];
                    [head initWithHeaders:resultDictionary];
                    
                    NSString *userToken = oldAcccessToken;
                    NSString *finalNonceString = [[NSUserDefaults standardUserDefaults] stringForKey:@"nonceValue"];
                    NSLog(@"%@",finalNonceString);
                    NSString *ha1encrypt = [NSString stringWithFormat:@"%@:%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"secretKey"],finalNonceString];
                    NSString *ha1 = [self md5:ha1encrypt];
                    NSString *requestEncrypt = [NSString stringWithFormat:@"%@:%@",userToken,ha1];
                    NSString *refreshRequest = [self md5:requestEncrypt];
                    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_nonce",finalNonceString,@"oauth_token",userToken,@"oauth_refresh",refreshRequest];
                    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
                    NSLog(@"%@",finalAuthString);
                    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
                    NSString *url;
                    if ([Port isEqualToString:@"-1"]){
                        url =[NSString stringWithFormat:@"%@://%@/auth?type=refresh",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
                    }else{
                        url =[NSString stringWithFormat:@"%@://%@:%@/auth?type=refresh",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
                    }
                    NSURL *finlaUrl = [NSURL URLWithString:url];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finlaUrl];
                    
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
                    
                    NSError *error;
                    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                    if (resultData != nil){
                        NSDictionary *forDict = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error];
                        NSLog(@"%@",forDict);
                        if ([forDict valueForKey:@"accessToken"]){
                            [[NSUserDefaults standardUserDefaults] setObject:[forDict valueForKey:@"accessToken"] forKey:@"userAccessToken"];
                            [[NSUserDefaults standardUserDefaults] setObject:[forDict valueForKey:@"expiresAt"] forKey:@"expiredTime"];
                            completionHandler(forDict);
                        }
                        else if ([forDict valueForKey:@"status"]){
                            SessionValidator *validator = [[SessionValidator alloc]init];
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                                NSLog(@"%@",result);
                                dispatch_semaphore_signal(semaphore);
                            }];
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        }
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please check your connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"]);
                    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"expiredTime"]);
                }
            }] resume];
    
}

//-(void)validateAccessToken:(NSString *)userToken;
//{
//    self.refreshesAccessToken = userToken;
//    [self getNonce];
//}
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
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        HeadBundlerClass *head = [[HeadBundlerClass alloc]init];
        [head initWithHeaders:dictionary];
    }
    NSString *userToken = self.refreshesAccessToken;
    NSString *finalNonceString = [[NSUserDefaults standardUserDefaults] stringForKey:@"nonceValue"];
    NSLog(@"%@",finalNonceString);
    NSString *ha1encrypt = [NSString stringWithFormat:@"%@:%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"secretKey"],finalNonceString];
    NSString *ha1 = [self md5:ha1encrypt];
    NSString *requestEncrypt = [NSString stringWithFormat:@"%@:%@",userToken,ha1];
    NSString *refreshRequest = [self md5:requestEncrypt];
    NSString *headerString = [NSString stringWithFormat:@"%@=%@,%@=%@,%@=%@",@"oauth_nonce",finalNonceString,@"oauth_token",userToken,@"oauth_refresh",refreshRequest];
    NSString *finalAuthString = [NSString stringWithFormat:@"%@ %@",@"OAuth",headerString];
    NSLog(@"%@",finalAuthString);
    NSString *Port =[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"];
    NSString *url;
    if ([Port isEqualToString:@"-1"]){
        url =[NSString stringWithFormat:@"%@://%@/auth?type=refresh",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"]];
    }else{
        url =[NSString stringWithFormat:@"%@://%@:%@/auth?type=refresh",[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoScheme"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoHost"],[[NSUserDefaults standardUserDefaults] stringForKey:@"mongoPort"]];
    }
    NSLog(@"%@",url);
    NSURL *finlaUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finlaUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:finalAuthString forHTTPHeaderField:@"Authorization"];
    
    NSError *error;
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (resultData != nil){
        NSDictionary *forDict = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:&error];
        if ([forDict valueForKey:@"accessToken"]){
            [[NSUserDefaults standardUserDefaults] setObject:[forDict valueForKey:@"accessToken"] forKey:@"userAccessToken"];
            [[NSUserDefaults standardUserDefaults] setObject:[forDict valueForKey:@"expiresAt"] forKey:@"expiredTime"];
        }
        else if ([forDict valueForKey:@"status"]){
            SessionValidator *validator = [[SessionValidator alloc]init];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [validator getNoncewithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"] :^(NSDictionary *result){
                NSLog(@"%@",result);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }else{
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please check your connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //        [alert show];
    }
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userAccessToken"]);
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"expiredTime"]);
    
}
@end
