/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <XCTest/XCTest.h>
#import <AdSupport/ASIdentifierManager.h>
#import "POWAdRequest.h"
#import "POWConfiguration.h"

@interface POWAdRequest()
@property (nonatomic, strong) NSString *pubId;
@property (nonatomic, strong) NSNumber *profileId;

- (NSDictionary *)deviceInfoObject;
- (NSDictionary *)userInfoObject;
- (NSDictionary *)appInfoObject;
- (NSDictionary *)bidderExtension;
- (NSDictionary *)queryParametersDictionary;
- (NSString *)urlString;
@end

@interface POWAdRequestTests : XCTestCase
@property POWAdRequest *request;
@end

@implementation POWAdRequestTests

- (void)setUp {
    _request = [[POWAdRequest alloc] initWithPublisherId:@"156276"
                                               profileId:@1234
                                                adUnitId:@"adUnitId"
                                                 andSize:CGSizeMake(320, 480)];
}

- (void)tearDown {
    _request = nil;
    SharedConfig.appInfo = nil;
    SharedConfig.userInfo = nil;
    SharedConfig.CCPA = nil;
    SharedConfig.GDPRConsent = nil;
    SharedConfig.customKeyValues = nil;
    SharedConfig.hashTypeForAdvertisingId = POWHashTypeRaw;
    SharedConfig.linearity = POWLinearityTypeLinear;
    [SharedConfig setValue:@-1 forKey:@"enableGDPR"];
}

- (void)testInit {
    XCTAssertNotNil(_request);
    XCTAssertEqualObjects(_request.pubId, @"156276");
    XCTAssertEqualObjects(_request.profileId, @1234);
    XCTAssertEqualObjects(_request.adUnitId, @"adUnitId");
    XCTAssertTrue(_request.size.width == 320 && _request.size.height == 480);
}

// Test network timeouts
- (void)testRequest_defaultTimeout {
    // Case 1: Default request timeout
    NSURLRequest *urlRequest = [_request urlRequest];
    XCTAssertNotNil(urlRequest);
    XCTAssertEqual(urlRequest.timeoutInterval, 5);
    
    // Case 2: User set request timeout
    _request.networkTimeout = 2;
    urlRequest = [_request urlRequest];
    XCTAssertNotNil(urlRequest);
    XCTAssertEqual(urlRequest.timeoutInterval, 2);
}

#pragma mark - Device Info

// Case 1: Raw IDFA
- (void)testDeviceInfoObject_rawIDFA {
    NSDictionary *deviceDict = [_request deviceInfoObject];
    XCTAssertEqualObjects(deviceDict[@"pwtlmt"], @0);
    XCTAssertEqualObjects(deviceDict[@"pwtdnt"], @0);
    XCTAssertNotNil(deviceDict[@"pwtifa"]);
    XCTAssertEqualObjects(deviceDict[@"pwtjs"], @1);
    XCTAssertNotNil(deviceDict[@"pwtuto"]);
    
    // No hash Set
    XCTAssertNil(deviceDict[@"pwtdpidsha1"]);
    XCTAssertNil(deviceDict[@"pwtdpidmd5"]);
}

// Case 2: SHA1 IDFA
- (void)testDeviceInfoObject_SHA1Hash {
    [POWConfiguration sharedConfig].hashTypeForAdvertisingId = POWHashTypeSHA1;
    
    NSDictionary *deviceDict = [_request deviceInfoObject];
    XCTAssertEqualObjects(deviceDict[@"pwtlmt"], @0);
    XCTAssertEqualObjects(deviceDict[@"pwtdnt"], @0);
    XCTAssertNotNil(deviceDict[@"pwtdpidsha1"]);
    XCTAssertEqualObjects(deviceDict[@"pwtjs"], @1);
    XCTAssertNotNil(deviceDict[@"pwtuto"]);
    
    XCTAssertNil(deviceDict[@"pwtifa"]);
    XCTAssertNil(deviceDict[@"pwtdpidmd5"]);
}

