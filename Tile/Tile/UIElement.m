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
    return nil;
}

- (void)setStringValue:(NSString *)value forAttribute:(NSString *)attribute
{
    return;
}

@end
