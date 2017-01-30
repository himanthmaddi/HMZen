//
//  HeadBundlerClass.h
//  Safetrax
//
//  Created by Himanth on 30/05/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeadBundlerClass : NSObject
{
    NSString *value;
}

@property (nonatomic , strong)      NSString *authType;
@property (nonatomic , strong)      NSString *finalNonceString;
@property (nonatomic , strong)      NSString *versionString;
-(id)initWithType:(NSString *)typeString;
-(void)initWithHeaders:(NSDictionary *)headers;
-(NSString *)headBundlerStringone;
-(NSString *)headBundlerStringtwo;
-(NSString *)headBundlerStringthree;
@end
