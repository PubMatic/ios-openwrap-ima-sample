/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWConfiguration.h"

// Value for BOOL YES
POWBOOL const POWBOOLYes = 1;
// Value for BOOL NO
POWBOOL const POWBOOLNo = 0;

@implementation POWConfiguration
@synthesize userInfo = _userInfo;
@synthesize appInfo = _appInfo;

+ (POWConfiguration *)sharedConfig {
    static POWConfiguration *sharedPOWConfig = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        sharedPOWConfig = [[POWConfiguration alloc] init];
    });
    
    return sharedPOWConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _linearity = POWLinearityTypeLinear;
        _enableGDPR = -1;
    }
    return self;
}

- (POWUserInfo *)userInfo {
    if (!_userInfo) {
        _userInfo = [POWUserInfo new];
    }
    return _userInfo;
}

- (POWApplicationInfo *)appInfo {
    if (!_appInfo) {
        _appInfo = [POWApplicationInfo new];
    }
    return _appInfo;
}

@end
