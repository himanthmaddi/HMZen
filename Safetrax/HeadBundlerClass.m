//
//  HeadBundlerClass.m
//  Safetrax
//
//  Created by Himanth on 30/05/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "HeadBundlerClass.h"
#import "LoginViewController.h"

@implementation HeadBundlerClass
@synthesize authType,finalNonceString;

-(id)initWithType:(NSString *)typeString{
    self = [super init];
    if (self) {
        authType = typeString;
    }
    return self;
}
-(void)initWithHeaders:(NSDictionary *)headers;
{
    NSLog(@"%@",headers);
    NSString *authenticateString = [headers valueForKey:@"Www-Authenticate"];
    NSArray *allArray = [authenticateString componentsSeparatedByString:@","];
    NSString *realmString = [allArray objectAtIndex:0];
    NSString *nonceString = [allArray objectAtIndex:1];
    NSString *versionString = [allArray objectAtIndex:2];
    NSArray *myArray = [realmString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    [[myArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *secondArray = [nonceString componentsSeparatedByString:@"="];
    [[secondArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *thirdArray = [versionString componentsSeparatedByString:@"="];
    [[thirdArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"^\"|\"$"];
    //here we are deleting special characters from main string
    value = [[[myArray objectAtIndex:1] componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    finalNonceString = [[[secondArray objectAtIndex:1] componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
//    finalNonceString = [NSString stringWithFormat:@"%@%@",finalNonceString,@"=="];
    LoginViewController *logIn = [[LoginViewController alloc]init];
    NSLog(@"final nonce string %@",finalNonceString);
    [[NSUserDefaults standardUserDefaults] setObject:finalNonceString forKey:@"nonceValue"];
    [logIn getHeadBundlerValue:finalNonceString];
}
-(NSString *)headBundlerStringone{
    NSString *headBundlerString = [NSString stringWithFormat:@"%@",finalNonceString];
    if (value == nil){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"alert" message:@"head bundler type not recognized" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    return headBundlerString;
}
@end

