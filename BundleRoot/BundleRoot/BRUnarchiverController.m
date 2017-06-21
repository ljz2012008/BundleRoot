//
//  BRUnarchiverController.m
//  BundleRoot
//
//  Created by Foolery on 6/18/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "BRUnarchiverController.h"

#import <XADMaster/XADSimpleUnarchiver.h>
#import <XADMaster/XADPlatform.h>

@interface BRUnarchiverController ()
{
    id finishTarget;
    SEL finishSelector;
}

@property (assign) BOOL cancelled;

@end

@implementation BRUnarchiverController

- (id)initWithFilename:(NSString *)filename
{
    if ((self = [super init])) {
        _archiveName = filename;
        finishTarget = nil;
        finishSelector = NULL;
    }
    return self;
}

- (void)runWithFinishAction:(SEL)selector target:(id)target
{
    finishTarget = target;
    finishSelector = selector;
    
    [NSThread detachNewThreadSelector:@selector(executeExtractThread) toTarget:self withObject:nil];
}

- (void)executeExtractThread
{
    [self extract];
}

- (void)extract
{
    NSString *destinationPath;
    NSString *path = _archiveName;
    destinationPath = [path stringByDeletingLastPathComponent];
    
    if([XADPlatform fileExistsAtPath:path])
    {
        XADError openerror;
        XADSimpleUnarchiver *unarchiver=[XADSimpleUnarchiver simpleUnarchiverForPath:path error:&openerror];
        [unarchiver setEnclosingDirectoryName:[[path lastPathComponent] stringByDeletingPathExtension]];
        [unarchiver setDestination:destinationPath];
        [unarchiver setRemovesEnclosingDirectoryForSoloItems:YES];
//        [unarchiver setEnclosingDirectoryName:NO];
        [unarchiver setAlwaysOverwritesFiles:NO];
        [unarchiver setAlwaysRenamesFiles:YES];
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
    
    [finishTarget performSelector:finishSelector withObject:self];
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

-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver willExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path
{
    XADPath *name=[dict objectForKey:XADFileNameKey];
    
}

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
    
    NSLog(@"TopName : %@, Total Progress: %lu%%",
          [[unarchiver destination] lastPathComponent], progressInt);
}

-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver estimatedExtractionProgressForEntryWithDictionary:(NSDictionary *)dict
           fileProgress:(double)fileprogress totalProgress:(double)totalprogress
{
    NSLog(@"gz Total Progress: %f%%", 100*totalprogress);
}

#pragma mark - XADSimpleUnarchiverDelegate

@end
