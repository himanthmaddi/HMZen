//
//  TestTransactions.m
//  Safetrax
//
//  Created by Kumaran on 03/07/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "tripSummaryViewController.h"
@interface TestTransactions : XCTestCase

@end

@implementation TestTransactions

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReachedEvent {
    tripSummaryViewController *tripSummary =[[tripSummaryViewController alloc] init];
    [tripSummary mockModel:@"incab"];
    [tripSummary reached:nil];
    // This is an example of a functional test case.
   // XCTAssert(YES, @"Pass");
}
- (void)testBoardingEvent {
    tripSummaryViewController *tripSummary =[[tripSummaryViewController alloc] init];
    [tripSummary mockModel:@"waiting"];
    [tripSummary boarded:nil];
    // This is an example of a functional test case.
    // XCTAssert(YES, @"Pass");
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
