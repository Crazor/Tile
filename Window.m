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

#import "Window.h"
#import "GTMAXUIElement.h"
#import "Application.h"
#import "Area.h"
#import "AreaController.h"

/*
 * Available AX Attributes:
 * AXRole,
 * AXRoleDescription,
 * AXSubrole,
 * AXTitle,
 * AXFocused,
 * AXParent,
 * AXChildren,
 * AXPosition,
 * AXSize,
 * AXMain,
 * AXMinimized,
 * AXCloseButton,
 * AXZoomButton,
 * AXMinimizeButton,
 * AXToolbarButton,
 * AXProxy,
 * AXTitleUIElement,
 * AXGrowArea,
 * AXDefaultButton,
 * AXCancelButton,
 * AXDocument,
 * AXModal
 */ 

// C Callback for AX Notifications
static void axObserverCallback(AXObserverRef observer, AXUIElementRef elementRef, CFStringRef notification, void *refcon)
{
	Window *self = (Window *)refcon;
	
	if ([[self element] isEqual:[GTMAXUIElement elementWithElement:elementRef]])
	{
		if ([(NSString *)notification isEqualToString:@"AXWindowMoved"])
		{
			[self moved];
		}
		if ([(NSString *)notification isEqualToString:@"AXWindowResized"])
		{
			[self resized];
		}
		if ([(NSString *)notification isEqualToString:@"AXWindowMiniaturized"])
		{
			[self miniaturized];
		}
		if ([(NSString *)notification isEqualToString:@"AXWindowDeminiaturized"])
		{
			[self deminiaturized];
		}
	}
}

@implementation Window

@synthesize	element;
@synthesize	application;
@synthesize locked;
@synthesize lockedRect;
@synthesize maximized;
@synthesize restoredRect;

- (id)initWithElement:(GTMAXUIElement *)e andApplication:(Application *)a
{
	if (self = [super init])
	{
		element = [e retain];
		application = [a retain];
		[self registerAXObserver];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterAXObserver];
	[[self application] release];
	[[self element] release];
	[super dealloc];
}

- (NSString *)description
{
	return [[self element] stringValueForAttribute:(NSString *)kAXTitleAttribute];
}

- (NSArray *)attributes
{
	return [[self element] accessibilityAttributeNames];
}

