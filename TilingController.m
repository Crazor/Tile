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

#import "TilingController.h"
#import "TilingStrategy.h"
#import "Application.h"
#import "WindowController.h"
#import "Window.h"


static NSScreen         *screen;

@implementation TilingController

+ (TilingController *)sharedInstance
{
    static TilingController *sharedInstance;

    if (!sharedInstance)
    {
        sharedInstance = [[TilingController alloc] init];
    }

    return sharedInstance;
}

- (TilingController *)init
{
    if (self = [super init])
    {
        _strategies = [NSMutableArray array];

        [self discoverScreens];
    }
    
    return self;
}

- (void)setTilingStrategy:(id<TilingStrategy>)aStrategy
{
    _tilingStrategy = aStrategy;
    [_tilingStrategy tileWindows];
}

- (void)addStrategy:(id<TilingStrategy>)aStrategy
{
    if (![_strategies containsObject:aStrategy])
    {
        [_strategies addObject:aStrategy];
        if (!_tilingStrategy)
        {
            _tilingStrategy = aStrategy;
        }
    }
}

- (void)addWindow:(Window *)w
{
    if (
        // catch Finder's desktop window
        !(
          [[[w application] identifier] isEqualToString:@"com.apple.finder"]
          && [w origin].x == 0 && [w origin].y == 0
          && [w size].width == [[TilingController sharedInstance] screenResolution].width
          && [w size].height == [[TilingController sharedInstance] screenResolution].height
          )

        // catch Xcode
        &&
        !(
          [[[w application] identifier] isEqualToString:@"com.apple.dt.Xcode"]
        )
    )
    {
        [_tilingStrategy addWindow:w];
    }
}

- (void)discoverScreens
{
	NSArray *screens = [NSScreen screens];
    
	for (int i = 0; i < [screens count]; i++)
	{
		NSScreen *aScreen = screens[i];
		NSString *mainScreen;
		if (i == 0)
		{
			mainScreen = @"[Main screen]";
			screen = aScreen;
		}
		else
		{
			mainScreen = @"";
		}
		
		log(@"Screen %d: Resolution: %@ %@; Visible Frame: %@", i, [aScreen deviceDescription][NSDeviceSize], mainScreen, NSStringFromSize(aScreen.visibleFrame.size));

		if (i == 0)
		{
			NSRect rect = [aScreen visibleFrame];
            rect.origin.y = 22;
            _toplevelArea = [[Area alloc] initWithRect:rect];
            _screenResolution = [[aScreen deviceDescription][NSDeviceSize] sizeValue];
		}
		else
		{
			log(@"Creating toplevelArea only on main screen for now!");
		}
	}
}

@end
