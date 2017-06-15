//
//  WindowController.m
//  BundleRoot
//
//  Created by Foolery on 6/12/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "WindowController.h"
#import "ProgressWindowController.h"

#import "BRNotification.h"

@interface WindowController ()

@property (nonatomic, strong) ProgressWindowController *progressWindowController;

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.window setTitle:@"Bundle ROOT"];
    _progressWindowController = [[ProgressWindowController alloc] initWithWindowNibName:@"ProgressWindowController"];
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
            NSString *filePath = path;
            [[NSNotificationCenter defaultCenter] postNotificationName:BRNewOverlayNotification object:filePath];
        }
    }];
}

- (IBAction)generateOverlay:(id)sender
{
    [self.window beginSheet:_progressWindowController.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            
        } else if (returnCode == NSModalResponseCancel) {
            
        }
    }];
}

@end
