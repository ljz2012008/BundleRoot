//
//  ViewController.m
//  BundleRoot
//
//  Created by Foolery on 6/15/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "ViewController.h"
#import "FileSystemNode.h"
#import "FileSystemBrowserCell.h"
#import "BundleEntity.h"

#import "BRCheckboxCellView.h"
#import "BRPopUpCellView.h"

#import "BRNotification.h"

#import "ZipKit/ZKFileArchive.h"
#import "ZipKit/ZKLog.h"

#import <XADMaster/XADSimpleUnarchiver.h>
#import <XADMaster/XADPlatform.h>

#import "BRUnarchiverController.h"

@interface ViewController () <NSBrowserDelegate, BRUnarchiverToMainControllerDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSImageView *image1;
@property (weak) IBOutlet NSImageView *image2;

@property (strong) NSOpenPanel *panel;
@property (weak) IBOutlet NSTextField *overlayNameTextField;
@property (weak) IBOutlet NSBrowser *mainFolderBrower;
@property (weak) IBOutlet NSTableView *bTableView;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (strong) NSMutableString *logTxT;

@property (weak) id keepObj;

@property (strong) FileSystemNode *rootNode;
@property (strong) NSMutableArray *bundleArr;
@property (strong) NSString *versionPath;
@property (strong) NSString *rootPath;
@property (strong) NSString *restorePackagePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    _logTxT = [NSMutableString new];
    _panel = [NSOpenPanel openPanel];
    [self.mainFolderBrower setCellClass:[FileSystemBrowserCell class]];

    _bundleArr = [NSMutableArray new];
    NSArray *tempArr = @[BREFI, BROS, BRBaseband, BRGrapeRoot, BRMesa, BRPWifi, BRWifi_BT, BRbblib, BRWipaMini];
    for (NSString *keyStr in tempArr) {
        BundleEntity *tempEntity = [[BundleEntity alloc] initWithType:keyStr];
        
        if ([keyStr isEqualToString:BRBaseband]) {
            tempEntity.isArchived = NO;
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/CurrentBaseband";
            // copy to relative path
            // link symbol file : CurrentBaseband.zip
        }
        
        [_bundleArr addObject:tempEntity];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setDouble:123 forKey:@"asdads"];
    
    _logTxT = [NSMutableString stringWithFormat:@"Unarchive:\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n", BREFI, BROS, BRBaseband, BRGrapeRoot, BRMesa, BRPWifi, BRbblib, BRWipaMini];
    [_logTextView setString:_logTxT];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__reloadBrowerWithFilePath:)
                                                 name:BRNewOverlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__unarchiveBundle:)
                                                 name:BRUnarchiveBundleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__archiveCheck:)
                                                 name:BRArchiveCheckNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popUpBtnAction:)
                                                 name:NSPopUpButtonWillPopUpNotification object:nil];
    
//    [ZKFileArchive process:@"/Users/foolery/Desktop/int" usingResourceFork:YES withInvoker:nil andDelegate:self];
    
//    NSString *path1 = @"/Users/foolery/Desktop/kk/z.Overlay/ErieTianshan14E61060k_DCSD-354_HWTE_SCM_P1_V07-1/Users/gdlocal/RestorePackage";
//    NSString *path2 = @"/Users/foolery/Desktop/kk/z.Overlay/ErieTianshan14E61060k_DCSD-354_HWTE_SCM_P1_V07-1/Users/gdlocal/RestorePackage/CurrentBundle";
//    NSString *path3 = @"/Users/foolery/Desktop/kk/z.Overlay/ErieTianshan14E61060k_DCSD-354_HWTE_SCM_P1_V07-1/Users/gdlocal/RestorePackage/ErieTianshan14E61060k_J71s_J72s";
//    
//    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path1 error:nil];
//    NSArray *arr1 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path2 error:nil];
//    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path2 error:nil];
//    NSDictionary *attr1 = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path3 error:nil];
//
//    NSImage *imageValue = [[NSWorkspace sharedWorkspace] iconForFile:path1];
//    NSImage *imageValue1 = [[NSWorkspace sharedWorkspace] iconForFile:path2];
//    
//    NSImage* icon;
//    if ([[NSURL fileURLWithPath:path3] getResourceValue:&icon forKey:NSURLLocalizedNameKey error:NULL]) {}
//    
//    NSString *fileType1 = [[NSWorkspace sharedWorkspace] typeOfFile:path1 error:nil];
//    NSString *fileType2 = [[NSWorkspace sharedWorkspace] typeOfFile:path2 error:nil];
//    NSString *fileType3 = [[NSWorkspace sharedWorkspace] typeOfFile:path3 error:nil];
//    
//    [_image1 setImage:imageValue];
////    [_image2 setImage:imageValue1];
//    _image2.image = [[NSWorkspace sharedWorkspace] iconForFile:path2];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