// Case 3: MD5 IDFA
- (void)testDeviceInfoObject_MD5Hash {
    [POWConfiguration sharedConfig].hashTypeForAdvertisingId = POWHashTypeMD5;
    
    NSDictionary *deviceDict = [_request deviceInfoObject];
    XCTAssertEqualObjects(deviceDict[@"pwtlmt"], @0);
    XCTAssertEqualObjects(deviceDict[@"pwtdnt"], @0);
    XCTAssertNotNil(deviceDict[@"pwtdpidmd5"]);
    XCTAssertEqualObjects(deviceDict[@"pwtjs"], @1);
    XCTAssertNotNil(deviceDict[@"pwtuto"]);
    
    XCTAssertNil(deviceDict[@"pwtifa"]);
    XCTAssertNil(deviceDict[@"pwtdpidsha1"]);
}

#pragma mark - User Info

// Case 1: No user data available
- (void)testUserInfoObject_noUserData {
    NSDictionary *userInfo = [_request userInfoObject];
    XCTAssertNil(userInfo[@"pwtlat"]);
    XCTAssertNil(userInfo[@"pwtlon"]);
    XCTAssertNil(userInfo[@"pwtgtype"]);
    XCTAssertNil(userInfo[@"pwtcntr"]);
    XCTAssertNil(userInfo[@"pwtcity"]);
    XCTAssertNil(userInfo[@"pwtmet"]);
    XCTAssertNil(userInfo[@"pwtzip"]);
    XCTAssertNil(userInfo[@"pwtgender"]);
    XCTAssertNil(userInfo[@"pwtyob"]);
}

// Case 2: User data is available - No location source provided
- (void)testUserInfoObject_validUserData_NoLocSource {
    POWUserInfo *userInfo = [POWUserInfo new];
    userInfo.location = [[CLLocation alloc] initWithLatitude:12.384 longitude:94.3];
    userInfo.country = @"India";
    userInfo.city = @"Baner";
    userInfo.metro = @"Pune";
    userInfo.zip = @"411021";
    userInfo.gender = POWGenderMale;
    userInfo.birthYear = @1989;
    [POWConfiguration sharedConfig].userInfo = userInfo;
    
    NSDictionary *userInfoDict = [_request userInfoObject];
    XCTAssertEqualObjects(userInfoDict[@"pwtlat"], @12.384);
    XCTAssertEqualObjects(userInfoDict[@"pwtlon"], @94.3);
    XCTAssertEqualObjects(userInfoDict[@"pwtgtype"], @3);
    XCTAssertEqualObjects(userInfoDict[@"pwtcntr"], @"India");
    XCTAssertEqualObjects(userInfoDict[@"pwtcity"], @"Baner");
    XCTAssertEqualObjects(userInfoDict[@"pwtmet"], @"Pune");
    XCTAssertEqualObjects(userInfoDict[@"pwtzip"], @"411021");
    XCTAssertEqualObjects(userInfoDict[@"pwtgender"], @"M");
    XCTAssertEqualObjects(userInfoDict[@"pwtyob"], @1989);
}

// Case 3: User data is available - Location source provided by user
- (void)testUserInfoObject_validUserData_locSourceProvided {
    POWUserInfo *userInfo = [POWUserInfo new];
    userInfo.location = [[CLLocation alloc] initWithLatitude:12.384 longitude:94.3];
    
    // Case 1: Location source GPS
    userInfo.locationSource = POWLocSourceGPS;
    [POWConfiguration sharedConfig].userInfo = userInfo;
    
    NSDictionary *userInfoDict = [_request userInfoObject];
    XCTAssertEqualObjects(userInfoDict[@"pwtlat"], @12.384);
    XCTAssertEqualObjects(userInfoDict[@"pwtlon"], @94.3);
    XCTAssertEqualObjects(userInfoDict[@"pwtgtype"], @1);
    
    // Case 2: Location source GPS IP address
    userInfo.locationSource = POWLocSourceIPAddress;
    [POWConfiguration sharedConfig].userInfo = userInfo;
    
    userInfoDict = [_request userInfoObject];
    XCTAssertEqualObjects(userInfoDict[@"pwtlat"], @12.384);
    XCTAssertEqualObjects(userInfoDict[@"pwtlon"], @94.3);
    XCTAssertEqualObjects(userInfoDict[@"pwtgtype"], @2);
}

#pragma mark - Application Info

