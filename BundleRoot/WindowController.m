//
//  WindowController.m
//  BundleRoot
//
//  Created by Foolery on 6/12/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "WindowController.h"
#import "BRNotification.h"

@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.window setTitle:@"Bundle ROOT"];
}

#pragma mark - Action
- (IBAction)newOverlay:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    //    [panel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setAllowedFileTypes:@[@""]];
    [panel setAllowsOtherFileTypes:YES];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSString *path = [panel.URLs.firstObject path];
            //code
//            AppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
//            appDelegate.hostPath = path;
            NSString *filePath = path;
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BRNewOverlayNotification object:filePath];
//            [_bbOverlayFileName setStringValue:fileName];
//            
//            // parse filePath to Entitys
//            _bbOverlayPackageEntity = [BBMergeEntity recurseParseFilePath:filePath parent:nil originOrMerge:YES];
//            
//            _bbOverlayPackageArrayM = _bbOverlayPackageEntity.nodeChild;
//            
//            [_bbOverlayOutlineView reloadData];
        }
    }];
}


@end
