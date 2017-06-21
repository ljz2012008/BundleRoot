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
    
    _bundleDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  @"1", BREFI,
                  @"1", BROS,
                  @"1", BRBaseband,
                  @"1", BRGrapeRoot,
                  @"1", BRMesa,
                  @"1", BRWifi,
                  @"1", BRPWifi,
                  @"1", BRBT,
                  @"1", BRbblib,
                  @"1", BRWipaMini, nil];
    _bundleArr = [NSMutableArray new];
    NSArray *tempArr = @[BREFI, BROS, BRBaseband, BRGrapeRoot, BRMesa, BRWifi, BRPWifi, BRBT, BRbblib, BRWipaMini];
    for (NSString *keyStr in tempArr) {
        BundleEntity *tempEntity = [[BundleEntity alloc] initWithTypeName:keyStr];
        [_bundleArr addObject:tempEntity];
    }
    
    _logTxT = [NSMutableString stringWithFormat:@"Unarchive:\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n%@: 100%%\n", varString(BREFI), varString(BROS),varString(BRBaseband),varString(BRGrapeRoot),varString(BRMesa),varString(BRWifi),varString(BRPWifi),varString(BRBT), varString(BRbblib), varString(BRWipaMini)];
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
            cellEntity.bundleRelatedPath = path;
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
    NSLog(@"%@ : Finish", archiveController.archiveName);
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
    for (int i = 0; i < [_bundleArr count]; i++) {
        BRPopUpCellView *cellView = [_bTableView viewAtColumn:1 row:i makeIfNecessary:NO];
        BundleEntity *cellEntity = _bundleArr[i];
        
        if (cellEntity.isSelected && [cellView.popUpBtn indexOfSelectedItem] > 1) {
            cellEntity.bundleName = [cellView.popUpBtn titleOfSelectedItem];
            cellEntity.bundleFullPath = [cellEntity.bundleRelatedPath stringByAppendingFormat:@"/%@", cellEntity.bundleName];
            [self exeUnarchiveWithBundleEntity:cellEntity];
        }
    }
}

- (void)exeUnarchiveWithBundleEntity:(BundleEntity *)entity
{
    BRUnarchiverController *unarchiver = [[BRUnarchiverController alloc] initWithFilename:entity.bundleFullPath];
    unarchiver.archiveType = entity.bundleType;
    unarchiver.destinationPath = entity.bundleRelatedPath;
    [unarchiver runWithFinishAction:@selector(unarchiverControllerFinish:) target:self];
}

//- (NSString *)__bundleUnarchive:(NSString *)path relatedPath:(NSString *)relatedPath
//{
//
//    
//}

@end