#pragma mark - BRUnarchiverToMainControllerDelegate
- (void)updateProgress:(double)dProgress target:(id)targetObj
{
    for (BundleEntity *entity in _bundleArr) {
        if (entity == targetObj) {
            NSString *progress = [NSString stringWithFormat:@"%d%%", (int)dProgress];
            NSString *pattern = [NSString stringWithFormat:@"(?<=%@: ).*?%%", entity.bundleType];
            NSRegularExpression *reExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult *firstMatch = [reExpress firstMatchInString:_logTxT options:0 range:NSMakeRange(0, [_logTxT length])];
            if (firstMatch) {
                NSRange resultRange = [firstMatch rangeAtIndex:0];
                //从urlString中截取数据
                [_logTxT replaceCharactersInRange:resultRange withString:progress];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_logTextView setString:_logTxT];
                });
            }
        }
    }
}

#pragma mark - NSBrowserDelegate
- (id)rootItemForBrowser:(NSBrowser *)browser
{
    if (self.rootNode == nil) {
        _rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    }
    return self.rootNode;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
    FileSystemNode *node = (FileSystemNode *)item;
    return node.children.count;
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return [node.children objectAtIndex:index];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    FileSystemBrowserCell *aCell = (FileSystemBrowserCell *)cell;
    NSIndexPath *indexPath = [sender indexPathForColumn:column];
    indexPath = [indexPath indexPathByAddingIndex:row];
    FileSystemNode *node = [sender itemAtIndexPath:indexPath];
    aCell.image = node.icon;
    aCell.labelColor = node.labelColor;
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return !node.isDirectory || node.isPackage; // take into account packaged apps and documents
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return node.displayName;
}

- (CGFloat)browser:(NSBrowser *)browser shouldSizeColumn:(NSInteger)columnIndex forUserResize:(BOOL)forUserResize toWidth:(CGFloat)suggestedWidth  {
    if (!forUserResize) {
        id item = [browser parentForItemsInColumn:columnIndex];
        if ([self browser:browser isLeafItem:item]) {
            suggestedWidth = 200;
        }
    }
    return suggestedWidth;
}

- (CGFloat)browser:(NSBrowser *)browser sizeToFitWidthOfColumn:(NSInteger)columnIndex
{
    return 400;
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _bundleArr ? [_bundleArr count] : 0;
}


#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    NSTableCellView *cellView = nil;
    if ([identifier isEqualToString:@"Column1"]) {
        BRCheckboxCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        BundleEntity *entity = _bundleArr[row];
        [cellView.checkBoxBtn setTitle:entity.bundleType];
        return cellView;
    } else if ([identifier isEqualToString:@"Column2"]) {
        BRPopUpCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        return cellView;
    }
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 22;
}

#pragma mark - Action

- (IBAction)enableBundleAction:(id)sender
{
    NSInteger rowIndex = [_bTableView rowForView:sender];
    BundleEntity *cellEntity = _bundleArr[rowIndex];
    BRPopUpCellView *cellView = [_bTableView viewAtColumn:1 row:rowIndex makeIfNecessary:NO];
    [cellView.popUpBtn setEnabled:[sender state] ? YES : NO];
    [cellEntity setIsSelected:[sender state] ? YES : NO];
}

// Mark - String Programming Guide called "Sorting strings like Finder"
// http://developer.apple.com/documentation/Cocoa/Conceptual/Strings/Articles/SearchingStrings.html#//apple_ref/doc/uid/20000149-SW1
NSInteger finderSortWithLocale(id string1, id string2, void *locale)
{
    static NSStringCompareOptions comparisonOptions = (NSCaseInsensitiveSearch |
                                                       NSNumericSearch |
                                                       NSWidthInsensitiveSearch |
                                                       NSForcedOrderingSearch);
    
    NSRange string1Range = NSMakeRange(0, [string1 length]);
    
    return [string1 compare:string2
                    options:comparisonOptions
                      range:string1Range
                     locale:(__bridge NSLocale *)locale];
}

