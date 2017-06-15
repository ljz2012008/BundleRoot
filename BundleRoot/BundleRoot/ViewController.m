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

#import <XADMaster/XADSimpleUnarchiver.h>
#import <XADMaster/XADPlatform.h>

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

#pragma mark - XADSimpleUnarchiverDelegate

//-(NSString *)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver encodingNameForXADString:(id <XADString>)string; {
//    return [string encodingName];
//}
//
//-(BOOL)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver shouldExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path
//{
//    return YES;
//}
//-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver willExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path
//{
//
//}
//-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver didExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path error:(XADError)error
//{
//
//
//}

-(NSString *)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver replacementPathForEntryWithDictionary:(NSDictionary *)dict
                 originalPath:(NSString *)path suggestedPath:(NSString *)unique
{
    return nil;
}
-(NSString *)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver deferredReplacementPathForOriginalPath:(NSString *)path
                suggestedPath:(NSString *)unique
{
    return nil;
}

-(BOOL)extractionShouldStopForSimpleUnarchiver:(XADSimpleUnarchiver *)unarchiver;
{
    return NO;
}

-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver extractionProgressForEntryWithDictionary:(NSDictionary *)dict
           fileProgress:(off_t)fileprogress of:(off_t)filesize
          totalProgress:(off_t)totalprogress of:(off_t)totalsize
{
    NSUInteger progressInt = 100*totalprogress/totalsize;
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [_sheetViewController updateProgress:progressInt];
//        [_sheetViewController.percentTextField setStringValue:[NSString stringWithFormat:@"%lu%%", progressInt]];
//    });
    
    NSLog(@"Total Progress: %lu%%", progressInt);
}

-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver estimatedExtractionProgressForEntryWithDictionary:(NSDictionary *)dict
           fileProgress:(double)fileprogress totalProgress:(double)totalprogress
{
    //    NSLog(@"Progress: %f", fileprogress/totalprogress);
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
        [self __bundleUnarchive:path relatedPath:efiPath];
    }
    
}

- (NSString *)__bundleUnarchive:(NSString *)path relatedPath:(NSString *)relatedPath
{

    NSString *destinationPath;
    destinationPath = [path stringByDeletingPathExtension];
    
    if([path rangeOfString:@"Baseband"].location == NSNotFound && ![XADPlatform fileExistsAtPath:destinationPath])
    {
        XADError openerror;
        XADSimpleUnarchiver *unarchiver=[XADSimpleUnarchiver simpleUnarchiverForPath:path error:&openerror];
        
        [unarchiver setDestination:relatedPath];
        [unarchiver setRemovesEnclosingDirectoryForSoloItems:NO];
        [unarchiver setEnclosingDirectoryName:[unarchiver enclosingDirectoryName]];
        [unarchiver setAlwaysOverwritesFiles:NO];
        [unarchiver setAlwaysRenamesFiles:NO];
        [unarchiver setAlwaysSkipsFiles:NO];
        [unarchiver setExtractsSubArchives:YES];
        [unarchiver setPropagatesRelevantMetadata:YES];
        [unarchiver setCopiesArchiveModificationTimeToEnclosingDirectory:NO];
        [unarchiver setCopiesArchiveModificationTimeToSoloItems:NO];
        [unarchiver setMacResourceForkStyle:YES];
        //
        [unarchiver setDelegate:self];
//        [unarchiver setRemovesEnclosingDirectoryForSoloItems:YES];
        XADError parseerror=[unarchiver parse];
        XADError unarchiveerror = [unarchiver unarchive];
        
        if(parseerror) { }
        if(unarchiveerror) { }
    }
    
    if ([path rangeOfString:@"Baseband"].location != NSNotFound) {
        destinationPath = [path stringByDeletingLastPathComponent];
    }
    return path;
}

@end
