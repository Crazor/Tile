//
//  UIElementTests.m
//  Tile
//
//  Created by Crazor on 21.03.14.
//  Copyright (c) 2014 Crazor. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIElement.h"
#import "TileTesterLauncher.h"

@interface UIElementTests : XCTestCase

@end

@implementation UIElementTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitWithElementRef
{
    AXUIElementRef r = AXUIElementCreateSystemWide();
    UIElement *e = [[UIElement alloc] initWithElementRef:r];
    XCTAssertEqual(r, [e elementRef]);
}

- (void)testInitWithProcessIdentifier
{
    TileTesterLauncher *launcher = [[TileTesterLauncher alloc] init];
    [launcher launchTester];
    UIElement *e = [[UIElement alloc] initWithProcessIdentifier:launcher.task.processIdentifier];
    pid_t pid;
    AXUIElementGetPid(e.elementRef, &pid);
    XCTAssertEqual(launcher.task.processIdentifier, pid);
    [launcher terminate];
}

@end
