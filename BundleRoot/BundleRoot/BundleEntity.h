//
//  BundleEntity.h
//  BundleRoot
//
//  Created by Foolery on 6/21/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BREFI       @"BREFI"
#define BROS        @"BROS"
#define BRBaseband  @"BRBaseband"
#define BRGrapeRoot @"BRGrapeRoot"
#define BRMesa      @"BRMesa"
#define BRWifi      @"BRWifi"
#define BRPWifi     @"BRPWifi"
#define BRBT        @"BRBT"
#define BRbblib     @"BRbblib"
#define BRWipaMini  @"BRWipaMini"

#define varString(var) [NSString stringWithFormat:@"%s",#var]

@interface BundleEntity : NSObject

@property (strong) NSString *bundleName;
@property (strong) NSString *bundleType;
@property (strong) NSString *bundleRelatedPath;
@property (strong) NSString *bundleFullPath;
@property (strong) NSMutableArray *bundleSets;
@property (assign) BOOL isSelected;

- (id)initWithTypeName:(NSString *)name;

@end
