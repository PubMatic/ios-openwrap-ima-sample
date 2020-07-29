/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <XCTest/XCTest.h>
#import "POWApplicationInfo.h"

@interface POWApplicationInfoTests : XCTestCase
@property POWApplicationInfo *appInfo;
@end

@implementation POWApplicationInfoTests

- (void)setUp {
    _appInfo = [POWApplicationInfo new];
}

- (void)tearDown {
    _appInfo = nil;
}

- (void)testAppId {
    // Case 1: Nil app store url
    NSString *itunesId = [_appInfo appId];
    XCTAssertNil(itunesId);
    
    _appInfo.storeURL = @"https://itunes.apple.com/us/app/i1175273098?mt=8";
    itunesId = [_appInfo appId];
    XCTAssertNil(itunesId);
    
    _appInfo.storeURL = @"https://itunes.apple.com/us/app/i";
    itunesId = [_appInfo appId];
    XCTAssertNil(itunesId);
    
    // Case 2: Valid itunes id
    _appInfo.storeURL = @"https://itunes.apple.com/us/app/id1175273098?mt=8";
    itunesId = [_appInfo appId];
    XCTAssertEqualObjects(itunesId, @"1175273098");
}

- (void)testAppName {
    NSString *appName = [_appInfo name];
    XCTAssertEqualObjects(appName, @"SampleApp");
}

@end