- (void)popUpBtnAction:(NSNotification *)sender
{
    _keepObj = [sender object];
}

- (IBAction)choseFile:(NSMenuItem *)sender
{
    [_panel setAllowsMultipleSelection:NO];
    [_panel setCanChooseDirectories:YES];
    [_panel setCanChooseFiles:YES];
//    [panel setAllowedFileTypes:@[@"zip"]];
    [_panel setAllowsOtherFileTypes:YES];
    
    [_panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSString *path = [_panel.URLs.firstObject path];
            NSArray *elements = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            elements = [elements sortedArrayUsingFunction:finderSortWithLocale
                                                  context:(__bridge void *)([NSLocale currentLocale])];
            
            NSInteger rowIndex = [_bTableView rowForView:_keepObj];
            if (rowIndex < 0) return;
            BundleEntity *cellEntity = _bundleArr[rowIndex];
            cellEntity.bundleParentPath = path;
            [cellEntity.bundleSets removeAllObjects];
            
            BRPopUpCellView *cellView = [_bTableView viewAtColumn:1 row:rowIndex makeIfNecessary:NO];
            
            NSPopUpButton *tempPop = cellView.popUpBtn;
            
            NSUInteger totalMenuCont = [tempPop numberOfItems];
            for (int i = 2; totalMenuCont > i; i ++) {
                [tempPop removeItemAtIndex:2];
            }
            
            for (NSString *element in elements) {
                if ([element containsString:@"DS_Store"]) {
                    continue;
                }
                BOOL isDir = NO;
                
                [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingFormat:@"/%@", element] isDirectory:&isDir];
                if (isDir) {
                    continue;
                }
                
                [cellEntity.bundleSets addObject:element];
                [tempPop addItemWithTitle:element];
            }
        }
    }];
}

- (void)unarchiverControllerFinish:(BRUnarchiverController *)archiveController
{
    NSLog(@"%@ : Finish", archiveController.bEntity.bundleName);
}

#pragma mark - NSNotification
- (void)__reloadBrowerWithFilePath:(NSNotification *)objc
{
    NSString *path = [objc object];
    
    NSString *fileName = [path lastPathComponent];
    fileName = [fileName stringByDeletingPathExtension];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDate *date = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileModificationDate];
    
    NSString *dateStr = [formatter stringFromDate:date];
    fileName = [NSString stringWithFormat:@"%@ (%@)",fileName, dateStr];
    
    [_overlayNameTextField setStringValue:fileName];
    _rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:path]];
    [_mainFolderBrower loadColumnZero];
    _restorePackagePath = [path stringByAppendingString:@"/Users/gdlocal/RestorePackage"];
    NSArray *contentsPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_restorePackagePath error:nil];
    NSLog(@"contentsOfDirectory: %@", contentsPath);
    for (NSString *element in contentsPath) {
        if ([element containsString:@"DS_Store"]) {
            continue;
        }
        if ([self canMatchPattern:@"([a-zA-Z0-9]+_)++(?!ROOT)" inString:element]) {
            _versionPath = [_restorePackagePath stringByAppendingFormat:@"/%@", element];
        }
        if ([self canMatchPattern:@"([a-zA-Z0-9]+_)++(?=ROOT)" inString:element]) {
            _rootPath = [_restorePackagePath stringByAppendingFormat:@"/%@", element];
        }
        NSLog(@"    %@", element);
    }
}

- (BOOL)canMatchPattern:(NSString *)pattern inString:(NSString *)logStr
{
    NSRegularExpression *reExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *firstMatch = [reExpress firstMatchInString:logStr options:0 range:NSMakeRange(0, [logStr length])];
    if (firstMatch) {
        return true;
    }
    return false;
}

