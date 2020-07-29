/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// Gender to help deliver more relevant ads.
typedef NS_ENUM(NSInteger, POWGender) {
    
    /// Other gender
    POWGenderOther = 1,
    /// Gender male
    POWGenderMale,
    /// Gender female
    POWGenderFemale
};

/// Location source
typedef NS_ENUM(NSInteger, POWLocSource)  {
    
    /// Location is determined from GPS
    POWLocSourceGPS = 1,
    /// Location is determined from IP address
    POWLocSourceIPAddress,
    /// Location is provided by user
    POWLocSourceUserProvided
};

/**
 Provides setters to pass user information
 */

@interface POWUserInfo : NSObject

/**
 *  @abstract The year of birth in YYYY format.
 *  @discussion Example : birthYear = @1988;
 */
@property(nonatomic, strong) NSNumber *birthYear;

/**
 *  @abstract Sets user gender,
 *  @discussion Possible options are:
 *
 *  - POWGenderOther
 *  - POWGenderMale,
 *  - POWGenderFemale
 *
 *  @see POWGender
 */
@property(nonatomic, assign) POWGender gender;

/**
 *  @abstract Google metro code; similar to but not exactly Nielsen DMAs.
 *  @discussion e.g. For example, New York, NY is also known as 501. Los Angeles, CA, on the other hand has been assigned the number 803.
 */
@property(nonatomic, strong) NSString *metro;

/**
 *  @abstract The user's zip or postal code. This may be useful in delivering geographically relevant ads
 *  @discussion e.g 94063 for Redwood City, CA
 */
@property(nonatomic, strong) NSString *zip;

/**
 *  @abstract City of user
 *  @discussion e.g "Los Angeles"
 */
@property(nonatomic, strong) NSString *city;

/**
 *  @abstract Country code using ISO-3166-1-alpha-3.
 *  @discussion e.g for United States of America you can use 'USA'
 */
@property(nonatomic, strong) NSString *country;

/**
 *  @abstract User's location. It is useful in delivering geographically relevant ads.
 *  @discussion If your application is already accessing the device location, it is highly recommended to set the location coordinates inferred from the device GPS.
 */
@property (nonatomic, strong) CLLocation *location;

/**
 *  @abstract User's location source.
 *  @see POWLocSource
 */
@property (nonatomic, assign) POWLocSource locationSource;

@end

NS_ASSUME_NONNULL_END
