//
//  SafetraxTests.m
//  SafetraxTests
//
//  
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ChangePasswordViewController.h"
@interface SafetraxTests : XCTestCase

@end

@implementation SafetraxTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChangePassword
{
    ChangePasswordViewController *change = [[ChangePasswordViewController alloc] init];
    UITextField *fieldone =[[UITextField alloc] init];
    UITextField *field2 =[[UITextField alloc] init];
    UITextField *field3 =[[UITextField alloc] init];
    fieldone.text = @"safe123";
    field2.text = @"safe124";
    field3.text = @"safe124";
    change.passwordFieldOld = fieldone;
    change.passwordFieldOne =field2;
    change.passwordFieldTwo =field3;
    [change changePassword:nil];
 }

@end
