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

#import "WindowController.h"
#import "UIElement.h"
#import "Application.h"
#import "Window.h"

@implementation WindowController

+ (WindowController *)sharedInstance
{
	static WindowController *sharedInstance;

    if (!sharedInstance)
    {
        sharedInstance = [[WindowController alloc] init];
    }

    return sharedInstance;
}

- (id)init
{
	if (self = [super init])
	{
		_applications = [NSMutableArray array];

        [self checkIsAXAPIEnabled];
        [self registerWithNotificationCenter];
        [self populateAppList];
	}

	return self;
}

- (void)checkIsAXAPIEnabled
{
    while(true)
    {
        if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)(@{(__bridge id)kAXTrustedCheckOptionPrompt: @YES})))
        {
            NSInteger ret = NSRunAlertPanel(@"This program requires access to the Accessibility API",
                                            @"Please make sure to allow access to control your computer.",
                                            @"Retry", @"Quit", @"");
            
            switch (ret)
            {
                case NSAlertDefaultReturn:
                    continue;
                case NSAlertAlternateReturn:
                    [NSApp terminate:self];
                    break;
                case NSAlertOtherReturn:
                    [NSApp terminate:self];
                    break;
            }
        }
    }
}

- (void)dealloc
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (NSArray *)windows
{
	NSMutableArray *array = [NSMutableArray array];
	for (Application *a in _applications)
	{
		[array addObjectsFromArray:[a windows]];
	}
	return array;
}

- (void)populateAppList
{
	// Populate appList with running apps
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	for (NSRunningApplication *runningApplication in [ws runningApplications])
	{
        [self addApp:runningApplication];
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
    
    // Other interesting notifications:
    // NSWorkspaceDidHideApplicationNotification
    // NSWorkspaceDidUnhideApplicationNotification
    // NSWorkspaceDidActivateApplicationNotification
    // NSWorkspaceDidDeactivateApplicationNotification
}

- (void)addApp:(NSRunningApplication *)application
{
    if ([application activationPolicy]
        == NSApplicationActivationPolicyRegular // Skip agents
        && [application processIdentifier]
        != [[NSProcessInfo processInfo] processIdentifier]) // Skip self
    {
        [[self applications] addObject:
         [[Application alloc] initWithRunningApplication:application]];
    }
}

- (void)removeApp:(NSRunningApplication *)application
{
	[[self applications] removeObject:application];
}

- (void)appLaunched:(NSNotification *)notification
{
    NSRunningApplication *application = [notification userInfo][@"NSWorkspaceApplicationKey"];
    [self addApp:application];
}

- (void)appTerminated:(NSNotification *)notification
{
    NSRunningApplication *application = [notification userInfo][@"NSWorkspaceApplicationKey"];
	[self removeApp:application];
}

- (Application *)applicationFromElement:(UIElement *)e
{
	for (Application *a in [self applications])
	{
		if ([[a element] isEqualTo:e])
			return a;
	}
	log(@"Application for element \"%@\" not found!", e);
	return nil;
}

- (Window *)focusedWindow
{
	UIElement *systemWide = [UIElement systemWideElement];
	
	Application *focusedApplication = [self applicationFromElement:
                                       [systemWide accessibilityAttributeValue:
                                        @"AXFocusedApplication"]];
	Window *focusedWindow = [focusedApplication windowFromElement:
                             [[systemWide accessibilityAttributeValue:
                               @"AXFocusedUIElement"]
                                accessibilityAttributeValue:@"AXWindow"]];
	
	return focusedWindow;
}

- (void)lockCurrentWindow
{
	Window *focusedWindow = [self focusedWindow];
	if ([focusedWindow locked])
	{
		log(@"Unlocking Window: %@", focusedWindow);
		[focusedWindow unlock];
	}
	else
	{
		log(@"Locking Window: %@", focusedWindow);
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
