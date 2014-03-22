//
//  TileTesterLauncher.m
//  Tile
//
//  Created by Crazor on 21.03.14.
//  Copyright (c) 2014 Crazor. All rights reserved.
//

#import "TileTesterLauncher.h"


@interface TileTesterLauncher ()

@property BOOL testerReady;

@end

@implementation TileTesterLauncher

- (id)init
{
    if (self = [super init])
    {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(testerReadyNotification:) name:@"TileTesterReady" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_task terminate];
}

- (void)testerReadyNotification:(NSNotification *)notification
{
    _testerReady = YES;
}

- (void)launchTester
{
    _task = [NSTask launchedTaskWithLaunchPath:[[NSBundle bundleForClass:self.class].bundlePath stringByAppendingPathComponent:@"../TileTester.app/Contents/MacOS/TileTester"] arguments:@[]];

    while(!_testerReady)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
    }

    NSConnection *connection = [NSConnection connectionWithRegisteredName:@"TesterServer" host:nil];
    connection.requestTimeout = 10;
    connection.replyTimeout = 10;

    _tester = (id<TileTesterProtocol>)[connection rootProxy];
    [(id)_tester setProtocolForProxy:@protocol(TileTesterProtocol)];
}

- (void)terminate
{
    [_task terminate];
}

@end
