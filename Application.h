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

#import <Cocoa/Cocoa.h>

@class Window;
@class GTMAXUIElement;

@interface Application : NSObject {
	AXObserverRef	observer;
	NSString		*identifier;
	NSString		*name;
	NSNumber		*pid;
	GTMAXUIElement	*element;
	NSMutableArray	*windows;
}

@property(copy)		NSString		*identifier;
@property(copy)		NSString		*name;
@property(assign)	NSNumber		*pid;
@property(retain)	GTMAXUIElement	*element;
@property(retain)	NSMutableArray	*windows;

- (id)initWithDict:(NSDictionary *)appDict;
- (NSArray *)attributes;
- (void)registerAXObserver;
- (void)unregisterAXObserver;
- (void)windowCreated:(GTMAXUIElement *)window;
- (void)windowDestroyed:(GTMAXUIElement *)window;
- (Window *)windowFromElement:(GTMAXUIElement *)e;

@end
