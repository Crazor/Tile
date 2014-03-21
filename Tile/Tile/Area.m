/*
 * This file is part of the Tile project.
 *
 * Copyright 2009-2014 Crazor <crazor@gmail.com>
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

#import "Area.h"
#import "Window.h"

@interface Area ()

@property NSWindow *overlay;

@end


@implementation Area

// TODO: Especially the ToplevelArea should really really acquire its rect and
// origin dynamically from NSScreen, since they are subject to changes, e.g.
// when the Dock is switched from/to autohide.
- (id)initWithRect:(NSRect)r
{
	if ((self = [super init]))
	{
		_children = [[NSMutableArray alloc] init];
		_rect = r;
	}
	return self;
}

- (int)width
{
	return self.rect.size.width;
}

- (int)height
{
	return self.rect.size.height;
}

- (void)drawOverlay
{
	NSRect contentRect = [NSWindow contentRectForFrameRect:_rect styleMask:NSBorderlessWindowMask];
	_overlay = [[NSWindow alloc] initWithContentRect:contentRect
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
	_overlay.backgroundColor = NSColor.lightGrayColor;
	_overlay.opaque = NO;
	_overlay.level = NSMainMenuWindowLevel + 1; //Alternative: NSFloatingWindowLevel
	_overlay.alphaValue = 0.4;
	_overlay.hasShadow = NO;
	_overlay.ignoresMouseEvents = YES;
	[_overlay makeKeyAndOrderFront:self];
}

- (void)addChild:(Window *)w
{
	[self.children addObject:w];
    w.area = self;
	[self resizeChildren];
}

- (void)removeChild:(Window *)w
{
    [self.children removeObject:w];
    [self resizeChildren];
}

- (void)resizeChildren
{
    if (self.children.count == 0)
        return;
    
    if (self.verticallySplit)
    {
        int heightPerWindow = self.height / self.children.count;
        
        int i = 0;
        for (Window *w in self.children)
        {
            NSRect newRect;
            newRect.size.width = self.width;
            newRect.size.height = heightPerWindow;
            
            NSPoint newOrigin = self.rect.origin;
            newOrigin.y += i++ * heightPerWindow;
            
            newRect.origin = newOrigin;
            
            w.rect = newRect;
        }
    }
    else
    {
        int widthPerWindow = self.width / self.children.count;
        
        int i = 0;
        for (Window *w in self.children)
        {
            NSRect newRect;
            newRect.size.width = widthPerWindow;
            newRect.size.height = self.height;
            
            NSPoint newOrigin = self.rect.origin;
            newOrigin.x += i++ * widthPerWindow;
            
            newRect.origin = newOrigin;
            
            w.rect = newRect;
        }
    }
}

@end
