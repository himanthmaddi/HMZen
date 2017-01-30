//
//  TestSOS.m
//  Safetrax
//
//  Created by Kumaran on 08/07/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SOSMainViewController.h"
@interface TestSOS : XCTestCase

@end

@implementation TestSOS

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSOSRequest {
    SOSMainViewController *sosVC = [[SOSMainViewController alloc] init];
    NSString *messsage = @"SOS help";
    BOOL isAttached    = NO;
    NSString *fileName = @"testing.jpg";
    [sosVC sendSosMessage:messsage withFileAttached:isAttached fileName:fileName];
    NSLog(@"sos send testing..");
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
