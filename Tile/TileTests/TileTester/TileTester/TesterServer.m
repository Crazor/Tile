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

#import "TesterServer.h"

@interface TesterServer ()

@property NSConnection *c;

@end

@implementation TesterServer

+ (void)setupTesterServer
{
    static TesterServer *s;
    s = [[TesterServer alloc] init];
    
    s.c = [NSConnection serviceConnectionWithName:@"TesterServer" rootObject:s];
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TileTesterReady" object:nil];
}

- (BOOL)testConnection
{
    NSLog(@"Test successful!");
    return YES;
}

- (NSString *)applicationName
{
    return [[NSProcessInfo processInfo] processName];
}

- (NSInteger)windowCount
{
    return [NSApplication sharedApplication].windows.count;
}

@end