- (void)registerAXObserver
{
	if (AXObserverCreate((pid_t)[[[self application] pid] longValue], axObserverCallback, &observer))
	{
		NSLog(@"Error creating AXObserver for %@", self);
		return;
	}

	CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);

	if (AXObserverAddNotification(observer, [[[self application] element] element], kAXWindowMovedNotification, self))
	{
		NSLog(@"Error adding kAXWindowMovedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, [[[self application] element] element], kAXWindowResizedNotification, self))
	{
		NSLog(@"Error adding kAXWindowResizedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, [[[self application] element] element], kAXWindowMiniaturizedNotification, self))
	{
		NSLog(@"Error adding kAXWindowMiniaturizedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, [[[self application] element] element], kAXWindowDeminiaturizedNotification, self))
	{
		NSLog(@"Error adding kAXWindowDeminiaturizedNotification for %@", self);
		return;
	}
}

- (void)unregisterAXObserver
{
	//NSLog(@"Unregistering Window Observer");
	AXObserverRemoveNotification(observer, [[[self application] element] element], kAXWindowMovedNotification);
	AXObserverRemoveNotification(observer, [[[self application] element] element], kAXWindowResizedNotification);
	AXObserverRemoveNotification(observer, [[[self application] element] element], kAXWindowMiniaturizedNotification);
	AXObserverRemoveNotification(observer, [[[self application] element] element], kAXWindowDeminiaturizedNotification);
}


// Messages

- (void)moved
{
	// TODO: Pull out some constants
	// TODO: Get notifications about mouse movements in order to allow drag-to-maximize even when only moving the mouse vertically
	
	NSPoint mouse = [NSEvent mouseLocation];
	NSRect screen = [[[AreaController sharedInstance] toplevelArea] rect];
	
	// The mouse coordinate system has its origin at the lower left corner of the screen
	mouse.y = screen.size.height - mouse.y + 22;
	//NSLog(@"%@: Origin: %@, Mouse: %@", [self description], NSStringFromPoint([self origin]), NSStringFromPoint(mouse));

	if ([self locked])
	{
		[self restoreLockedPosition];
		return;
	}

	return;

	// Drag to maximize
	if ([self origin].y <= screen.origin.y && mouse.y <= screen.origin.y && !maximized)
	{
		[self maximize];
		return;
	}
	
	if ([self origin].y != 22 && maximized)
	{
		[self restoreByDragging];
		return;
	}	
	
	/*
	if (NSEqualPoints([self origin], screen.origin))
	{
		//NSLog(@"Ignoring spurious move event!");
		return;
	}
	*/
	
	// Snap to left edge
	if (abs([self origin].x) <= (screen.origin.x + 15))
	{
		NSPoint origin = [self origin];
		origin.x = screen.origin.x;
		[self setOrigin:origin];
	}
	
	// right edge
	if (([self origin].x + [self rect].size.width) >= (screen.origin.x + screen.size.width - 15))
	// The following is too generic. Multi-monitor systems can have all kinds of layouts.
	//if (([self origin].x + [self rect].size.width) >= (screen.origin.x + screen.size.width - 15) && ([self origin].x + [self rect].size.width) <= (screen.origin.x + screen.size.width + 15))
	{
		NSPoint origin = [self origin];
		origin.x = screen.size.width - [self size].width + screen.origin.x;
		[self setOrigin:origin];
	}
	
	// top edge
	if ([self origin].y <= (screen.origin.y + 15))
	{
		NSPoint origin = [self origin];
		origin.y = screen.origin.y;
		[self setOrigin:origin];
	}
		
	// bottom edge
	if (([self origin].y + [self size].height) >= (screen.origin.y + screen.size.height - 15))
	{
		NSPoint origin = [self origin];
		origin.y = screen.size.height - [self size].height + screen.origin.y;
		[self setOrigin:origin];
	}
}

- (void)resized
{
	if ([self locked])
	{
		//NSLog(@"Window is locked! Restoring locked size.");
		[self restoreLockedSize];
	}
}

- (void)miniaturized
{
	NSLog(@"Window \"%@\" miniaturized", self);
}

- (void)deminiaturized
{
	NSLog(@"Window \"%@\" deminiaturized", self);
}


// Attributes

- (NSPoint)origin
{
	return NSPointFromString([[self element] stringValueForAttribute:(NSString *)kAXPositionAttribute]);
}

- (void)setOrigin:(NSPoint)origin
{
	[[self element] setStringValue:NSStringFromPoint(origin) forAttribute:(NSString *)kAXPositionAttribute];
}

- (NSSize)size
{
	return NSSizeFromString([[self element] stringValueForAttribute:(NSString *)kAXSizeAttribute]);
}

- (void)setSize:(NSSize)size
{
	[[self element] setStringValue:NSStringFromSize(size) forAttribute:(NSString *)kAXSizeAttribute];
}

- (NSRect)rect
{
	NSRect rect;
	rect.origin	= [self origin];
	rect.size	= [self size];
	return rect;
}

- (void)setRect:(NSRect)rect
{
	[self setOrigin:rect.origin];
	[self setSize:rect.size];
}

- (void)lock
{
	locked = YES;
	lockedRect = [self rect];
}

- (void)unlock
{
	locked = NO;
}

- (void)restoreLockedSize
{
	if ([self locked])
	{
		[self setSize:[self lockedRect].size];
	}
	else
	{
		NSLog(@"Trying to restore non-locked window's size!");
	}
}

- (void)restoreLockedPosition
{
	if ([self locked])
	{
		[self setOrigin:[self lockedRect].origin];
	}
	else
	{
		NSLog(@"Trying to restore non-locked window's position!");
	}
}

- (void)restoreLockedRect
{
	if ([self locked])
	{
		[self setRect:[self lockedRect]];
	}
	else
	{
		NSLog(@"Trying to restore non-locked window's rect!");
	}	
}

- (void)toggleMaximized
{
	if (!maximized)
	{
		[self maximize];
	}
	else
	{
		[self restore];
	}
}

- (void)maximize
{
	restoredRect = [self rect];
	
	Area *toplevelArea = [[AreaController sharedInstance] toplevelArea];
	[self setRect:[toplevelArea rect]];
	
	maximized = YES;
}

- (void)restore
{
	NSRect rect = [self restoredRect];
	if (rect.origin.y == 22)
	{
		rect.origin.y = 23;
	}
	[self setRect:rect];
	
	maximized = NO;
}

- (void)restoreByDragging
{
	NSRect rect = restoredRect;
	NSPoint mouse = [NSEvent mouseLocation];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.x = mouse.x - (rect.size.width / 2);
	rect.origin.y = screen.size.height - mouse.y - 11;
	
	[self setRect:rect];
	maximized = NO;
}

- (void)centerHorizontal
{
	NSRect rect = [self rect];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.x = (screen.size.width / 2) - (rect.size.width / 2);
	[self setRect:rect];
}

- (void)centerVertical
{
	NSRect rect = [self rect];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.y = (screen.size.height / 2) - (rect.size.height / 2);
	[self setRect:rect];
}

- (void)center
{
	NSRect rect = [self rect];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.x = (screen.size.width / 2) - (rect.size.width / 2);
	rect.origin.y = (screen.size.height / 2) - (rect.size.height / 2);
	[self setRect:rect];
}

@end
