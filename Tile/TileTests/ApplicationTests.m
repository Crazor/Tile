//
//  ApplicationTests.m
//  Tile
//
//  Created by Crazor on 21.03.14.
//  Copyright (c) 2014 Crazor. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Application.h"
#import "TileTesterLauncher.h"

@interface ApplicationTests : XCTestCase

@property TileTesterLauncher *launcher;
@property Application *application;

@end

@implementation ApplicationTests

- (void)setUp
{
    [super setUp];
    _launcher = [[TileTesterLauncher alloc] init];
    [_launcher launchTester];
    _application = [[Application alloc]
                    initWithRunningApplication:[NSRunningApplication
                                                runningApplicationWithProcessIdentifier:
                                                _launcher.task.processIdentifier]];
}

- (void)tearDown
{
    [_launcher terminate];
    [super tearDown];
}

- (void)testPid
{
    XCTAssertEqual(_application.pid, _launcher.task.processIdentifier,
                   @"Application's PID is %d, should be %d.",
                   _application.pid, _launcher.task.processIdentifier);
}

- (void)testName
{
    XCTAssertEqualObjects(_application.name, _launcher.tester.applicationName,
                          @"Application's name is %@, should be %@.",
                          _application.name, _launcher.tester.applicationName);
}

- (void)testWindowCount
{
    XCTAssertEqual(_application.windows.count, _launcher.tester.windowCount,
                   @"Application's window count is %lu, should be %ldd.",
                   (unsigned long)_application.windows.count,
                   (long)_launcher.tester.windowCount);
}

@end




