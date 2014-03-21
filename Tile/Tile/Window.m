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

#import "Window.h"
#import "UIElement.h"
#import "Application.h"
#import "Area.h"

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
 * AXModal,
 * AXFullScreen,
 * AXIdentifier
 */

// C Callback for AX Notifications
static void axObserverCallback(AXObserverRef observer, AXUIElementRef elementRef, CFStringRef notification, void *refcon)
{
	Window *self = (__bridge_transfer Window *)refcon;
	
	if ([[self element] isEqual:[[UIElement alloc] initWithElementRef:elementRef]])
	{
		if ([(__bridge NSString *)notification isEqualToString:@"AXWindowMoved"])
		{
			[self moved];
		}
		if ([(__bridge NSString *)notification isEqualToString:@"AXWindowResized"])
		{
			[self resized];
		}
		if ([(__bridge NSString *)notification isEqualToString:@"AXWindowMiniaturized"])
		{
			[self miniaturized];
		}
		if ([(__bridge NSString *)notification isEqualToString:@"AXWindowDeminiaturized"])
		{
			[self deminiaturized];
		}
        if ([(__bridge NSString *)notification isEqualToString:@"AXUIElementDestroyed"])
		{
			[self destroyed];
		}
	}
}

@implementation Window
{
	AXObserverRef   observer;
}

- (id)initWithElement:(UIElement *)e andApplication:(Application *)a
{
	if ((self = [super init]))
	{
		_element = e;
		_application = a;
		[self registerAXObserver];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterAXObserver];
}

- (NSString *)description
{
	return [[self element] stringValueForAttribute:(NSString *)kAXTitleAttribute];
}

- (NSArray *)attributes
{
	return [[self element] accessibilityAttributeNames];
}

- (bool)isMinimized
{
    NSNumber *value = [[self element] accessibilityAttributeValue:(NSString *)kAXMinimizedAttribute];
    return [value boolValue];
}

- (void)registerAXObserver
{
	if (AXObserverCreate([[self application] pid], axObserverCallback, &observer))
	{
		log(@"Error creating AXObserver for %@", self);
		return;
	}

	CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);

	if (AXObserverAddNotification(observer, self.application.element.elementRef, kAXWindowMovedNotification, (__bridge_retained void *)self))
	{
		log(@"Error adding kAXWindowMovedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, self.application.element.elementRef, kAXWindowResizedNotification, (__bridge_retained void *)self))
	{
		log(@"Error adding kAXWindowResizedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, self.application.element.elementRef, kAXWindowMiniaturizedNotification, (__bridge_retained void *)self))
	{
		log(@"Error adding kAXWindowMiniaturizedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, self.application.element.elementRef, kAXWindowDeminiaturizedNotification, (__bridge_retained void *)self))
	{
		log(@"Error adding kAXWindowDeminiaturizedNotification for %@", self);
		return;
	}
	if (AXObserverAddNotification(observer, self.application.element.elementRef, kAXUIElementDestroyedNotification, (__bridge_retained void *)self))
	{
		log(@"Error adding kAXUIElementDestroyedNotification for %@", self);
		return;
	}
}

- (void)unregisterAXObserver
{
	AXObserverRemoveNotification(observer, self.application.element.elementRef, kAXWindowMovedNotification);
	AXObserverRemoveNotification(observer, self.application.element.elementRef, kAXWindowResizedNotification);
	AXObserverRemoveNotification(observer, self.application.element.elementRef, kAXWindowMiniaturizedNotification);
	AXObserverRemoveNotification(observer, self.application.element.elementRef, kAXWindowDeminiaturizedNotification);
    AXObserverRemoveNotification(observer, self.application.element.elementRef, kAXUIElementDestroyedNotification);
    
    CFRunLoopRemoveSource([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
}


// Messages

- (void)moved
{
#if 0
	// TODO: Pull out some constants
	// TODO: Get notifications about mouse movements in order to allow drag-to-maximize even when only moving the mouse vertically
	
	NSPoint mouse = [NSEvent mouseLocation];
	NSRect screen = [[[AreaController sharedInstance] toplevelArea] rect];
	
	// The mouse coordinate system has its origin at the lower left corner of the screen
	mouse.y = screen.size.height - mouse.y + 22;
	log(@"%@: Origin: %@, Mouse: %@", [self description], NSStringFromPoint([self origin]), NSStringFromPoint(mouse));

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
		log(@"Ignoring spurious move event!");
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
#endif
}

- (void)resized
{
	if ([self locked])
	{
		[self restoreLockedSize];
	}
}

- (void)miniaturized
{
	log(@"Window \"%@\" miniaturized", self);
}

- (void)deminiaturized
{
	log(@"Window \"%@\" deminiaturized", self);
}

- (void)destroyed
{
    [_area removeChild:self];
    [self unregisterAXObserver];
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
	_locked = YES;
	_lockedRect = [self rect];
}

- (void)unlock
{
	_locked = NO;
}

- (void)restoreLockedSize
{
	if ([self locked])
	{
		[self setSize:[self lockedRect].size];
	}
	else
	{
		log(@"Trying to restore non-locked window's size!");
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
		log(@"Trying to restore non-locked window's position!");
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
		log(@"Trying to restore non-locked window's rect!");
	}	
}

- (void)toggleMaximized
{
	if (!_maximized)
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
#if 0
	restoredRect = [self rect];
	
	Area *toplevelArea = [[AreaController sharedInstance] toplevelArea];
	[self setRect:[toplevelArea rect]];
	
	maximized = YES;
#endif
}

- (void)restore
{
	NSRect rect = [self restoredRect];
	/*
	 if (rect.origin.y == 22)
	{
		rect.origin.y = 23;
	}
	 */
	[self setRect:rect];
	
	_maximized = NO;
}

- (void)restoreByDragging
{
#if 0
	NSRect rect = restoredRect;
	NSPoint mouse = [NSEvent mouseLocation];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.x = mouse.x - (rect.size.width / 2);
	rect.origin.y = screen.size.height - mouse.y - 11;
	
	[self setRect:rect];
	maximized = NO;
#endif
}

- (void)centerHorizontal
{
#if 0
	NSRect rect = [self rect];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.x = (screen.size.width / 2) - (rect.size.width / 2);
	[self setRect:rect];
#endif
}

- (void)centerVertical
{
#if 0
	NSRect rect = [self rect];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.y = (screen.size.height / 2) - (rect.size.height / 2);
	[self setRect:rect];
#endif
}

- (void)center
{
#if 0
	NSRect rect = [self rect];
	NSRect screen = [[[AreaController sharedInstance] screen] frame];
	rect.origin.x = (screen.size.width / 2) - (rect.size.width / 2);
	rect.origin.y = (screen.size.height / 2) - (rect.size.height / 2);
	[self setRect:rect];
#endif
}

@end
