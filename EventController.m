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

#import "EventController.h"
#import "GTMAXUIElement.h"
#import "WindowController.h"
#import "Application.h"
#import "Window.h"

static OSStatus applicationEventHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData)
{
	EventHotKeyID hotKeyID;
	GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	
	EventController *self = (__bridge_transfer EventController *)userData;
	
	if (hotKeyID.signature == 'lead')
	{
		[self leaderEvent];
	}
	else if (hotKeyID.signature == 'keys')
	{
		[self keyEventWithID:hotKeyID.id];
	}
	
	return noErr;
}

@implementation EventController
{
	EventHotKeyRef				hotKeyRef;
	EventHotKeyRef				keyRef[0x80];
	BOOL						keyHandlersRegistered;
	SEL							eventSelectors[EVENT_ID_MAX];
	id							eventTargets[EVENT_ID_MAX];
}

- (void)awakeFromNib
{
	[self registerLeaderHandler];
	
	WindowController *wc = [WindowController sharedInstance];
	
	[self setSelector:@selector(lockCurrentWindow)		ofTarget:wc		forActionID:37]; // L
	[self setSelector:@selector(quit)					ofTarget:self	forActionID:12]; // Q
	[self setSelector:@selector(maximizeCurrentWindow)	ofTarget:wc		forActionID:46]; // M
	[self setSelector:@selector(centerCurrentWindow)	ofTarget:wc		forActionID: 8]; // C
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self 
														   selector: @selector(userDefaultsDidChange:)
															   name: NSUserDefaultsDidChangeNotification
															 object: NULL];
}

- (void)userDefaultsDidChange: (NSNotification *)notification
{
	NSLog(@"User Defaults did change. Name: %@", [notification name]);
}

- (void)registerLeaderHandler
{
	EventHotKeyID hotKeyID;
	EventTypeSpec typeSpec;
	
	hotKeyID.signature = 'lead';
	hotKeyID.id = 0xFF;
	
	typeSpec.eventClass	= kEventClassKeyboard;
	typeSpec.eventKind	= kEventHotKeyPressed;
	
	InstallApplicationEventHandler(&applicationEventHandler, 1, &typeSpec, (__bridge_retained void *)self, NULL);

	OSStatus status = RegisterEventHotKey(kVK_Space, controlKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
	if (status != noErr)
	{
		NSLog(@"Error %d registering leader hotkey handler!", status);
	}
}

- (void)registerKeyHandlers
{
	if (keyHandlersRegistered)
	{
		NSLog(@"Key handlers already registered.");
		return;
	}
	
	EventHotKeyID hotKeyID;
	EventTypeSpec typeSpec;
	
	typeSpec.eventClass	= kEventClassKeyboard;
	typeSpec.eventKind	= kEventHotKeyPressed;

	InstallApplicationEventHandler(&applicationEventHandler, 1, &typeSpec, (__bridge_retained void *)self, NULL);
	
	for (int i = 0; i < EVENT_ID_MAX; i++)
	{
		hotKeyID.signature = 'keys';
		hotKeyID.id = i;
		
		OSStatus status = RegisterEventHotKey(i, 0, hotKeyID, GetApplicationEventTarget(), 0, &(keyRef[i]));
		if (status != noErr)
		{
			NSLog(@"Error %d registering key handler %x!", status, i);
		}
	}
	
	keyHandlersRegistered = TRUE;
}

- (void)unregisterKeyHandlers
{
	if (!keyHandlersRegistered)
	{
		NSLog(@"Key handlers not registered.");
		return;
	}
	
	for (int i = 0; i < EVENT_ID_MAX; i++)
	{
		OSStatus status = UnregisterEventHotKey(keyRef[i]);
		if (status != noErr)
		{
			NSLog(@"Error %d unregistering key handler %x!", status, i);
		}
	}
	
	keyHandlersRegistered = false;
}

- (void)leaderEvent
{
	[self registerKeyHandlers];
}

- (void)keyEventWithID:(int)ID
{	
	id target		= eventTargets[ID];
	SEL selector	= eventSelectors[ID];
	
	if (!target)
	{
		NSLog(@"No target defined for event ID %d", ID);
	}
	else if (!selector)
	{
		NSLog(@"No selector defined for event ID %d", ID);
	}
	else if ([target respondsToSelector:selector])
	{
		NSLog(@"Performing selector %@ on target %@ (event ID: %d)", NSStringFromSelector(selector), NSStringFromClass([target class]), ID);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[target performSelector:selector];
#pragma clang diagnostic pop
	}
	else
	{
		NSLog(@"Target does not respond to selector for event ID %d", ID);
	}
	
	[self unregisterKeyHandlers];
}

- (void)setSelector:(SEL)selector ofTarget:(id)target forActionID:(int)ID
{
	eventSelectors[ID]	= selector;
	eventTargets[ID]	= target;
}

- (void)quit
{
	NSLog(@"Terminating...");
	[[NSApplication sharedApplication] terminate:self];
}

@end
