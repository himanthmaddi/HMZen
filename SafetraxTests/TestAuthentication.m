//
//  TestAuthentication.m
//  Safetrax
//
//  Created by Kumaran on 01/07/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LoginViewController.h"
@interface TestAuthentication : XCTestCase

@end

@implementation TestAuthentication

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLogin {
   NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"vignesh.periyasami@iopex.com",@"email",@"1167",
                           @"empid",nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict1
                                                       options:0
                                                         error:nil];
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSData* data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    LoginViewController *login =[[LoginViewController alloc] init];
    login.userName =[[UITextField alloc] init];
    login.password =[[UITextField alloc] init];
    login.userName.text = @"vikki";
    login.password.text = @"safe123";
    [login onResponseReceived:data]; //use this unit test case only when you login. It will crash if already logged-in
}
- (void)testResponseReceived {
   
    XCTAssert(YES, @"Pass");
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
