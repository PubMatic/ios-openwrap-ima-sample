/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <XCTest/XCTest.h>
#import "POWUtil.h"

@interface POWUtilTests : XCTestCase

@end

@implementation POWUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - POWUtil methods

- (void)testCheckForOKResponse {
    // Case 1: Error response
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://ow.pubmatic.com/openrtb/2.5/video"] statusCode:400 HTTPVersion:nil headerFields:@{ @"Connection": @"keep-alive", @"Content-Length": @"0" }];
    NSError *error = [POWUtil checkForOKResponse:response andData:nil];
    XCTAssertNotNil(error);
    XCTAssertTrue(error.code == 400);
    
    // Case 2: No error response
    response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://ow.pubmatic.com/openrtb/2.5/video"] statusCode:200 HTTPVersion:nil headerFields:@{ @"Connection": @"keep-alive", @"Content-Length": @"0" }];
    error = [POWUtil checkForOKResponse:response andData:[@"@{\"Key\": \"Value\"}" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertNil(error);
}

- (void)testUTCOffsetWithTimeZone {
    // Asia/Calcutta UTC+05:30
    int timeZoneOffset = [POWUtil utcOffsetWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"IST"]];
    XCTAssertTrue(timeZoneOffset == 330, @"Incorrect timezone offset received.");
    // Asia/Tokyo UTC+09
    timeZoneOffset = [POWUtil utcOffsetWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    XCTAssertTrue(timeZoneOffset == 540, @"Incorrect timezone offset received.");
    // GMT
    timeZoneOffset = [POWUtil utcOffsetWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    XCTAssertTrue(timeZoneOffset == 0, @"Incorrect timezone offset received.");
    // Eastern Greenland Summer Time UTC±00
    timeZoneOffset = [POWUtil utcOffsetWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EGST"]];
    XCTAssertTrue(timeZoneOffset == 0, @"Incorrect timezone offset received.");
    // Atlantic Daylight Time UTC−03
    NSTimeZone *adtTz = [NSTimeZone timeZoneWithAbbreviation:@"ADT"];
    timeZoneOffset = [POWUtil utcOffsetWithTimeZone:adtTz];
    int adtOffset = -240 + ([adtTz isDaylightSavingTime] ? 60 : 0);
    XCTAssertTrue(timeZoneOffset == adtOffset, @"Incorrect timezone offset received.");
}

#pragma mark - NSString extension

- (void)testUrlEncode {
    // Case 1: Valid strings
    NSString * result = [@"a x" urlEncode];
    XCTAssertTrue([result isEqualToString:@"a%20x"], @"invalid urlencoding");
    
    result = [@"a+x" urlEncode];
    XCTAssertTrue([result isEqualToString:@"a%2Bx"], @"invalid urlencoding");
    
    result = [@"3::4::5" urlEncode];
    XCTAssertTrue([result isEqualToString:@"3%3A%3A4%3A%3A5"], @"invalid urlencoding");

    // Case 2: nil string
    result = nil;
    result = [result urlEncode];
    XCTAssertNil(result, @"invalid urlencoding");
    
    // Case 3: Empty string
    result = [@"" urlEncode];
    XCTAssertTrue([result isEqualToString:@""], @"invalid urlencoding");
}

- (void)testHashUsingSHA1 {
    // Case 1: Valid strings
    NSString *result = [@"A15C3149-98F4-9C01-655F-44DB7DAED175" hashUsingSHA1];
    XCTAssertTrue([result isEqualToString:@"39b54fcfa7a4f15095a18c3ff092251a035a8868"], @"invalid SHA1 hash generation.");
    
    // Case 2: nil string
    result = nil;
    result = [result hashUsingSHA1];
    XCTAssertNil(result, @"invalid SHA1 hash generation.");
    
    // Case 3: Empty string
    result = [@"" hashUsingSHA1];
    XCTAssertTrue([result isEqualToString:@""], @"invalid SHA1 hash generation.");
}

- (void)testHashUsingMD5 {
    // Case 1: Valid strings
    NSString *result = [@"A15C3149-98F4-9C01-655F-44DB7DAED175" hashUsingMD5];
    XCTAssertTrue([result isEqualToString:@"cafdf653a2561a8e3d9fa50d10116479"], @"invalid MD5 hash generation.");
    
    // Case 2: nil string
    result = nil;
    result = [result hashUsingMD5];
    XCTAssertNil(result, @"invalid MD5 hash generation.");
    
    // Case 3: Empty string
    result = [@"" hashUsingMD5];
    XCTAssertTrue([result isEqualToString:@""], @"invalid MD5 hash generation.");
}

- (void)testStringFromObject {
    // Case 1: Array
    NSArray *array = @[ @"Val1", @"Val2", @"Val3"];
    NSString *arrayString = [NSString stringFromObject:array];
    XCTAssertTrue([arrayString isEqualToString:@"[\n  \"Val1\",\n  \"Val2\",\n  \"Val3\"\n]"], @"Incorrect string generated from object.");
    
    // Case 2: Simple dictionary
    NSDictionary *dict = @{ @"Key1": @[ @"Val11", @"Val12"]};
    NSString *expectedDictString = @"{\n  \"Key1\" : [\n    \"Val11\",\n    \"Val12\"\n  ]\n}";
    NSString *dictString = [NSString stringFromObject:dict];
    XCTAssertTrue([dictString isEqualToString:expectedDictString], @"Incorrect string generated from object.");
    
    // Case 3: Dictionary with values of NSString and NSNumber data
    dict = @{@"Key2": @"Val21", @"Key3": @31};
    expectedDictString = @"{\n  \"Key2\" : \"Val21\",\n  \"Key3\" : 31\n}";
    dictString = [NSString stringFromObject:dict];
    XCTAssertTrue([dictString isEqualToString:expectedDictString], @"Incorrect string generated from object.");
    
    // Case 4: Complex dictionary
    dict = @{@"Key1": @[ @"Val11", @"Val12"], @"Key2": @"Val21", @"Key3": @31};
    expectedDictString = @"{\n  \"Key2\" : \"Val21\",\n  \"Key1\" : [\n    \"Val11\",\n    \"Val12\"\n  ],\n  \"Key3\" : 31\n}";
    dictString = [NSString stringFromObject:dict];
    XCTAssertTrue([dictString isEqualToString:expectedDictString], @"Incorrect string generated from object.");
    
    // Case 5: Nil dictionary
    dictString = [NSString stringFromObject:nil];
    XCTAssertNil(dictString, @"Incorrect string generated from object.");
}

- (void)testStringFromGender {
    // Case 1: Correct gender values
    NSString *genderStr = [NSString StringFromGender:POWGenderMale];
    XCTAssertEqualObjects(genderStr, @"M");
    genderStr = [NSString StringFromGender:POWGenderFemale];
    XCTAssertEqualObjects(genderStr, @"F");
    genderStr = [NSString StringFromGender:POWGenderOther];
    XCTAssertEqualObjects(genderStr, @"O");
    
    // Case 2: Invalid Gender value
    genderStr = [NSString StringFromGender:5];
    XCTAssertNil(genderStr);
}

#pragma mark - NSDictionary

- (void)testUrlQueryString {
    // Case 1: Valid dictionary without special characters
    NSDictionary *paramsDict = @{ @"Key1": @"Value1", @"Key2": @23 };
    NSString *queryString = [paramsDict urlQueryStringWithEncoding:YES];
    NSString *expectedString = @"Key2=23&Key1=Value1";
    XCTAssertEqualObjects(queryString, expectedString);
    
    // Case 2: Valid dictionary with special characters
    paramsDict = @{ @"Key1": @"Value1/67&123", @"Key2": @23 };
    queryString = [paramsDict urlQueryStringWithEncoding:YES];
    expectedString = @"Key2=23&Key1=Value1%2F67%26123";
    XCTAssertEqualObjects(queryString, expectedString);
    
    // Case 3: Dictionary with empty characters
    paramsDict = @{ @"Key1": @"", @"Key2": @"" };
    queryString = [paramsDict urlQueryStringWithEncoding:YES];
    expectedString = @"Key2=&Key1=";
    XCTAssertEqualObjects(queryString, expectedString);
    
    // Case 4: Nil dictionary
    paramsDict = nil;
    queryString = [paramsDict urlQueryStringWithEncoding:YES];
    XCTAssertNil(queryString);
}

#pragma mark - NSMutableDictionary

- (void)testSetObjectSafely {
    // Case 1: Valid objects
    // Valid dict
    NSDictionary *valueDict = @{ @"Key1": @1 };
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObjectSafely:valueDict forKey:@"ValidDict"];
    XCTAssertEqualObjects(dict[@"ValidDict"], valueDict);
    
    // Valid array
    NSArray *valueArray = @[@"Value1", @"Value2"];
    [dict setObjectSafely:valueArray forKey:@"ValidArray"];
    XCTAssertEqualObjects(dict[@"ValidArray"], valueArray);
    
    // Valid string
    NSString *valueString = @"Value3";
    [dict setObjectSafely:valueString forKey:@"ValidString"];
    XCTAssertEqualObjects(dict[@"ValidString"], valueString);
    
    // Case 2: Empty objects
    // Empty dict
    valueDict = @{};
    [dict setObjectSafely:valueDict forKey:@"EmptyDict"];
    XCTAssertNil(dict[@"EmptyDict"]);
    
    // Valid array
    valueArray = @[];
    [dict setObjectSafely:valueArray forKey:@"EmptyArray"];
    XCTAssertNil(dict[@"EmptyArray"]);
    
    // Valid string
    valueString = @"";
    [dict setObjectSafely:valueString forKey:@"EmptyString"];
    XCTAssertNil(dict[@"EmptyString"]);
    
    // Case 3: Nil objects
    // Nil dict
    [dict setObjectSafely:nil forKey:@"NilObj"];
    XCTAssertNil(dict[@"NilObj"]);
}

@end
