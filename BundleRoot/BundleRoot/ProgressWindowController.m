//
//  ProgressWindowController.m
//  BundleRoot
//
//  Created by Foolery on 6/15/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "ProgressWindowController.h"

#import "ZipKit/ZKFileArchive.h"
#import "ZipKit/ZKLog.h"
#import "ZipFileOperation.h"

const double maxProgress = 100.0;

@interface ProgressWindowController () <ZipKitDelegate>

@property IBOutlet NSProgressIndicator *progressIndicator;
@property IBOutlet NSTextField *remainingTextField;

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
    [ZKLog sharedInstance].minimumLevel = [[NSUserDefaults standardUserDefaults] integerForKey:ZKLogLevelKey];
    self.message = NSLocalizedString(@"Ready", @"status message");
    self.progress = 0.0;
    self.remainingTime = 0.0;
    self.zipQueue = [NSOperationQueue new];
    [self.zipQueue setMaxConcurrentOperationCount:1];
}

- (IBAction)cancel:(id)sender
{
    [self.zipQueue cancelAllOperations];
    [self.window makeFirstResponder:nil];
    [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseCancel];
}

- (IBAction)gggg:(id)sender
{
    ZipFileOperation *zipFileOperation = [ZipFileOperation new];
    zipFileOperation.item = @"/Users/foolery/Desktop/kk/z.Overlay/TL_ErieTianshan14E61060k_DCSD-354_HWTE_SCM_P1_V07";
    zipFileOperation.delegate = self;
    [self.zipQueue addOperation:zipFileOperation];

//    [ZKFileArchive process:@"/Users/foolery/Desktop/kk/z.Overlay/TL_ErieTianshan14E61060k_DCSD-354_HWTE_SCM_P1_V07" usingResourceFork:YES withInvoker:nil andDelegate:self];
}

#pragma mark - ZipKitDelegate
- (void) onZKArchiveDidBeginZip:(ZKArchive *) archive {
    self.isIndeterminate = YES;
    self.progress = 0.0;
    self.remainingTime = NSTimeIntervalSince1970;
    self.action = NSLocalizedString(@"Archiving", @"action for status message");
    self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ items (%@)...", @"status message"),
                    self.action, [[archive archivePath] lastPathComponent]];
    self.startTime = [NSDate date];
    [self showWindow:self];
    ZKLogDebug(self.message);
}

- (void) onZKArchiveDidBeginUnzip:(ZKArchive *) archive {
    self.isIndeterminate = YES;
    self.progress = 0.0;
    self.remainingTime = NSTimeIntervalSince1970;
    self.message = @"";
    self.action = NSLocalizedString(@"Extracting", @"action for status message");
    self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ items (%@)...", @"status message"),
                    self.action, [[archive archivePath] lastPathComponent]];
    self.startTime = [NSDate date];
    [self showWindow:self];
    ZKLogDebug(self.message);
}

- (void) onZKArchiveDidEndZip:(ZKArchive *) archive {
    self.progress = maxProgress;
    self.remainingTime = 0.0;
    self.isIndeterminate = NO;
    self.message = [NSString stringWithFormat:NSLocalizedString(@"Archive created (%@)", @"status message"),
                    [[archive archivePath] lastPathComponent]];
    [_remainingTextField setStringValue:@"Finish"];
    ZKLogDebug(self.message);
}

- (void) onZKArchiveDidEndUnzip:(ZKArchive *) archive {
    self.progress = maxProgress;
    self.remainingTime = 0.0;
    self.isIndeterminate = NO;
    self.message = [NSString stringWithFormat:NSLocalizedString(@"Archive extracted (%@)", @"status message"),
                    [[archive archivePath] lastPathComponent]];
    ZKLogDebug(self.message);
}

- (void) onZKArchiveDidCancel:(ZKArchive *) archive {
    self.progress = 0.0;
    self.remainingTime = 0.0;
    self.isIndeterminate = NO;
    self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ cancelled", @"status message"), self.action];
    ZKLogDebug(self.message);
}

- (void) onZKArchiveDidFail:(ZKArchive *) archive {
    self.progress = 0.0;
    self.remainingTime = 0.0;
    self.isIndeterminate = NO;
    self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ failed", @"status message"), self.action];
    ZKLogError(self.message);
}

- (void) onZKArchive:(ZKArchive *) archive didUpdateTotalSize:(unsigned long long)size {
    self.totalSize = size;
}

- (void) onZKArchive:(ZKArchive *) archive didUpdateTotalCount:(unsigned long long)count {
    self.totalCount = count;
    if (self.totalCount < 1)
        self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ items (%@)...", @"status message"),
                        self.action, [[archive archivePath] lastPathComponent]];
    else if (self.totalCount == 1)
        self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ 1 item (%@)...", @"status message"),
                        self.action, [[archive archivePath] lastPathComponent]];
    else
        self.message = [NSString stringWithFormat:NSLocalizedString(@"%@ %qu items (%@)...", @"status message"),
                        self.action, self.totalCount, [[archive archivePath] lastPathComponent]];
}

- (void) onZKArchive:(ZKArchive *) archive didUpdateBytesWritten:(unsigned long long)byteCount {
    self.sizeWritten += byteCount;
    self.isIndeterminate = (self.totalSize == 0);
    if (self.totalSize > 0) {
        self.progress = maxProgress * ((double)self.sizeWritten) / ((double)self.totalSize);
        [_progressIndicator setDoubleValue:self.progress];
    }
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startTime];
    NSTimeInterval rt = (100.0 * elapsed / self.progress) - elapsed;
    if (rt < self.remainingTime)
        self.remainingTime = rt;
}

- (void) onZKArchive:(ZKArchive *) archive willZipPath:(NSString *)path {
    ZKLogDebug(@"Adding %@...", [path lastPathComponent]);
}

- (void) onZKArchive:(ZKArchive *) archive willUnzipPath:(NSString *)path {
    ZKLogDebug(@"Extracting %@...", [path lastPathComponent]);
}

- (BOOL) zkDelegateWantsSizes {
    return YES;
}


@end
