//
//  BundleEntity.m
//  BundleRoot
//
//  Created by Foolery on 6/21/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import "BundleEntity.h"

@implementation BundleEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bundleName = @"";
        _bundleType = @"";
        _bundleParentPath = @"";
        _bundleRelatedPath = @"";
        _bundleFullPath = @"";
        _bundleExtractPath = @"";
        _bundleSets = [NSMutableArray new];
        _isSelected = YES;
        _isValid = NO;
        _isArchived = YES;
    }
    return self;
}

- (id)initWithType:(NSString *)name
{
    self = [self init];
    if (self) {
        _bundleType = name;
    }
    return self;
}

@end
