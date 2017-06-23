//
//  BundleEntity.h
//  BundleRoot
//
//  Created by Foolery on 6/21/17.
//  Copyright © 2017 itsme. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BREFI       @"EFI"
#define BROS        @"OS"
#define BRBaseband  @"Baseband"
#define BRGrapeRoot @"GrapeRoot"
#define BRMesa      @"Mesa"

#define BRPWifi     @"P_Wifi"

#define BRWifi_BT   @"Wifi_BT"
#define BRbblib     @"bblib"
#define BRWipaMini  @"WipaMini"

#define varString(var) [NSString stringWithFormat:@"%s",#var]

@interface BundleEntity : NSObject

@property (strong) NSString *bundleName;
@property (strong) NSString *bundleType;
@property (strong) NSString *bundleParentPath;
@property (strong) NSString *bundleRelatedPath;
@property (strong) NSString *bundleFullPath;
@property (strong) NSString *bundleExtractPath;
@property (strong) NSMutableArray *bundleSets;
@property (assign) BOOL isSelected;
@property (assign) BOOL isValid;
@property (assign) BOOL isArchived;

- (id)initWithType:(NSString *)name;

@end
