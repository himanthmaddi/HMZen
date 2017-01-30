//
//  SessionValidator.h
//  Safetrax
//
//  Created by Himanth on 28/06/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionValidator : NSObject
{
}
@property (nonatomic , strong) NSString *refreshesAccessToken;
-(void)validateAccessToken:(NSString *)userToken;
@end
