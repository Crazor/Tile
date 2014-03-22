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

#import "UIElement.h"

@implementation UIElement

@synthesize elementRef = _elementRef;

+ (id)systemWideElement
{
    static UIElement *systemWideElement;

    if (!systemWideElement)
    {
        systemWideElement = [[UIElement alloc] initWithElementRef:AXUIElementCreateSystemWide()];
    }

    return systemWideElement;
}

- (id)initWithElementRef:(AXUIElementRef)elementRef
{
    if (self = [super init])
    {
        _elementRef = elementRef;
    }

    return self;
}

- (id)initWithProcessIdentifier:(pid_t)pid
{
    if (self = [super init])
    {
        _elementRef = AXUIElementCreateApplication(pid);
    }

    return self;
}

- (NSString *)stringValueForAttribute:(NSString *)attribute
{
    CFTypeRef cfValue;

    AXError e = AXUIElementCopyAttributeValue(_elementRef, (__bridge CFStringRef)attribute, &cfValue);

    if (e != kAXErrorSuccess)
    {
        log(@"AXError %d", e);
        return nil;
    }

    return (__bridge id)cfValue;
}


- (void)setStringValue:(NSString *)value forAttribute:(NSString *)attribute
{
    return;
}

- (CFTypeRef)accessibilityCopyAttributeCFValue:(NSString*)attribute
{
	CFTypeRef value = NULL;
	AXError error = AXUIElementCopyAttributeValue(_elementRef, (__bridge CFStringRef)attribute, &value);
	if (error == kAXErrorNoValue)
    {
		value = kCFNull;
	}
    else if (error)
    {
		value = nil;
	}
	return value;
}

- (id)accessibilityAttributeValue:(NSString*)attribute
{
	CFTypeRef value = [self accessibilityCopyAttributeCFValue:attribute];
	if (!value)
    {
        return nil;
    }

	id nsValue = nil;
	CFTypeID axTypeID = AXUIElementGetTypeID();

	if (CFGetTypeID(value) == axTypeID)
    {
		nsValue = [[UIElement alloc] initWithElementRef:(AXUIElementRef)value];
	}
    else if (CFGetTypeID(value) == CFArrayGetTypeID())
    {
		nsValue = [NSMutableArray array];
		NSEnumerator *enumerator = [(__bridge NSArray *)value objectEnumerator];
		id object;
		while ((object = [enumerator nextObject]))
        {
			if (CFGetTypeID((__bridge CFTypeRef)object) == axTypeID)
            {
				[nsValue addObject:[[UIElement alloc] initWithElementRef:(__bridge AXUIElementRef)object]];
			}
            else
            {
				[nsValue addObject:object];
			}
		}
	}
    else
    {
		nsValue = (__bridge id)value;
	}
	return nsValue;
}

@end
