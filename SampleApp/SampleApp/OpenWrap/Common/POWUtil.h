/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>
#import "POWConfiguration.h"

/*!
 This class provided various Util methods to OpenWrap module.
 */
@interface POWUtil : NSObject

/**
 *  @abstract This method validates NSURLResponse.
 *  @discussion It checks the HTTP status from response. In case of success, it returns nil, otherwise, generates respective error and returns that object.
 *  @param response HTTP response
 *  @param data Response data
 *  @return NSError Error object in case of failure.
 */
+ (NSError *)checkForOKResponse:(NSURLResponse*)response
                       andData:(NSData *)data;

/**
 *  @abstract This method returns NSError with error code as POWErrorCode and given description.
 *  @param code NSInterget
 *  @param description Error description
 *  @return NSError object
 */
+ (NSError *)errorWithCode:(NSInteger)code
               description:(NSString *)description;

/**
 *  @abstract Method to get the local time as the number +/- of minutes from UTC
 *  @param timezone Device tiimezone
 *  @return UTC offset value
 */
+ (int)utcOffsetWithTimeZone:(NSTimeZone *)timezone;

@end


/*!
 Extension of NSString class to perform various string operations and conversions.
 */
@interface NSString (Addition)

/**
 *  @abstract Method to URL encode given string url.
 *  @return Encoded URL as a string
 */
- (NSString *)urlEncode;

/**
 *  @abstract Method to hash the string using SHA1
 *  @return SHA1 hashed string
 */
- (NSString *)hashUsingSHA1;

/**
 *  @abstract Method to hash the string using MD5
 *  @return MD5 hashed string
 */
- (NSString *)hashUsingMD5;

/**
 *  @abstract Method to get stringifed object.
 *  @param object Object to be stringified
 *  @return Stringified object
 */
+ (NSString *)stringFromObject:(id)object;

/**
 *  @abstract Method to get string from gender
 *  @param gender Gender value to be stringified
 *  @see POWGender
 *  @return Stringified gender
 */
+ (NSString *)StringFromGender:(POWGender)gender;

@end


/*!
 Extension of NSDictionary class to perform various dictionary operations and conversions.
 */
@interface NSDictionary (Addition)

/**
 *  @abstract This method converts key-value pairs of dictionary into query string in format key1=val1&key2=val2
 *  @param enableEncode Enable encoding on values.
 *  @return Query string as NSString object
 */
- (NSString *)urlQueryStringWithEncoding:(BOOL)enableEncode;
@end


/*!
 Extension of NSMutableDictionary class to perform various dictionary operations and conversions.
 */
@interface NSMutableDictionary (SafeMutableDictionary)

/**
 *  @abstract Method to set the object in dictionary safely.
 *  @discussion nil objects, strings with 0 length, empty arrays will not be saved in the dictionary.
 *  @param anObject Object to be saved.
 *  @param aKey Dictionary key
 */
- (void)setObjectSafely:(id)anObject forKey:(id<NSCopying>)aKey;
@end
