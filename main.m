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

#import <Cocoa/Cocoa.h>
#import "AreaController.h"
#import "WindowController.h"
#import "EventController.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	
	AreaController *areaController = [[AreaController alloc] init];
	[areaController awakeFromNib];
	
	WindowController *windowController = [[WindowController alloc] init];
	[windowController awakeFromNib];
	
	EventController *eventController = [[EventController alloc] init];
	[eventController awakeFromNib];
	
	[NSApp run];
	
	[autoreleasePool release];
	return 0;
}
