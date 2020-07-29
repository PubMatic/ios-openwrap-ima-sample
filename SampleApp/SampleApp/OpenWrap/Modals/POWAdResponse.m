/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWAdResponse.h"

NSString *const kPOWTargetting = @"targeting";

@implementation POWAdResponse

#pragma mark - Initializers

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _targettingInfo = dictionary[kPOWTargetting];
    }
    return self;
}

@end