// Case 1: No App data available
- (void)testAppInfoObject_noAppData {
    NSDictionary *appInfoDict = [_request appInfoObject];
    XCTAssertEqualObjects(appInfoDict[@"pwtappname"], @"SampleApp");
    XCTAssertNil(appInfoDict[@"pwtm_url"]);
    XCTAssertNil(appInfoDict[@"pwtappurl"]);
    XCTAssertNil(appInfoDict[@"pwtappid"]);
    XCTAssertNil(appInfoDict[@"pwtappbdl"]);
    XCTAssertNil(appInfoDict[@"pwtappdom"]);
    XCTAssertNil(appInfoDict[@"pwtappcat"]);
    XCTAssertNil(appInfoDict[@"pwtapppd"]);
}

// Case 2: Valid App data is available
- (void)testAppInfoObject_validAppData {
    NSString *appStoreUrl = @"https://itunes.apple.com/app/id378458261";
    POWApplicationInfo *appInfo = [POWApplicationInfo new];
    appInfo.storeURL = appStoreUrl;
    appInfo.categories = @"val1,val2";
    appInfo.domain = @"pubmatic.sampleapp.com";
    appInfo.paid = NO;
    [POWConfiguration sharedConfig].appInfo = appInfo;
    
    NSDictionary *appInfoDict = [_request appInfoObject];
    XCTAssertEqualObjects(appInfoDict[@"pwtappname"], @"SampleApp");
    XCTAssertEqualObjects(appInfoDict[@"pwtm_url"], appStoreUrl);
    XCTAssertEqualObjects(appInfoDict[@"pwtappurl"], appStoreUrl);
    XCTAssertEqualObjects(appInfoDict[@"pwtappid"], @"378458261");
    XCTAssertEqualObjects(appInfoDict[@"pwtappbdl"], @"378458261");
    XCTAssertEqualObjects(appInfoDict[@"pwtappdom"], @"pubmatic.sampleapp.com");
    XCTAssertEqualObjects(appInfoDict[@"pwtappcat"], @"val1,val2");
    XCTAssertEqualObjects(appInfoDict[@"pwtapppd"], @0);
}

#pragma mark - Bidder Extension

// Case 1: No values available for bidder extension
- (void)testBidderExtension_noValues {
    NSDictionary *bidderInfo = [_request bidderExtension];
    XCTAssertNil(bidderInfo);
}

// Case 2: Values are available for bidder extension
- (void)testBidderExtension_valuesAvailable {
    _request.bidderCustomParams = @{ @"pubmatic": @{
            @"keywords": @[@{
                @"key": @"dctr",
                @"value": @[@"val1", @"val2"]
            }]
        },
        @"appnexus": @{
            @"keywords": @[@{
                    @"key": @"key1",
                    @"value": @[@"val1", @"val2"]
                },
                @{
                    @"key": @"key2",
                    @"value": @[@"val1"]
                }
            ]
        }
     
    };
    NSString *expectedValue = @"{\n  \"pubmatic\" : {\n    \"keywords\" : [\n      {\n        \"key\" : \"dctr\",\n        \"value\" : [\n          \"val1\",\n          \"val2\"\n        ]\n      }\n    ]\n  },\n  \"appnexus\" : {\n    \"keywords\" : [\n      {\n        \"key\" : \"key1\",\n        \"value\" : [\n          \"val1\",\n          \"val2\"\n        ]\n      },\n      {\n        \"key\" : \"key2\",\n        \"value\" : [\n          \"val1\"\n        ]\n      }\n    ]\n  }\n}";
    NSDictionary *bidderInfo = [_request bidderExtension];
    XCTAssertEqualObjects(bidderInfo[@"pwtbidrprm"], expectedValue);
}

#pragma mark - Generic quesry parameters dict

// Case 1: Default parameters
- (void)testQueryParametersDictionary_defaultParams {
    NSDictionary *queryParams = [_request queryParametersDictionary];
    XCTAssertEqualObjects(queryParams[@"pubId"], @"156276");
    XCTAssertEqualObjects(queryParams[@"profId"], @1234);
    XCTAssertEqualObjects(queryParams[@"pwtmime"], @"1");
    XCTAssertEqualObjects(queryParams[@"adserver"], @"DFP");
    XCTAssertEqualObjects(queryParams[@"pwtplt"], @"video");
    XCTAssertEqualObjects(queryParams[@"pwtm_iu"], @"adUnitId");
    XCTAssertEqualObjects(queryParams[@"pwtm_sz"], @"320x480");
    XCTAssertEqualObjects(queryParams[@"f"], @"json");
    XCTAssertEqualObjects(queryParams[@"pwtapp"], @"1");
    XCTAssertNil(queryParams[@"pwtgdpr"]);
    XCTAssertNil(queryParams[@"pwtcnst"]);
    XCTAssertNil(queryParams[@"pwtccpa"]);
    XCTAssertNil(queryParams[@"pwtv"]);
    XCTAssertNil(queryParams[@"pwtvc"]);
    XCTAssertEqualObjects(queryParams[@"pwtvlin"], @1);
}

