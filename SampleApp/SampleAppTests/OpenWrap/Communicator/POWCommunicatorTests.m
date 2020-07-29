/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <XCTest/XCTest.h>
#import "POWCommunicator.h"

@interface POWCommunicator()
- (POWAdResponse *)parseResponse:(NSData *)response error:(NSError **)error;
@end

@interface POWCommunicatorTests : XCTestCase <POWCommunicatorDelegate>
@property POWCommunicator *communicator;
@property POWAdRequest *request;
@property XCTestExpectation *expectation;
@property NSInteger errorCode;
@end

@implementation POWCommunicatorTests

- (void)setUp {
    _request = [[POWAdRequest alloc] initWithPublisherId:@"156276"
                                               profileId:@2486
                                                adUnitId:@"/15671365/pm_ott_video"
                                                 andSize:CGSizeMake(640, 480)];
    _communicator = [[POWCommunicator alloc] initWithRequest:_request];
    _communicator.delegate = self;
}

- (void)tearDown {
    _errorCode = 0;
    _request = nil;
    _communicator = nil;
    _expectation = nil;
}

// Case 1: Valid request
- (void)testRequestAd_validRequest {
    _expectation = [self expectationWithDescription:@"communicator:didReceiveAdResponse: should be called."];
    [_communicator requestAd];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// Case 2: Nil request
- (void)testRequestAd_nilRequest {
    _communicator = [[POWCommunicator alloc] initWithRequest:nil];
    _communicator.delegate = self;
    _expectation = [self expectationWithDescription:@"communicator:didFailWithError: should be called."];
    _errorCode = NSURLErrorBadURL;
    [_communicator requestAd];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

// Test parse response
- (void)testParseResponse {
    // Case 1: Valid response
    NSError *error = nil;
    NSString *responseStr = @"{ \"targeting\" :{ \"pwtbst\": 1, \"pwtcid\": \"aaf3854e-e541-497b-8d67-9dadcc626209\", \"pwtcpath\": \"/cache\", \"pwtcurl\": \"https://ow.pubmatic.com\", \"pwtecp\": \"3.00\", \"pwtpid\": \"pubmatic\", \"pwtplt\": \"video\", \"pwtprofid\": 2486, \"pwtpubid\": 156276, \"pwtsid\": \"/15671365/pm_ott_video\", \"pwtsz\": \"0x0\", \"pwtverid\": 2}}";
    POWAdResponse *adResponse = [_communicator parseResponse:[responseStr dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(adResponse.targettingInfo);
    
    // Case 2: Invalid response
    error = nil;
    responseStr = @"{ \"targeting\" :{ \"pwtbst\": 1 \"pwtcid\": \"aaf3854e-e541-497b-8d67-9dadcc626209\", \"pwtcpath\": \"/cache\", \"pwtcurl\": \"https://ow.pubmatic.com\", \"pwtecp\": \"3.00\", \"pwtpid\": \"pubmatic\", \"pwtplt\": \"video\", \"pwtprofid\": 2486, \"pwtpubid\": 156276, \"pwtsid\": \"/15671365/pm_ott_video\", \"pwtsz\": \"0x0\", \"pwtverid\": 2}";
    adResponse = [_communicator parseResponse:[responseStr dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNil(adResponse);
    XCTAssertNotNil(error);
    
    // Case 3: nil response
    error = nil;
    adResponse = [_communicator parseResponse:nil error:&error];
    XCTAssertNil(adResponse);
    XCTAssertTrue(error.code == NSURLErrorCannotParseResponse);
    
    // Case 4: Empty response
    error = nil;
    adResponse = [_communicator parseResponse:[NSData new] error:&error];
    XCTAssertNil(adResponse);
    XCTAssertNotNil(error);
}

#pragma mark - POWCommunicatorDelegate

- (void)communicator:(POWCommunicator *)communicator didReceiveAdResponse:(POWAdResponse *)response {
    XCTAssertNotNil(response);
    [_expectation fulfill];
}

- (void)communicator:(POWCommunicator *)communicator didFailWithError:(NSError *)error {
    XCTAssertTrue(error.code == _errorCode);
    [_expectation fulfill];
}

@end
