//
//  GCMRequest.h
//  Safetrax
//
//  Created by Kumaran on 29/12/14.
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import "RequestParams.h"

@interface GCMRequest : RequestParams
{
    NSData *GCMPostParams;
}
-(id)initColumnName:(NSString *)column withMethod:(NSString *)method;
- (void)setPostParams:(NSDictionary *)GCMDictionary;
- (void)setPostParamFromData:(NSData *)paramData;
- (void)setPostParamFromString:(NSString *)paramString;
-(NSURL *)getURL;
-(NSString *)getHTTPMethod;
-(NSData *)getPostParams;

@end