- (void)__unarchiveBundle:(NSNotification*)notification
{
    _logTxT = [NSMutableString stringWithFormat:@"Unarchive:\n"];
    for (int i = 0; i < [_bundleArr count]; i++) {
        BRPopUpCellView *cellView = [_bTableView viewAtColumn:1 row:i makeIfNecessary:NO];
        BundleEntity *cellEntity = _bundleArr[i];
        
        if (cellEntity.isSelected && [cellView.popUpBtn indexOfSelectedItem] > 1) {
            cellEntity.isValid = YES;
            if (cellEntity.isArchived == NO) {
                cellEntity.bundleName = [cellView.popUpBtn titleOfSelectedItem];
                cellEntity.bundleFullPath = [cellEntity.bundleParentPath stringByAppendingFormat:@"/%@", cellEntity.bundleName];
                cellEntity.bundleExtractPath = cellEntity.bundleFullPath;
            } else {
                [_logTxT appendString:[NSString stringWithFormat:@"%@: 0%%\n", cellEntity.bundleType]];
                cellEntity.bundleName = [cellView.popUpBtn titleOfSelectedItem];
                cellEntity.bundleFullPath = [cellEntity.bundleParentPath stringByAppendingFormat:@"/%@", cellEntity.bundleName];
                [self exeUnarchiveWithBundleEntity:cellEntity];
            }
        } else {
            cellEntity.isValid = NO;
        }
        
    }
//    [[notification object] setEnabled:YES];
}

- (void)exeUnarchiveWithBundleEntity:(BundleEntity *)entity
{
    BRUnarchiverController *unarchiver = [[BRUnarchiverController alloc] initWithEntity:entity];
    unarchiver.mainControllerDelegate = self;
    [unarchiver runWithFinishAction:@selector(unarchiverControllerFinish:) target:self];
}

- (void)__archiveCheck:(NSNotification*)notification
{
    NSString *overlayPath = [_rootNode.URL path];
    NSString *binPath = [_rootPath stringByAppendingFormat:@"/AppleInternal/Diags/bin"];
    NSString *diagsPath = [_versionPath stringByAppendingString:@"/Restore/Diags"];
    NSString *currentDiagsPath = [_restorePackagePath stringByAppendingString:@"/CurrentDiags"];
    NSString *currentBasebandPath = [_restorePackagePath stringByAppendingString:@"/CurrentBaseband"];
    
    for (BundleEntity *entity in _bundleArr) {
        if (entity.isValid) {
            
            if ([entity.bundleType isEqualToString:BREFI]) {
                // 1. Copy to relative J71s_J72s_ROOT
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:_rootPath error:nil];
//                [self overwritefileWithTargetPath:_rootPath sourePath:entity.bundleExtractPath];
                // 2. find Tianshan format
                // 3. check CurrentBundle CurrentRoot ErieTianshan14E61060k_J71s_J72s J71s_J72s_ROOT
                // 4. delete /Users/gdlocal/RestorePackage/ErieTianshan14E61060k_J71s_J72s/Restore/Diags/XXX | add 2 bin
                [XADPlatform removeItemAtPath:diagsPath];
                [self copyDirectoryFromPath:binPath toPath:diagsPath];
                // 5. new CurrentDiags | add 2bin
                [XADPlatform removeItemAtPath:currentDiagsPath];
                [self copyDirectoryFromPath:binPath toPath:currentDiagsPath];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BROS]) {
                // overwrite
                // check when duplication of name
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:_rootPath error:nil];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BRBaseband]) {
                // copy to relative path
                [XADPlatform removeItemAtPath:currentBasebandPath];
                NSString *targetPath = [currentBasebandPath stringByAppendingPathComponent:[entity.bundleExtractPath lastPathComponent]];
                [[NSFileManager defaultManager] createDirectoryAtPath:currentBasebandPath withIntermediateDirectories:YES attributes:nil error:nil];
                [[NSFileManager defaultManager] copyItemAtPath:entity.bundleExtractPath toPath:targetPath error:nil];
                // link symbol file : CurrentBaseband.zip
                NSString *sBaseband = [entity.bundleExtractPath lastPathComponent];
                [[NSFileManager defaultManager] changeCurrentDirectoryPath:currentBasebandPath];
                [[NSFileManager defaultManager] createSymbolicLinkAtPath:@"CurrentBaseband.zip" withDestinationPath:sBaseband error:nil];
            }
            if ([entity.bundleType isEqualToString:BRGrapeRoot]) {
                // overwrite
                // list????
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:_rootPath error:nil];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BRMesa]) {
                // overwrite
                // list????
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:_rootPath error:nil];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BRPWifi]) {
                // overwrite
                // list????
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:_rootPath error:nil];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BRWifi_BT]) {
                // overwrite
                // list????
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:[_rootPath stringByAppendingString:@"/AppleInternal"] error:nil];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BRbblib]) {
                // delete /Users/gdlocal/RestorePackage/J71s_J72s_ROOT/AppleInternal/Diags/Logs/Smokey/Shared/BBLib/Latest
                [XADPlatform removeItemAtPath:[_rootPath stringByAppendingString:@"/AppleInternal/Diags/Logs/Smokey/Shared/BBLib/Latest"]];
                // copy bundle | overwrite
                [self mergeContentsOfPath:entity.bundleExtractPath intoPath:_rootPath error:nil];
                [XADPlatform removeItemAtPath:entity.bundleExtractPath];
            }
            if ([entity.bundleType isEqualToString:BRWipaMini]) {
                // check the name of WiPASmini
                // copy to /Users/gdlocal/RestorePackage/J71s_J72s_ROOT/AppleInternal/Applications/SwitchBoard
                NSString *switchPath = [_rootPath stringByAppendingString:@"/AppleInternal/Applications/SwitchBoard"];
                if (![XADPlatform fileExistsAtPath:switchPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:switchPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                [XADPlatform removeItemAtPath:[switchPath stringByAppendingString:@"/WiPASmini.app"]];
                [XADPlatform moveItemAtPath:entity.bundleExtractPath toPath:[switchPath stringByAppendingString:@"/WiPASmini.app"]];
            }
        }
    }
    
    [_logTxT appendString:@"/n/n Check OK"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_logTextView setString:_logTxT];
        [_mainFolderBrower loadColumnZero];
    });

    [[notification object] setEnabled:YES];
}

