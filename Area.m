/*
 * This file is part of the Tile project.
 *
 * Copyright 2009, 2010 Crazor <crazor@gmail.com>
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

//@class Window;

@implementation Area

@synthesize children;
@synthesize rect;

static NSWindow *overlay;


// Especially the ToplevelArea should really really acquire it's rect and origin dynamically from NSScreen, since
// they are subject to changes, e.g. when the Dock is switched from/to autohide.
- (id)initWithRect:(NSRect)r
{
	if ((self = [super init]))
	{
		children = [[NSMutableArray alloc] init];
		rect = r;
		NSLog(@"Creating Area with origin: %@, size: %@", NSStringFromPoint(r.origin), NSStringFromSize(r.size));
		[self drawOverlay];
	}
	return self;
}

- (void)dealloc
{
	[[self children] release];
	[super dealloc];
}

- (int)width
{
	return [self rect].size.width;
}

- (int)height
{
	return [self rect].size.height;
}

- (void)drawOverlay
{
	NSRect contentRect = [NSWindow contentRectForFrameRect:rect styleMask:NSBorderlessWindowMask];
	overlay = [[NSWindow alloc] initWithContentRect:contentRect
												   styleMask:NSBorderlessWindowMask
													 backing:NSBackingStoreBuffered
													   defer:NO];
	[overlay setBackgroundColor:[NSColor lightGrayColor]];
	[overlay setOpaque:NO];
	[overlay setLevel:NSMainMenuWindowLevel + 1]; //Alternative: NSFloatingWindowLevel
	[overlay setAlphaValue:0.4];
	[overlay setHasShadow:NO];
	[overlay setIgnoresMouseEvents:YES];
	[overlay makeKeyAndOrderFront:overlay];
}

- (void)addWindow:(Window *)w
{
	[children addObject:w];
	[self resizeWindows];
}

- (void)resizeWindows
{
	int widthPerWindow = [self width] / [children count];
	int i = 0;
	for (Window *w in children)
	{
		NSSize size;
		size.width = widthPerWindow;
		size.height = [self height];

		NSPoint origin = rect.origin;
		origin.x += i++ * widthPerWindow;

		NSLog(@"Resizing window %@ to origin %@ size %@", w, NSStringFromPoint(origin), NSStringFromSize(size));
		[w setSize:size];
		[w setOrigin:origin];
	}
}

@end
