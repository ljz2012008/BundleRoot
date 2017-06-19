//
//  BRUnarchiverController.h
//  BundleRoot
//
//  Created by Foolery on 6/18/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRUnarchiverController : NSObject

@property (strong) NSString *archiveName;
@property (strong) NSString *destinationPath;
@property (weak) id finishTarget;
@property (assign) SEL finishSelector;

- (id)initWithFilename:(NSString *)filename;
- (void)runWithFinishAction:(SEL)selector target:(id)target;
- (void)executeExtractThread;
- (void)extract;

@end
