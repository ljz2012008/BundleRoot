//
//  BRUnarchiverController.h
//  BundleRoot
//
//  Created by Foolery on 6/18/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRUnarchiverController : NSObject

- (id)initWithFilename:(NSString *)filename;
- (void)runWithFinishAction:(SEL)selector target:(id)target;
- (void)executeExtractThread;
- (void)extract;

@end
