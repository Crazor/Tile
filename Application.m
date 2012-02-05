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

#import "Application.h"
#import "Window.h"
#import "GTMAXUIElement.h"
#import "AreaController.h"
#import "Area.h"

static void axObserverCallback(AXObserverRef observer, AXUIElementRef elementRef, CFStringRef notification, void *refcon)
{
	GTMAXUIElement *element = [GTMAXUIElement elementWithElement:elementRef];
	Application *application = (Application *)refcon;
	NSString *notificationString = (NSString *)notification;
	
	if ([notificationString isEqualToString:(NSString *)kAXWindowCreatedNotification])
	{
		[application windowCreated:element];
	}
	if ([notificationString isEqualToString:(NSString *)kAXUIElementDestroyedNotification])
	{
		[application windowDestroyed:element];
	}
}

@implementation Application

@synthesize identifier;
@synthesize name;
@synthesize pid;
@synthesize element;
@synthesize windows;

- (id)initWithRunningApplication:(NSRunningApplication *)runningApplication
{
	if ((self = [super init]))
	{
		[self setWindows:[NSMutableArray array]];
		[self setPid:		[runningApplication processIdentifier]];
		[self setIdentifier:[runningApplication bundleIdentifier]];
		[self setName:		[runningApplication	localizedName]];
		[self setElement:	[GTMAXUIElement elementWithProcessIdentifier:pid]];
		
		for (GTMAXUIElement *e in [[self element] accessibilityAttributeValue:(NSString *)kAXWindowsAttribute])
		{
			Window *w = [[Window alloc] initWithElement:e andApplication:self];
			
			[[self windows] addObject:w];
		}
		
		[self registerAXObserver];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterAXObserver];
	[[self identifier]	release];
	[[self name]		release];
	[[self element]		release];
	[[self windows]		release];
	
	[super dealloc];
}

- (void)registerAXObserver
{
	if (AXObserverCreate(pid, axObserverCallback, &observer))
	{
		NSLog(@"Error creating AXObserver for %@", [self identifier]);
		return;
	}
	if (AXObserverAddNotification(observer, [[self element] element], kAXWindowCreatedNotification, self))
	{
		NSLog(@"Error adding AXWindowCreatedNotification for %@", [self identifier]);
		return;
	}
	if (AXObserverAddNotification(observer, [[self element] element], kAXUIElementDestroyedNotification, self))
	{
		NSLog(@"Error adding AXUIElementDestroyedNotification for %@", [self identifier]);
		return;
	}
	CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
}

- (void)unregisterAXObserver
{
	AXObserverRemoveNotification(observer, [[self element] element], kAXWindowCreatedNotification);
	AXObserverRemoveNotification(observer, [[self element] element], kAXUIElementDestroyedNotification);	
}

- (NSString *)description
{
	return [[self element] stringValueForAttribute:(NSString *)kAXTitleAttribute];
}

- (NSArray *)attributes
{
	return [[self element] accessibilityAttributeNames];
}

- (void)windowCreated:(GTMAXUIElement *)e
{
	//NSLog(@"Window created: %@", e);
	Window *w = [[Window alloc] initWithElement:e andApplication:self];
	[[self windows] addObject:w];
	[[[AreaController sharedInstance] toplevelArea] addWindow:w];
}

- (void)windowDestroyed:(GTMAXUIElement *)e
{
	for (Window *w in [self windows])
	{
		if ([[w element] isEqualTo:e])
		{
			[[self windows] removeObject:w];
            
			break;
		}
	}
}

- (Window *)windowFromElement:(GTMAXUIElement *)e
{
	for (Window *w in [self windows])
	{
		if ([[w element] isEqualTo:e])
		{
			return w;
		}
	}
	
	NSLog(@"Window for Element \"%@\" not found!", e);
	return nil;
}

@end
