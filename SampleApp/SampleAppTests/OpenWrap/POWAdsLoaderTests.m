/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <XCTest/XCTest.h>
#import "POWAdsLoader.h"

@interface POWAdsLoaderTests : XCTestCase <POWAdsLoaderDelegate>
@property POWAdsLoader *adsLoader;
@property XCTestExpectation *expectation;
@end

@implementation POWAdsLoaderTests

- (void)setUp {
    _adsLoader = [POWAdsLoader new];
    _adsLoader.delegate = self;
}

- (void)tearDown {
    _adsLoader = nil;
    _expectation = nil;
}

// Case 1: Invalid request
- (void)testRequestAdsWithRequest_invalidRequest {
    _expectation = [self expectationWithDescription:@"adsLoader:didFailWithError: should be called."];
    POWAdRequest *adRequest = nil;
    [_adsLoader requestAdsWithRequest:adRequest];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

// Case 2: Valid request
- (void)testRequestAdsWithRequest_validRequest {
    _expectation = [self expectationWithDescription:@"adsLoader:didLoadAd: should be called."];
    POWAdRequest *adRequest = [[POWAdRequest alloc] initWithPublisherId:@"156276"
                                                              profileId:@2486
                                                               adUnitId:@"/15671365/pm_ott_video"
                                                                andSize:CGSizeMake(640, 480)];
    [_adsLoader requestAdsWithRequest:adRequest];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark - POWAdsLoaderDelegate

- (void)adsLoader:(POWAdsLoader *)loader didLoadAd:(POWAdResponse *)adResponse {
    XCTAssertTrue([NSThread isMainThread]);
    XCTAssertNotNil(adResponse.targettingInfo);
    [_expectation fulfill];
}

- (void)adsLoader:(POWAdsLoader *)loader didFailWithError:(NSError *)error {
    XCTAssertTrue([NSThread isMainThread]);
    [_expectation fulfill];
}

@end
