/*
 * This file is part of the Tile project.
 *
 * Copyright 2014 Crazor <crazor@gmail.com>
 *
 * Tile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Tile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Tile.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <XCTest/XCTest.h>
#import "TileTester/TileTester/TileTesterProtocol.h"

@interface TileTests : XCTestCase

@property NSTask *task;
@property BOOL testerRunning;
@property id tester;

@end

@implementation TileTests

+ (void)setUp
{
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(testerRunningNotification:) name:@"TileTesterReady" object:nil];
}

- (void)setUp
{
    [super setUp];
}

- (void)launchTester
{
    _task = [NSTask launchedTaskWithLaunchPath:[NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"../TileTester.app/Contents/MacOS/TileTester"] arguments:@[]];
    
    while(!_testerRunning)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    NSConnection *connection = [NSConnection connectionWithRegisteredName:@"TesterServer" host:nil];
    connection.requestTimeout = 10;
    connection.replyTimeout = 10;
    
    _tester = [connection rootProxy];
    [_tester setProtocolForProxy:@protocol(TileTesterProtocol)];
}

- (void)testerRunningNotification:(NSNotification *)notification
{
    _testerRunning = YES;
}

- (void)tearDown
{
    [_task terminate];
    [super tearDown];
}

- (void)testRunning
{
    [self launchTester];
    XCTAssertTrue([_tester testConnection], @"Connection to Tester failed.");
}

@end
