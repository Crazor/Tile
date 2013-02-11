/*
 * This file is part of the Tile project.
 *
 * Copyright 2009-2013 Crazor <crazor@gmail.com>
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
#import "UIElement.h"
#import "Area.h"
#import "TilingController.h"

static void axObserverCallback(AXObserverRef observer, AXUIElementRef elementRef, CFStringRef notification, void *refcon)
{
	UIElement *element = [[UIElement alloc] initWithElementRef:elementRef];
	Application *application = (__bridge_transfer Application *)refcon;
	NSString *notificationString = (__bridge NSString *)notification;
	
	if ([notificationString isEqualToString:(NSString *)kAXWindowCreatedNotification])
	{
		[application windowCreated:element];
	}
	if ([notificationString isEqualToString:(NSString *)kAXUIElementDestroyedNotification])
	{
		//[application windowDestroyed:element];
	}
}

@implementation Application
{
	AXObserverRef	observer;
}

- (id)initWithRunningApplication:(NSRunningApplication *)runningApplication
{
	if ((self = [super init]))
	{
		_windows    = [[NSMutableArray alloc] init];
		_pid        = runningApplication.processIdentifier;
		_identifier = runningApplication.bundleIdentifier;
		_name		= runningApplication.localizedName;
		_element	= [[UIElement alloc] initWithProcessIdentifier:_pid];

		for (UIElement *e in [self.element accessibilityAttributeValue:(NSString *)kAXWindowsAttribute])
		{
			Window *w = [[Window alloc] initWithElement:e andApplication:self];
            [TilingController.sharedInstance addWindow:w];
		}
		
		[self registerAXObserver];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterAXObserver];
}

- (void)registerAXObserver
{
	if (AXObserverCreate(_pid, axObserverCallback, &observer))
	{
		log(@"Error creating AXObserver for %@", self.identifier);
		return;
	}
    
	if ((AXObserverAddNotification(observer, self.element.elementRef, kAXWindowCreatedNotification, (__bridge_retained void *)self)))
	{
		log(@"Error adding AXWindowCreatedNotification for %@", self.identifier);
		return;
	}
	if (AXObserverAddNotification(observer, self.element.elementRef, kAXUIElementDestroyedNotification, (__bridge_retained void *)self))
	{
		log(@"Error adding AXUIElementDestroyedNotification for %@", self.identifier);
		return;
	}
	CFRunLoopAddSource(NSRunLoop.currentRunLoop.getCFRunLoop, AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
}

- (void)unregisterAXObserver
{
	AXObserverRemoveNotification(observer, self.element.elementRef, kAXWindowCreatedNotification);
	AXObserverRemoveNotification(observer, self.element.elementRef, kAXUIElementDestroyedNotification);	
}

- (NSString *)description
{
	return [self.element stringValueForAttribute:(NSString *)kAXTitleAttribute];
}

- (NSArray *)attributes
{
	return self.element.accessibilityAttributeNames;
}

- (void)windowCreated:(UIElement *)e
{
	Window *w = [[Window alloc] initWithElement:e andApplication:self];
	[self.windows addObject:w];
    [TilingController.sharedInstance.tilingStrategy addWindow:w];
}

- (void)windowDestroyed:(UIElement *)e
{
	for (Window *w in self.windows)
	{
		if ([w.element isEqualTo:e])
		{
			[self.windows removeObject:w];
			break;
		}
	}
}

- (Window *)windowFromElement:(UIElement *)e
{
	for (Window *w in self.windows)
	{
		if ([w.element isEqualTo:e])
		{
			return w;
		}
	}
	
	log(@"Window for Element \"%@\" not found!", e);
	return nil;
}

@end
