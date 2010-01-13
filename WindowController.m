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

#import "WindowController.h"
#import "GTMAXUIElement.h"
#import "Application.h"
#import "Window.h"

@implementation WindowController

@synthesize applications;

static WindowController *sharedInstance;

+ (void)initialize
{
	static BOOL initialized = NO;
	if(!initialized)
	{
		sharedInstance = [[WindowController alloc] init];
		initialized = YES;
	}
}

+ (WindowController *)sharedInstance
{
	return sharedInstance;
}

- (id)init
{
	if (sharedInstance)
	{
		[self dealloc];
		return sharedInstance;
	}
	
	if (self = [super init])
	{
		applications = [[NSMutableArray array] retain];
	}
	
	return self;
}

- (void)awakeFromNib
{
	if (!AXAPIEnabled())
	{
		NSLog(@"Please enable \"Access for assistive devices\" in System Preferences");
		[[NSApplication sharedApplication] terminate:self];

		// The following does not work without a MainMenu.nib:
		/*
		int ret = NSRunAlertPanel (@"This program requires that the Accessibility API be enabled. Would you like me to launch System Preferences so that you can turn on \"Enable access for assistive devices\".", @"", @"OK", @"Quit", @"Cancel");
		
		switch (ret)
		{
			case NSAlertDefaultReturn:
				[[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
				break;
			case NSAlertAlternateReturn:
				[NSApp terminate:self];
				return;
			case NSAlertOtherReturn: // just continue
			default:
				break;
		}
		 */
	}
		
	[self populateAppList];
	[self registerWithNotificationCenter];
}

- (void)dealloc
{
	[[self applications] release];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super dealloc];
}

- (void)populateAppList
{
	// Populate appList with running apps
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSDictionary *appDict;
	for (appDict in [ws launchedApplications])
	{
		[[self applications] addObject:[[Application alloc] initWithDict:appDict]];
	}
}

// Register self to receive application launch/terminate notifications
- (void)registerWithNotificationCenter
{
	NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
	[nc addObserver:self
		   selector:@selector(appLaunched:)
			   name:NSWorkspaceDidLaunchApplicationNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(appTerminated:)
			   name:NSWorkspaceDidTerminateApplicationNotification
			 object:nil];
}

- (void)removeApp:(NSDictionary *)appDict
{
	NSLog(@"removeApp: to be implemented...");
}

- (void)appLaunched:(NSNotification *)notification
{
	[[self applications] addObject:[[Application alloc] initWithDict:[notification userInfo]]];
}

- (void)appTerminated:(NSNotification *)notification
{
	NSLog(@"appTerminated: to be implemented...");
	//[self removeApp:[notification userInfo]];
}

- (Application *)applicationFromElement:(GTMAXUIElement *)e
{
	for (Application *a in [self applications])
	{
		if ([[a element] isEqualTo:e])
			return a;
	}
	NSLog(@"Application for Element \"%@\" not found!", e);
	return nil;
}

- (Window *)focusedWindow
{
	GTMAXUIElement *systemWide = [GTMAXUIElement systemWideElement];
	
	Application *focusedApplication = [self applicationFromElement:[systemWide accessibilityAttributeValue:@"AXFocusedApplication"]];
	Window *focusedWindow = [focusedApplication windowFromElement:[[systemWide accessibilityAttributeValue:@"AXFocusedUIElement"] accessibilityAttributeValue:@"AXWindow"]];
	
	return focusedWindow;
}

- (void)lockCurrentWindow
{
	Window *focusedWindow = [self focusedWindow];
	if ([focusedWindow locked])
	{
		NSLog(@"Unlocking Window: %@", focusedWindow);
		[focusedWindow unlock];
	}
	else
	{
		NSLog(@"Locking Window: %@", focusedWindow);
		[focusedWindow lock];
	}
}

- (void)maximizeCurrentWindow
{
	[[self focusedWindow] toggleMaximized];
}

- (void)centerCurrentWindow
{
	[[self focusedWindow] center];
}

@end
