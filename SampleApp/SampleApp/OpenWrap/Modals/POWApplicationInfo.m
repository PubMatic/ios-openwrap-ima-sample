/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWApplicationInfo.h"

static NSCharacterSet *numericCharSet;
NSString *const POWITUNES_ID_MISSING_LOG = @"storeURL is malformed or missing a valid numeric itunes Id. It is required for platform identification";

@implementation POWApplicationInfo
@synthesize appId = _appId;
@synthesize name = _name;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.paid = -1;
    }
    return self;
}

- (NSString *)appId {
    return [self itunesIdFromStoreUrl:[NSURL URLWithString:self.storeURL]];
}

// Get the application name
- (NSString *)name{
    if (!_name) {
        _name = [NSBundle mainBundle].localizedInfoDictionary[@"CFBundleDisplayName"];
        if (!_name) {
            _name = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
        }
        
        if (!_name) {
            _name = [NSBundle mainBundle].localizedInfoDictionary[(NSString*)kCFBundleNameKey];
        }
        
        if (!_name) {
            _name = [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleNameKey];
        }
        
        if (!_name) {
            _name = [NSProcessInfo processInfo].processName;
        }
    }
    return _name;
}

#pragma mark - Private methods

- (NSString *)itunesIdFromStoreUrl:(NSURL *)storeUrl {
    NSMutableString *itunesId = storeUrl.lastPathComponent.mutableCopy;
    NSRange idRange = NSMakeRange(0, 2);
    @try{
        NSString *idPrefix = [itunesId substringWithRange:idRange];
        // Remove 'id' prefix from lastPathComponent to get itunes id
        [itunesId deleteCharactersInRange:idRange];
        if (!numericCharSet) {
            numericCharSet = [NSCharacterSet decimalDigitCharacterSet];
        }
        NSString *expectedEmptyString = [itunesId stringByTrimmingCharactersInSet:numericCharSet];
        if (![idPrefix isEqualToString:@"id"] || !itunesId.length || expectedEmptyString.length) {
            NSLog(POWITUNES_ID_MISSING_LOG);
            return nil;
        }
    } @catch(NSException *exception){
        NSLog(POWITUNES_ID_MISSING_LOG);
        return nil;
    }
    return itunesId;
}

@end
