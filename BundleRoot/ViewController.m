//
//  ViewController.m
//  BundleRoot
//
//  Created by Foolery on 6/8/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "ViewController.h"
#import "FileSystemNode.h"
#import "FileSystemBrowserCell.h"

#import "BRNotification.h"

typedef NS_ENUM(NSUInteger, BRBundleModelType) {
    BREFI = 0,
    BROS = 1,
    BRBaseband = 2,
    BRGrapeRoot = 3,
    BRWifi,
    BRbblib,
    BRWipaMini,
};

@interface ViewController () <NSBrowserDelegate>

@property (weak) IBOutlet NSTextField *overlayNameTextField;

@property (weak) IBOutlet NSBrowser *mainFolderBrower;

@property (weak) IBOutlet NSButton *efiButton;
@property (weak) IBOutlet NSButton *osButton;
@property (weak) IBOutlet NSButton *basebandButton;
@property (weak) IBOutlet NSButton *graperootButton;
@property (weak) IBOutlet NSButton *wifiButton;
@property (weak) IBOutlet NSButton *btButton;
@property (weak) IBOutlet NSButton *bblibButton;
@property (weak) IBOutlet NSButton *wipaminiButton;

@property (weak) IBOutlet NSPopUpButton *efiPopupButton;
@property (weak) IBOutlet NSPopUpButton *osPopupButton;
@property (weak) IBOutlet NSPopUpButton *basebandPopupButton;
@property (weak) IBOutlet NSPopUpButton *graperootPopupButton;
@property (weak) IBOutlet NSPopUpButton *wifiPopupButton;
@property (weak) IBOutlet NSPopUpButton *btPopupButton;
@property (weak) IBOutlet NSPopUpButton *bblibPopupButton;
@property (weak) IBOutlet NSPopUpButton *wipaminiPopupButton;

@property (strong) FileSystemNode *rootNode;

@property (strong) NSMutableDictionary *bundleDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self.mainFolderBrower setCellClass:[FileSystemBrowserCell class]];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__reloadBrowerWithFilePath:) name:BRNewOverlayNotification object:nil];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
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

#pragma mark - Action

- (IBAction)bundleAction:(id)sender
{
    if (sender == _efiButton) {
        [_efiPopupButton setEnabled:[_efiButton state] ? YES : NO];
    } else if (sender == _osButton) {
        [_osPopupButton setEnabled:[_osButton state] ? YES : NO];
    } else if (sender == _basebandButton) {
        [_basebandPopupButton setEnabled:[_basebandButton state] ? YES : NO];
    } else if (sender == _graperootButton) {
        [_graperootPopupButton setEnabled:[_graperootButton state] ? YES : NO];
    } else if (sender == _wifiButton) {
        [_wifiPopupButton setEnabled:[_wifiButton state] ? YES : NO];
    } else if (sender == _btButton) {
        [_btPopupButton setEnabled:[_btButton state] ? YES : NO];
    } else if (sender == _bblibButton) {
        [_bblibPopupButton setEnabled:[_bblibButton state] ? YES : NO];
    } else if (sender == _wipaminiButton) {
        [_wipaminiPopupButton setEnabled:[_wipaminiButton state] ? YES : NO];
    }
}

- (IBAction)newBundle:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
//    [panel setAllowedFileTypes:@[@"zip"]];
    [panel setAllowsOtherFileTypes:YES];
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSString *path = [panel.URLs.firstObject path];

            NSString *filePath = path;
            
        }
    }];
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


@end