- (void)copyDirectoryFromPath:(NSString *)sPath toPath:(NSString *)tPath
{
    NSString *sourcePath = sPath;
    NSString *destPath = tPath;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSArray *sourceFiles = [fm contentsOfDirectoryAtPath:sourcePath error:NULL];
    NSError *copyError = nil;
    
    BOOL isDirectory;
    
    for (NSString *currentFile in sourceFiles)
    {
        if (![fm copyItemAtPath:[sourcePath stringByAppendingPathComponent:currentFile] toPath:[destPath stringByAppendingPathComponent:currentFile] error:&copyError])
        {
            NSLog(@".....%@", currentFile);
        }
    }
}

- (BOOL)overwritefileWithTargetPath:(NSString *)tPath sourePath:(NSString *)sPath
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSURL *sURL = [NSURL fileURLWithPath:sPath];
    NSURL *tURL = [NSURL fileURLWithPath:tPath];
    NSError *error;
    BOOL isPass = [defaultManager replaceItemAtURL:tURL
                                     withItemAtURL:sURL
                                    backupItemName:nil
                                           options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                  resultingItemURL:nil error:nil];
    if (error) {
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
    }
    return isPass;
}

- (void)mergeContentsOfPath:(NSString *)srcDir intoPath:(NSString *)dstDir error:(NSError**)err {
    
    NSLog(@"- mergeContentsOfPath: %@\n intoPath: %@", srcDir, dstDir);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *srcDirEnum = [fm enumeratorAtPath:srcDir];
    NSString *subPath;
    while ((subPath = [srcDirEnum nextObject])) {
        
        NSLog(@" subPath: %@", subPath);
        NSString *srcFullPath =  [srcDir stringByAppendingPathComponent:subPath];
        NSString *potentialDstPath = [dstDir stringByAppendingPathComponent:subPath];
        
        // Need to also check if file exists because if it doesn't, value of `isDirectory` is undefined.
        BOOL isDirectory = ([[NSFileManager defaultManager] fileExistsAtPath:srcFullPath isDirectory:&isDirectory] && isDirectory);
        
        // Create directory, or delete existing file and move file to destination
        if (isDirectory) {
            NSLog(@"   create directory");
            [fm createDirectoryAtPath:potentialDstPath withIntermediateDirectories:YES attributes:nil error:err];
            if (err && *err) {
                NSLog(@"ERROR: %@", *err);
                return;
            }
        }
        else {
            if ([fm fileExistsAtPath:potentialDstPath]) {
                NSLog(@"   removeItemAtPath");
                [fm removeItemAtPath:potentialDstPath error:err];
                if (err && *err) {
                    NSLog(@"ERROR: %@", *err);
                    return;
                }
            }
            
            NSLog(@"   moveItemAtPath");
            [fm moveItemAtPath:srcFullPath toPath:potentialDstPath error:err];
            if (err && *err) {
                NSLog(@"ERROR: %@", *err);
                return;
            }
        }
    }
}

@end
