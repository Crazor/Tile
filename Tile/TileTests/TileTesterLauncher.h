//
//  TileTesterLauncher.h
//  Tile
//
//  Created by Crazor on 21.03.14.
//  Copyright (c) 2014 Crazor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileTester/TileTester/TileTesterProtocol.h"

@interface TileTesterLauncher : NSObject

@property id<TileTesterProtocol> tester;
@property NSTask *task;

- (void)launchTester;
- (void)terminate;

@end
