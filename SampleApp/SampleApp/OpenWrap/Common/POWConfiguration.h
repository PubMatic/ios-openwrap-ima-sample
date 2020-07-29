/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>
#import "POWUserInfo.h"
#import "POWApplicationInfo.h"

#define SharedConfig [POWConfiguration sharedConfig]

/// Type for BOOL
typedef NSInteger POWBOOL;

/// Bool value YES
extern POWBOOL const POWBOOLYes;
/// Bool value NO
extern POWBOOL const POWBOOLNo;

/*!
 Linearity type.
 */
typedef NS_ENUM(NSInteger, POWLinearityType) {
    
    /// Linear. Default type
    POWLinearityTypeLinear = 1,
    
    // Non-linear
    POWLinearityTypeNonLinear
};

/// Advertising id hashing
typedef NS_ENUM(NSInteger, POWHashType) {
    
    /// No hashing applied
    POWHashTypeRaw = 1,
    /// SHA1 hashing will be applied
    POWHashTypeSHA1,
    /// MD5 hashing will be applied
    POWHashTypeMD5
};

/*!
 Provides global configurations for the OpenWrap module, e.g. location access, CCPA, GDPR, etc.
 These configurations are globally applicable for OpenWrap module; you don't have to set these for every ad request.
 */
@interface POWConfiguration : NSObject

/**
 *  @abstract Object having user information, such as birth year, gender, region, etc, for more relevant ads.
 *  @see POWUserInfo
 */
@property (nonatomic, strong) POWUserInfo *userInfo;

/**
 * @abstract Object having application information, which contains various attributes about app, such as application category, store URL, domain, etc, for more relevant ads.
 * @see POWApplicationInfo
 */
@property (nonatomic, strong) POWApplicationInfo *appInfo;

/**
 *  @abstract Enable GDPR compliance, it indicates whether or not the ad request is GDPR(General Data Protection Regulation) compliant.
 *  @note By default, this parameter is omitted in the ad request.
 *  @see POWBOOL
 */
@property (nonatomic, assign, getter = isEnabledGDPR) POWBOOL enableGDPR;

/**
 *  @abstract Set GDPR consent string to convey user consent when GDPR regulations are in effect. A valid Base64 encoded consent string as per https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework.
 *  @discussion The user consent string is optional, but highly recommended if the request is subject to GDPR regulations (i.e. gdpr = YES). The default sense of consent under GDPR is “opt-out” and as such, an omitted consent string in a request subject to GDPR would be interpreted as equivalent to the user fully opting out of all defined purposes for data use by all parties.
 */
@property (nonatomic, strong) NSString *GDPRConsent;

/**
 *  @abstract CCPA compliant string, it helps publisher toward compliance with the California Consumer Privacy Act (CCPA).
 *  @discussion For more details refer https://www.iab.com/guidelines/ccpa-framework/
 *  Make sure that the string value you use is compliant with the IAB Specification, refer https://iabtechlab.com/wp-content/uploads/2019/11/U.S.-Privacy-String-v1.0-IAB-Tech-Lab.pdf
 *
 *  If this is not set, it looks for app's NSUserDefault with key 'IABUSPrivacy_String'
 *  If CCPA is applied through both options, it will be honourd by only API property.
 *  If both are not set then CCPA parameter is omitted from an ad request.
 */
@property (nonatomic, strong) NSString *CCPA;

/**
 *  @abstract Linearity type
 *  @see POWLinearityType
 */
@property (nonatomic, assign) POWLinearityType linearity;

/**
 *  @abstract Hash type to be applied on the advertising id befire sending it in bid request.
 *  @see POWHashType
 */
@property (nonatomic, assign) POWHashType hashTypeForAdvertisingId;

/**
 *  @abstract Dictionary of key-value pairs to be passed in the OpenWrap request.
 */
@property (nonatomic, strong) NSDictionary *customKeyValues;

/**
 *  @abstract Method to get the shared instance of OpenWrap module configuration.
 *  @return Shared instance of POWConfiguration
 */
+ (POWConfiguration *)sharedConfig;

@end
