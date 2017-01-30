//
//  tripIDModel.h
//  Safetrax
//
//  Created by Himanth on 03/06/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tripIDModel : NSObject

@property (nonatomic , strong) NSMutableArray *tripIdArray;
-(void)addIdToMutableArray:(NSString *)idString;
-(NSMutableArray *)idsArry;

@end
