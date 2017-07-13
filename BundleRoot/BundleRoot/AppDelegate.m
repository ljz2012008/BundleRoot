//
//  AppDelegate.m
//  BundleRoot
//
//  Created by Foolery on 6/15/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "AppDelegate.h"
#import "FileSystemNode.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    FileSystemNode *node = [[FileSystemNode alloc] initWithURL:[NSURL URLWithString:@"/Users/foolery/Desktop/kk/z.Overlay/ErieTianshan14E61060k_DCSD-354_HWTE_SCM_P1_V07-1/Users/gdlocal/RestorePackage/CurrentBundle"]];
    
    
    
    NSArray *children = node.children;
    BOOL bl = node.isDirectory;
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
