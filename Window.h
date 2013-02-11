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

@class Area;
@class UIElement;
@class Application;

@interface Window : NSObject

@property(readonly) UIElement   *element;
@property(readonly) Application *application;
@property(readonly) BOOL        locked;
@property(readonly) NSRect      lockedRect;
@property(readonly) NSRect      restoredRect;
@property(readonly) BOOL        maximized;
@property           Area        *area;

- (id)initWithElement:(UIElement *)e andApplication:(Application *)a;
- (NSArray *)attributes;
- (void)moved;
- (void)resized;
- (void)miniaturized;
- (void)deminiaturized;
- (void)destroyed;
- (bool)isMinimized;
- (void)registerAXObserver;
- (void)unregisterAXObserver;
- (NSPoint)origin;
- (void)setOrigin:(NSPoint)origin;
- (NSSize)size;
- (void)setSize:(NSSize)size;
- (NSRect)rect;
- (void)setRect:(NSRect)rect;
- (void)lock;
- (void)unlock;
- (void)restoreLockedSize;
- (void)restoreLockedPosition;
- (void)restoreLockedRect;
- (void)toggleMaximized;
- (void)maximize;
- (void)restore;
- (void)restoreByDragging;
- (void)center;

@end
