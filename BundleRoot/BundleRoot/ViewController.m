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

#import "BRUnarchiverController.h"



@interface ViewController () <NSBrowserDelegate, BRUnarchiverToMainControllerDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTextField *overlayNameTextField;
@property (weak) IBOutlet NSBrowser *mainFolderBrower;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (strong) NSMutableString *logTxT;

@property (weak) IBOutlet NSTableView *bTableView;

@property (weak) id keepObj;

@property (strong) FileSystemNode *rootNode;

@property (strong) NSOpenPanel *panel;

@property (strong) NSMutableDictionary *bundleDic;
@property (strong) NSMutableArray *bundleArr;

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
        if ([keyStr isEqualToString:BREFI]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // 1. Copy to relative J71s_J72s_ROOT
            // 2. find Tianshan format
            // 3. check CurrentBundle CurrentRoot ErieTianshan14E61060k_J71s_J72s J71s_J72s_ROOT
            // 4. delete /Users/gdlocal/RestorePackage/ErieTianshan14E61060k_J71s_J72s/Restore/Diags/XXX | add 2 bin
            // 5. new CurrentDiags | add 2bin
        }
        if ([keyStr isEqualToString:BROS]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // overwrite
            // check when duplication of name
        }
        if ([keyStr isEqualToString:BRBaseband]) {
            tempEntity.isArchived = NO;
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/CurrentBaseband";
            // copy to relative path
            // link symbol file : CurrentBaseband.zip
        }
        if ([keyStr isEqualToString:BRGrapeRoot]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // overwrite
            // list????
        }
        if ([keyStr isEqualToString:BRMesa]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // overwrite
            // list????
        }
        if ([keyStr isEqualToString:BRPWifi]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // overwrite
            // list????
        }
        if ([keyStr isEqualToString:BRWifi_BT]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // overwrite
            // list????
        }
        if ([keyStr isEqualToString:BRbblib]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // delete /Users/gdlocal/RestorePackage/J71s_J72s_ROOT/AppleInternal/Diags/Logs/Smokey/Shared/BBLib/Latest
            // copy bundle | overwrite
        }
        if ([keyStr isEqualToString:BRWipaMini]) {
            tempEntity.bundleRelatedPath = @"/Users/gdlocal/RestorePackage/J71s_J72s_ROOT";
            // check the name of WiPASmini
            // copy to /Users/gdlocal/RestorePackage/J71s_J72s_ROOT/AppleInternal/Applications/SwitchBoard
        }
        [_bundleArr addObject:tempEntity];
    }
    
    _logTxT = [NSMutableString stringWithFormat:@"Unarchive:\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n", BREFI, BROS, BRBaseband, BRGrapeRoot, BRMesa, BRPWifi, BRbblib, BRWipaMini];
    [_logTextView setString:_logTxT];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__reloadBrowerWithFilePath:)
                                                 name:BRNewOverlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__checkBundle)
                                                 name:BRCheckBundleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popUpBtnAction:)
                                                 name:NSPopUpButtonWillPopUpNotification object:nil];
    
//    [ZKFileArchive process:@"/Users/foolery/Desktop/int" usingResourceFork:YES withInvoker:nil andDelegate:self];
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
    static NSStringCompareOptions comparisonOptions =
    NSCaseInsensitiveSearch | NSNumericSearch |
    NSWidthInsensitiveSearch | NSForcedOrderingSearch;
    
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
}

- (void)__checkBundle
{
    _logTxT = [NSMutableString stringWithFormat:@"Unarchive:\n"];
    for (int i = 0; i < [_bundleArr count]; i++) {
        BRPopUpCellView *cellView = [_bTableView viewAtColumn:1 row:i makeIfNecessary:NO];
        BundleEntity *cellEntity = _bundleArr[i];
        
        if (cellEntity.isSelected && [cellView.popUpBtn indexOfSelectedItem] > 1 && cellEntity.isArchived == YES) {
            [_logTxT appendString:[NSString stringWithFormat:@"%@: 0%%\n", cellEntity.bundleType]];
            cellEntity.bundleName = [cellView.popUpBtn titleOfSelectedItem];
            cellEntity.bundleFullPath = [cellEntity.bundleParentPath stringByAppendingFormat:@"/%@", cellEntity.bundleName];
            [self exeUnarchiveWithBundleEntity:cellEntity];
        }
        if (cellEntity.isArchived == NO) {
            cellEntity.bundleName = [cellView.popUpBtn titleOfSelectedItem];
            cellEntity.bundleFullPath = [cellEntity.bundleParentPath stringByAppendingFormat:@"/%@", cellEntity.bundleName];
            cellEntity.bundleExtractPath = cellEntity.bundleFullPath;
        }
    }
}

- (void)exeUnarchiveWithBundleEntity:(BundleEntity *)entity
{
    BRUnarchiverController *unarchiver = [[BRUnarchiverController alloc] initWithEntity:entity];
    unarchiver.mainControllerDelegate = self;
    [unarchiver runWithFinishAction:@selector(unarchiverControllerFinish:) target:self];
}

//- (NSString *)__bundleUnarchive:(NSString *)path relatedPath:(NSString *)relatedPath
//{
//
//    
//}

@end
