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

@interface ViewController () <NSBrowserDelegate>

@property (weak) IBOutlet NSBrowser *mainFolderBrower;

@property (strong) FileSystemNode *rootNode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self.mainFolderBrower setCellClass:[FileSystemBrowserCell class]];
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - NSBrowserDelegate
- (id)rootItemForBrowser:(NSBrowser *)browser
{
    if (self.rootNode == nil) {
        _rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:NSOpenStepRootDirectory()]];
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

@end