// Case 2: CCPA/ GDPR set
- (void)testQueryParametersDictionary_expliciteSetParams {
    SharedConfig.CCPA = @"CCPA String";
    SharedConfig.enableGDPR = YES;
    SharedConfig.GDPRConsent = @"GDPR Consent";
    SharedConfig.customKeyValues = @{@"pwtplbk": @2, @"pwtvpos": @"Inline"};
    _request.enableDebug = YES;
    _request.versionId = @2;
    
    NSDictionary *queryParams = [_request queryParametersDictionary];
    XCTAssertEqualObjects(queryParams[@"pwtgdpr"], @1);
    XCTAssertEqualObjects(queryParams[@"pwtcnst"], @"GDPR Consent");
    XCTAssertEqualObjects(queryParams[@"pwtccpa"], @"CCPA String");
    XCTAssertEqualObjects(queryParams[@"pwtv"], @2);
    XCTAssertEqualObjects(queryParams[@"pwtvc"], @1);
    XCTAssertEqualObjects(queryParams[@"pwtplbk"], @2);
    XCTAssertEqualObjects(queryParams[@"pwtvpos"], @"Inline");
}

// Case 3: Linearity values set
- (void)testQueryParametersDictionary_linearityValues {
    // Case 1: Linear
    SharedConfig.linearity = POWLinearityTypeLinear;
    NSDictionary *queryParams = [_request queryParametersDictionary];
    XCTAssertEqualObjects(queryParams[@"pwtvlin"], @1);
    
    // Case 2: Non-Linear
    SharedConfig.linearity = POWLinearityTypeNonLinear;
    queryParams = [_request queryParametersDictionary];
    XCTAssertEqualObjects(queryParams[@"pwtvlin"], @2);
}

#pragma mark - URL string generation

// Case 1: No explicite setters
- (void)testUrlString_noSetters {
    NSString *expectedString = [NSString stringWithFormat:@"https://ow.pubmatic.com/openrtb/2.5/video?pwtapp=1&pwtappname=SampleApp&adserver=DFP&pwtifa=%@&pwtplt=video&pwtdnt=0&pwtvlin=1&pwtm_iu=adUnitId&pwtjs=1&profId=1234&pubId=156276&pwtuto=330&pwtlmt=0&f=json&pwtm_sz=320x480&pwtmime=1", [self idfa]];
    NSString *resultUrlString = [_request urlString];
    XCTAssertEqualObjects(expectedString, resultUrlString);
}

// Case 2: Setters with valid strings
- (void)testUrlString_validStrings {
    [self setupValidRequest];
    NSString *expectedString = @"https://ow.pubmatic.com/openrtb/2.5/video?pwtm_sz=320x480&pwtapp=1&pwtappcat=val1%2Cval2&pwtcity=Pune&pwtapppd=0&pwtuto=330&f=json&pwtlmt=0&pwtvc=1&pwtappid=378458261&pwtjs=1&pwtlon=94.3&pwtplbk=2&pubId=156276&pwtdnt=0&pwtmet=Maharashtra&pwtyob=1989&pwtgender=M&pwtmime=1&pwtplt=video&pwtm_iu=adUnitId&pwtccpa=CCPA&pwtappdom=pubmatic.sampleapp.com&pwtifa=";
    expectedString = [expectedString stringByAppendingString:[self idfa]];
    expectedString = [expectedString stringByAppendingString:@"&pwtcnst=GDPRConsent&pwtgdpr=1&pwtm_url=https%3A%2F%2Fitunes.apple.com%2Fapp%2Fid378458261&pwtappbdl=378458261&pwtappname=SampleApp&pwtv=2&pwtvpos=Inline&profId=1234&pwtlat=12.384&pwtgtype=3&pwtappurl=https%3A%2F%2Fitunes.apple.com%2Fapp%2Fid378458261&pwtzip=411021&pwtvlin=1&pwtcntr=India&adserver=DFP"];
    // Append device/simulator specific IDFA here.
    NSString *resultUrlString = [_request urlString];
    XCTAssertEqualObjects(expectedString, resultUrlString);
}

