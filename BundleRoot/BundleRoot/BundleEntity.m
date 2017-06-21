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
        _bundleRelatedPath = @"";
        _bundleFullPath = @"";
        _bundleSets = [NSMutableArray new];
        _isSelected = YES;
    }
    return self;
}

- (id)initWithTypeName:(NSString *)name
{
    self = [self init];
    if (self) {
        _bundleType = name;
    }
    return self;
}

@end
