//
//  WindowControllerTests.m
//  Tile
//
//  Created by Crazor on 21.03.14.
//  Copyright (c) 2014 Crazor. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WindowController.h"

@interface WindowControllerTests : XCTestCase

@end

@implementation WindowControllerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSharedInstance
{
    WindowController *wc1 = [WindowController sharedInstance];
    WindowController *wc2 = [WindowController sharedInstance];
    XCTAssertEqual(wc1, wc2, @"WindowController not a singleton");
}

@end
