//
//  tripsTest.m
//  Safetrax
//
//  Created by Kumaran on 02/07/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HomeViewController.h"
@interface tripsTest : XCTestCase

@end

@implementation tripsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTripCollection {
   NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"tripid",@"538f87ade4b0254ee2395b5c",@"1167",
        @"driverLicence",@"[80.168501,13.094579]",@"dropLngLat",@"Moolakadai junction",@"pickup",@"Kumasar",@"driverName",@"Pickup",@"tripType",@"8754875308",@"driverPhone",nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSData* data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    HomeViewController *home = [[HomeViewController alloc] init];
    //[home onResponseReceived:data];
    [home onFinishLoading];
    // This is an example of a functional test case.
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
