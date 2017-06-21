//
//  BRUnarchiverController.h
//  BundleRoot
//
//  Created by Foolery on 6/18/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BRUnarchiverToMainControllerDelegate <NSObject>

- (void)updateProgressWith:(double)dProgress target:(id)targetObj;

@end

@interface BRUnarchiverController : NSObject

@property (strong) NSString *archiveType;
@property (strong) NSString *archiveName;
@property (strong) NSString *destinationPath;

@property (weak) id mainControllerDelegate;


- (id)initWithFilename:(NSString *)filename;
- (void)runWithFinishAction:(SEL)selector target:(id)target;
- (void)executeExtractThread;
- (void)extract;

@end