// Case 3: Setters with strings having special characters
- (void)testUrlString_validStringsWithSpecialChars {
    [self setupdRequestWithSpecialCharValues];
    NSString *expectedString = @"https://ow.pubmatic.com/openrtb/2.5/video?pubId=156276&pwtappbdl=378458261&pwtzip=411-021&profId=1234&pwtm_iu=adUnitId&pwtuto=330&pwtcntr=%21ndi%40&pwtappcat=val1%2612%2Cval2%2F23&f=json&pwtmime=1&pwtvlin=1&adserver=DFP&pwtdnt=0&pwtapp=1&pwtplt=video&pwtappurl=https%3A%2F%2Fitunes.apple.com%2Fapp%2Fid378458261&pwtccpa=CCPA%2FCCAP2&pwtlmt=0&pwtappname=SampleApp&pwtappid=378458261&pwtcity=Pune%2345&pwtm_url=https%3A%2F%2Fitunes.apple.com%2Fapp%2Fid378458261&pwtgdpr=1&pwtjs=1&pwtifa=";
    // Append device/simulator specific IDFA here.
    expectedString = [expectedString stringByAppendingString:[self idfa]];
    expectedString = [expectedString stringByAppendingString:@"&pwtmet=Mahar%40shtr%40&pwtcnst=GDPRConsent%2612&pwtm_sz=320x480"];
    NSString *resultUrlString = [_request urlString];
    XCTAssertEqualObjects(expectedString, resultUrlString);
}

#pragma mark - Supporting Methods

// Create a valid request
- (void)setupValidRequest {
    POWConfiguration *config = [POWConfiguration sharedConfig];
    config.CCPA = @"CCPA";
    config.enableGDPR = YES;
    config.GDPRConsent = @"GDPRConsent";
    config.linearity = POWLinearityTypeLinear;
    config.customKeyValues = @{@"pwtplbk": @2, @"pwtvpos": @"Inline"};
    
    // Set User Info info
    POWUserInfo *userInfo = [POWUserInfo new];
    userInfo.city = @"Pune";
    userInfo.country = @"India";
    userInfo.metro = @"Maharashtra";
    userInfo.zip = @"411021";
    userInfo.gender = POWGenderMale;
    userInfo.birthYear = @1989;
    userInfo.location = [[CLLocation alloc] initWithLatitude:12.384 longitude:94.3];
    [POWConfiguration sharedConfig].userInfo = userInfo;

    // Set application info
    POWApplicationInfo *appInfo = [POWApplicationInfo new];
    appInfo.storeURL = @"https://itunes.apple.com/app/id378458261";
    appInfo.categories = @"val1,val2";
    appInfo.domain = @"pubmatic.sampleapp.com";
    appInfo.paid = NO;
    [POWConfiguration sharedConfig].appInfo = appInfo;
    
    _request.enableDebug = YES;
    _request.versionId = @2;
    _request.networkTimeout = 2;
}

// Create a request with parameters with special characters
- (void)setupdRequestWithSpecialCharValues {
    POWConfiguration *config = [POWConfiguration sharedConfig];
    config.CCPA = @"CCPA/CCAP2";
    config.enableGDPR = YES;
    config.GDPRConsent = @"GDPRConsent&12";
    
    // Set User Info info
    POWUserInfo *userInfo = [POWUserInfo new];
    userInfo.city = @"Pune#45";
    userInfo.country = @"!ndi@";
    userInfo.metro = @"Mahar@shtr@";
    userInfo.zip = @"411-021";
    [POWConfiguration sharedConfig].userInfo = userInfo;

    // Set application info
    POWApplicationInfo *appInfo = [POWApplicationInfo new];
    appInfo.storeURL = @"https://itunes.apple.com/app/id378458261";
    appInfo.categories = @"val1&12,val2/23";
    [POWConfiguration sharedConfig].appInfo = appInfo;
}

// Get device IDFA
- (NSString *)idfa {
    return [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
}

@end
