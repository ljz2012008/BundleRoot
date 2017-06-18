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

#import "BRNotification.h"

#import "ZipKit/ZKFileArchive.h"
#import "ZipKit/ZKLog.h"

#import "BRUnarchiverController.h"

#define BREFI @"BREFI"
#define BROS @"BROS"
#define BRBaseband @"BRBaseband"
#define BRGrapeRoot @"BRGrapeRoot"
#define BRMesa @"BRMesa"
#define BRWifi @"BRWifi"
#define BRPWifi @"BRPWifi"
#define BRBT @"BRBT"
#define BRbblib @"BRbblib"
#define BRWipaMini @"BRWipaMini"

@interface ViewController () <NSBrowserDelegate>

@property (weak) IBOutlet NSTextField *overlayNameTextField;
@property (weak) IBOutlet NSBrowser *mainFolderBrower;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;


@property (weak) IBOutlet NSButton *efiButton;
@property (weak) IBOutlet NSButton *osButton;
@property (weak) IBOutlet NSButton *basebandButton;
@property (weak) IBOutlet NSButton *graperootButton;
@property (weak) IBOutlet NSButton *mesaButton;
@property (weak) IBOutlet NSButton *wifiButton;
@property (weak) IBOutlet NSButton *pwifiButton;
@property (weak) IBOutlet NSButton *btButton;
@property (weak) IBOutlet NSButton *bblibButton;
@property (weak) IBOutlet NSButton *wipaminiButton;

@property (weak) IBOutlet NSPopUpButton *efiPopupButton;
@property (weak) IBOutlet NSPopUpButton *osPopupButton;
@property (weak) IBOutlet NSPopUpButton *basebandPopupButton;
@property (weak) IBOutlet NSPopUpButton *graperootPopupButton;
@property (weak) IBOutlet NSPopUpButton *mesaPopupButton;
@property (weak) IBOutlet NSPopUpButton *wifiPopupButton;
@property (weak) IBOutlet NSPopUpButton *pwifiPopupButton;
@property (weak) IBOutlet NSPopUpButton *btPopupButton;
@property (weak) IBOutlet NSPopUpButton *bblibPopupButton;
@property (weak) IBOutlet NSPopUpButton *wipaminiPopupButton;

@property (strong) FileSystemNode *rootNode;

@property (strong) NSOpenPanel *panel;

@property (strong) NSMutableDictionary *bundleDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__reloadBrowerWithFilePath:) name:BRNewOverlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__checkBundle) name:BRCheckBundleNotification object:nil];
    
//    [ZKFileArchive process:@"/Users/foolery/Desktop/int" usingResourceFork:YES withInvoker:nil andDelegate:self];
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
    } else if (sender == _mesaButton) {
        [_mesaPopupButton setEnabled:[_mesaButton state] ? YES : NO];
    } else if (sender == _wifiButton) {
        [_wifiPopupButton setEnabled:[_wifiButton state] ? YES : NO];
    } else if (sender == _pwifiButton) {
        [_pwifiPopupButton setEnabled:[_pwifiButton state] ? YES : NO];
    } else if (sender == _btButton) {
        [_btPopupButton setEnabled:[_btButton state] ? YES : NO];
    } else if (sender == _bblibButton) {
        [_bblibPopupButton setEnabled:[_bblibButton state] ? YES : NO];
    } else if (sender == _wipaminiButton) {
        [_wipaminiPopupButton setEnabled:[_wipaminiButton state] ? YES : NO];
    }
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

- (IBAction)newBundle:(id)sender
{
    [_panel setAllowsMultipleSelection:NO];
    [_panel setCanChooseDirectories:YES];
    [_panel setCanChooseFiles:YES];
    //    [panel setAllowedFileTypes:@[@"zip"]];
    [_panel setAllowsOtherFileTypes:YES];
    
    [_panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSString *path = [_panel.URLs.firstObject path];
            NSString *filePath = path;
            
            NSArray *elements = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
            elements = [elements sortedArrayUsingFunction:finderSortWithLocale
                                                  context:(__bridge void *)([NSLocale currentLocale])];
            
            NSPopUpButton *tempPop;
            if ([_efiPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BREFI];
                tempPop = _efiPopupButton;
            } else if ([_osPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BROS];
                tempPop = _osPopupButton;
            } else if ([_basebandPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRBaseband];
                tempPop = _basebandPopupButton;
            } else if ([_graperootPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRGrapeRoot];
                tempPop = _graperootPopupButton;
            } else if ([_mesaPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRMesa];
                tempPop = _mesaPopupButton;
            }  else if ([_wifiPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRWifi];
                tempPop = _wifiPopupButton;
            }  else if ([_pwifiPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRPWifi];
                tempPop = _pwifiPopupButton;
            } else if ([_btPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRBT];
                tempPop = _btPopupButton;
            } else if ([_bblibPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRbblib];
                tempPop = _bblibPopupButton;
            } else if ([_wipaminiPopupButton indexOfItem:sender] == 0) {
                [_bundleDic setObject:filePath forKey:BRWipaMini];
                tempPop = _wipaminiPopupButton;
            }
            
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
                
                [tempPop addItemWithTitle:element];
            }
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

- (void)__checkBundle
{
    if ([_efiButton state] ==1) {
        NSString *efiPath = [_bundleDic objectForKey:BREFI];
        NSString *efiName = [_efiPopupButton titleOfSelectedItem];
        NSString *path = [efiPath stringByAppendingFormat:@"/%@", efiName];
        
        BRUnarchiverController *unarchiver = [[BRUnarchiverController alloc] initWithFilename:path];
        
        [unarchiver runWithFinishAction:nil target:nil];
//        [NSThread detachNewThreadSelector:@selector(__bundleUnarchive:relatedPath:) toTarget:self withObject:efiPath];
//        [self __bundleUnarchive:path relatedPath:efiPath];
    }
    
}

//- (NSString *)__bundleUnarchive:(NSString *)path relatedPath:(NSString *)relatedPath
//{
//
//    
//}

@end
