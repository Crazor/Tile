/*
 * This file is part of the Tile project.
 *
 * Copyright 2009 Crazor <crazor@gmail.com>
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

@class Window;

@implementation Area

@synthesize children;
@synthesize rect;

- (id)initWithRect:(NSRect)r
{
	if (self = [super init])
	{
		children = [[NSArray alloc] init];
		rect = r;
		NSLog(@"Creating Area with origin: %@, size: %@", NSStringFromPoint(r.origin), NSStringFromSize(r.size));
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

- (void)addWindow:(Window *)w
{
}

- (void)split:(BOOL)vertically
{
}

@end
