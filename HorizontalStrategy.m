/*
 * This file is part of the Tile project.
 *
 * Copyright 2009-2012 Crazor <crazor@gmail.com>
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

#import "HorizontalStrategy.h"
#import "TilingController.h"
#import "Window.h"

static HorizontalStrategy *sharedInstance;

@implementation HorizontalStrategy
{
    NSMutableArray *windows;
}

@synthesize area = _area;

+(void)load
{
    [[TilingController sharedInstance] addStrategy:[HorizontalStrategy sharedInstance]];
}

+(HorizontalStrategy *)sharedInstance
{
    static HorizontalStrategy *sharedInstance;

    if (!sharedInstance)
    {
        sharedInstance = [[HorizontalStrategy alloc] init];
    }

    return sharedInstance;
}

-(HorizontalStrategy *)init
{
    if (self = [super init])
    {
        windows = [[NSMutableArray alloc] init];
        _area = [[TilingController sharedInstance] toplevelArea];
    }
    return self;
}

-(void)addWindow:(Window *)aWindow
{
    [windows addObject:aWindow];
}

-(void)addWindows:(NSArray *)someWindows
{
	for (Window *w in someWindows)
	{
		[self addWindow:w];
	}
}

- (void)tileWindows
{
    NSMutableArray *windowsToTile = [NSMutableArray array];

    for (Window *w in windows)
    {
        if (![w isMinimized])
        {
            [windowsToTile addObject:w];
        }
    }

    if (windowsToTile.count == 0)
    {
        NSLog(@"No windows to tile!");
        return;
    }

    int height = _area.height / windowsToTile.count;
    NSPoint currentOrigin = _area.rect.origin;
    NSSize size = {_area.width, height};
	for (Window *w in windowsToTile)
    {
        [w setOrigin:currentOrigin];
        [w setSize:size];
        NSLog(@"Window %@ origin %@ size %@", w, NSStringFromPoint(currentOrigin), NSStringFromSize(size));
        currentOrigin.y += height;
    }
}

@end
