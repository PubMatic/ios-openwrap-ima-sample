/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWUtil.h"
#import <CommonCrypto/CommonDigest.h>

NSString * const kPOWErrorDomain = @"OpenWrapError";

@implementation POWUtil

// This method validates NSURLResponse.
+ (NSError*)checkForOKResponse:(NSURLResponse*)response
                      andData:(NSData *)data{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSError *error = nil;
    
    // Check the status code from response.
    if (httpResponse.statusCode != 200){
        
        // Status code is other than 200
        NSString *errMsg = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        if (data) {
            errMsg = [errMsg stringByAppendingFormat:@", %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
        
        error = [POWUtil errorWithCode:httpResponse.statusCode description:errMsg];
    }
    return error;
}

// This method returns NSError with error code as POWErrorCode and given description.
+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
    NSDictionary *userInfo = nil;
    NSString *errorMessage = [NSString stringWithFormat:@"(%ld) : %@", (long)code, description];
    userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(errorMessage, nil)};
    return [NSError errorWithDomain:kPOWErrorDomain code:code userInfo:userInfo];
}

// Method for getting current TimeZone offset in minutes
+ (int)utcOffsetWithTimeZone:(NSTimeZone *)timezone {
    // Local time as the number +/- of minutes from UTC
    int timezoneOffset = ([timezone secondsFromGMT] / 60.0);
    return timezoneOffset;
}

@end


/**
 Extension of NSString class to perform various string operations and conversions.
 */
@implementation NSString (Addition)

- (NSString *)urlEncode {
    // Reusable character set as it is expensive to create new one each time
    static NSMutableCharacterSet *charSet = nil;
    if (!charSet) {
        charSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [charSet removeCharactersInString:@"!*'();:@&=+$,/?%#[]<>"];
    }
    NSString *output = [self stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    return output;
}

// Method to hash the string using SHA1
- (NSString *)hashUsingSHA1 {
    if (self.length > 0) {
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(data.bytes, (uint)data.length, digest);
        NSMutableString *output =
        [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
        return [NSString stringWithString:output];
    }
    return self;
}

// Method to hash the string using MD5
- (NSString *)hashUsingMD5 {
    if (self.length > 0) {
        const char *cStr = self.UTF8String;
        unsigned char digest[16];
        CC_MD5(cStr, (uint)strlen(cStr), digest);
        NSMutableString *output =
        [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
        return [NSString stringWithString:output];
    }
    return self;
}

// Method to get stringified object
+ (NSString *)stringFromObject:(id)object {
    NSError *error = nil;
    
    @try {
        // Get object as NSData to convert it into string.
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (data.length > 0) {
            // Convert NSData into string
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    } @catch (NSException *exception) {
    }
    return nil;
}

// Method to get stringified gender
+ (NSString *)StringFromGender:(POWGender)gender {
    switch (gender){
        case 1:
            // Gender - Other
            return @"O";
        case 2:
            // Gender - Male
            return @"M";
        case 3:
            // Gender - Female
            return @"F";
        default:
            // Invalid value
            return nil;
    }
}

@end


/**
 Extension of NSDictionary class to perform various dictionary operations and conversions.
 */
@implementation NSDictionary (Addition)

// Method to convert the dictionary values into query parameters of URL string.
- (NSString *)urlQueryStringWithEncoding:(BOOL)enableEncode {
    NSMutableArray *queryComponents = [NSMutableArray arrayWithCapacity:self.allKeys.count];
    if (self.allKeys.count) {
        for (NSString *key in self.allKeys) {
            // Create array of key=val pairs
            id value = [self valueForKey:key];
            if (enableEncode && [value isKindOfClass:[NSString class]]) {
                // Encode all the string values as they may contain special characters.
                value = [(NSString *)value urlEncode];
            }
            [queryComponents addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }
    // Join the key=val pairs in a string using '&' to return
    return [queryComponents componentsJoinedByString:@"&"];
}
@end


/**
 Extension of NSMutableDictionary class to perform various dictionary operations and conversions.
 */
@implementation NSMutableDictionary (SafeMutableDictionary)

// Method to save the objects safely into a dictionary
- (void)setObjectSafely:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject != nil &&
        !(([anObject isKindOfClass:[NSArray class]] && [anObject count] == 0) ||
          ([anObject isKindOfClass:[NSString class]] && ((NSString *)anObject).length == 0) ||
          ([anObject isKindOfClass:[NSDictionary class]] && ((NSDictionary *)anObject).count == 0))) {
        
        // Object is not empty, save it into dictionary.
              self[aKey] = anObject;
    }
}

@end
