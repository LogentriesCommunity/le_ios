//
//  lelibTests.m
//  lelibTests
//
//  Created by Petr on 27.10.13.
//  Copyright (c) 2013,2014 Logentries. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "lelib.h"

@interface lelibTests : XCTestCase

@end

@implementation lelibTests

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

- (void)testLog
{
    LELog* log = [LELog sharedInstance];
    log.token = @"f66815d1-702c-414b-8dcc-bb73de372584";
    [log log:@"ahoj"];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    XCTFail(@"Test exited runloop");
}
- (void)testNilToken{
    
    LELog* log = [LELog sharedInstance];
    log.token = nil;
    [log log:@"try to log without token"];

}

@end
