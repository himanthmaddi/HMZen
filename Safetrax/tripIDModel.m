//
//  tripIDModel.m
//  Safetrax
//
//  Created by Himanth on 03/06/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "tripIDModel.h"

@implementation tripIDModel

-(void)addIdToMutableArray:(NSString *)idString;
{
    _tripIdArray = [[NSMutableArray alloc]init];
    [_tripIdArray addObject:idString];
    NSLog(@"%@",_tripIdArray);
}
-(NSMutableArray *)idsArry;
{
    return _tripIdArray;
}
@end
