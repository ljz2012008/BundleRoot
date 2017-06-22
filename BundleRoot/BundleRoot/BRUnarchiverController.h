//
//  BRUnarchiverController.h
//  BundleRoot
//
//  Created by Foolery on 6/18/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BundleEntity.h"

@protocol BRUnarchiverToMainControllerDelegate <NSObject>

- (void)updateProgress:(double)dProgress target:(id)Obj;

@end

@interface BRUnarchiverController : NSObject

@property (weak) BundleEntity *bEntity;
@property (weak) id mainControllerDelegate;

- (id)initWithEntity:(BundleEntity *)entity;
- (void)runWithFinishAction:(SEL)selector target:(id)target;
- (void)executeExtractThread;
- (void)extract;

@end
