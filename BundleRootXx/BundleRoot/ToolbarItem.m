//
//  ToolbarItem.m
//  BundleRoot
//
//  Created by Foolery on 6/13/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "ToolbarItem.h"

@implementation ToolbarItem

- (NSSize)minSize
{
    if (floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_12) {
        /* Overriding this getter seems to be the only solution for runtime error logs like: NSToolbarItem (<APMRegularToolbarItem: 0x60e000039460>) had to adjust the size of <NSButton: 0x60f0001acce0> from {40, 25} to the expected size of {42, 27}. Make sure that this toolbar item view has a valid frame/min/max size. This is an app bug, please do not file a bug against AppKit or NSToolbar! Break on _NSToolbarAdjustedBorderedControlSizeBreakpoint
         */
        return NSMakeSize(42, 27);
    }
    else {
        return [super minSize];
    }
}

@end
