//
//  ProgressWindowController.m
//  BundleRoot
//
//  Created by Foolery on 6/14/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "ProgressWindowController.h"

@interface ProgressWindowController ()

@property (copy) NSString *message;
@property (copy) NSString *action;
@property (strong) NSDate *startTime;
@property (assign) double progress;
@property (assign) NSTimeInterval remainingTime;
@property (assign) unsigned long long sizeWritten;
@property (assign) unsigned long long totalSize;
@property (assign) unsigned long long totalCount;
@property (assign) BOOL isIndeterminate;
@property (strong) NSOperationQueue *zipQueue;


@end

@implementation ProgressWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)cancel:(id)sender
{
    [self.window makeFirstResponder:nil];
    
    [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
