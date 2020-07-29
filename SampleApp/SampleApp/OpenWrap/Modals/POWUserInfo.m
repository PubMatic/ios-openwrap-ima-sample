/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWUserInfo.h"

@implementation POWUserInfo

- (instancetype)init{
    self = [super init];
    if (self) {
        // No value set for gender.
        self.gender = -1;
    }
    return self;
}

@end
