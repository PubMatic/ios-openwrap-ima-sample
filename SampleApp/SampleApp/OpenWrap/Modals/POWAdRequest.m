/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWAdRequest.h"
#import "POWUtil.h"
#import "POWConfiguration.h"
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/ASIdentifierManager.h>

#define POW_REQUEST_ENDPOINT            @"https://ow.pubmatic.com/openrtb/2.5/video"
#define POW_DEFAULT_REQUEST_TIMEOUT     5.0

// OpenWrap Keys
NSString *const kPOWPubId = @"pubId";
NSString *const kPOWProfileId = @"profId";
NSString *const kPOWAdServer = @"adserver";
NSString *const kPOWPlatform = @"pwtplt";
NSString *const kPOWMime = @"pwtmime";
NSString *const kPOWAdUnit = @"pwtm_iu";
NSString *const kPOWSize = @"pwtm_sz";
NSString *const kPOWUrl = @"pwtm_url";
NSString *const kPOWFormat = @"f";
NSString *const kPOWApp = @"pwtapp";
NSString *const kPOWVersionId = @"pwtv";
NSString *const kPOWEnableDebug = @"pwtvc";
NSString *const kPOWBidderParams = @"pwtbidrprm";
NSString *const kPOWLinearity = @"pwtvlin";
NSString *const kPOWEnableGDPR = @"pwtgdpr";
NSString *const kPOWGDPRConsent = @"pwtcnst";
NSString *const kPOWCCPA = @"pwtccpa";

// Device Object
NSString *const kPOWLmt = @"pwtlmt";
NSString *const kPOWDnt = @"pwtdnt";
NSString *const kPOWJs = @"pwtjs";
NSString *const kPOWIFA = @"pwtifa";
NSString *const kPOWDpidSHA1 = @"pwtdpidsha1";
NSString *const kPOWDpidMD5 = @"pwtdpidmd5";
NSString *const kPOWUTCOffset = @"pwtuto";

// User Object
NSString *const kPOWGeoLat = @"pwtlat";
NSString *const kPOWGeoLon = @"pwtlon";
NSString *const kPOWGeoType = @"pwtgtype";
NSString *const kPOWCountry = @"pwtcntr";
NSString *const kPOWCity = @"pwtcity";
NSString *const kPOWMetro = @"pwtmet";
NSString *const kPOWZip = @"pwtzip";
NSString *const kPOWBirthYear = @"pwtyob";
NSString *const kPOWGender = @"pwtgender";

// App Object
NSString *const kPOWAppId = @"pwtappid";
NSString *const kPOWAppName = @"pwtappname";
NSString *const kPOWAppBundle = @"pwtappbdl";
NSString *const kPOWAppDomain = @"pwtappdom";
NSString *const kPOWAppStoreUrl = @"pwtappurl";
NSString *const kPOWAppCat = @"pwtappcat";
NSString *const kPOWAppPaid = @"pwtapppd";

@interface POWAdRequest()
@property (nonatomic, strong) NSString *pubId;
@property (nonatomic, strong) NSNumber *profileId;
@end

@implementation POWAdRequest

#pragma mark - Initializer

- (instancetype)initWithPublisherId:(NSString *)pubId
                          profileId:(NSNumber *)profileId
                           adUnitId:(NSString *)adUnitId
                            andSize:(CGSize)size {
    self = [super init];
    if (self) {
        _pubId = pubId;
        _profileId = profileId;
        _adUnitId = adUnitId;
        _size = size;
    }
    return self;
}

#pragma mark - Public APIs

// Method to create request
- (NSMutableURLRequest *)urlRequest {
    NSURL *url = [NSURL URLWithString:[self urlString]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.timeoutInterval = (_networkTimeout > 1.0) ? _networkTimeout : POW_DEFAULT_REQUEST_TIMEOUT;
    return urlRequest;
}

#pragma mark - Supporting Method

// Create device info object
- (NSDictionary *)deviceInfoObject {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // Check if user tracking is enabled.
    BOOL trackingEnabled = [ASIdentifierManager sharedManager].advertisingTrackingEnabled;
    
    // Save lmt dnt values.
    NSNumber *lmtEnabled = trackingEnabled ? @0 : @1;
    params[kPOWLmt] = lmtEnabled;
    params[kPOWDnt] = lmtEnabled;
    
    // Set advertising identifier if lmt is not enabled.
    if (trackingEnabled) {
        NSString *advertisingIdentifier = [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
        
        // Check hash type set and accordingly save the advertising identifier.
        if (SharedConfig.hashTypeForAdvertisingId == POWHashTypeSHA1) {
            // SHA1 has type is set, so hash the advertising identifier and save it.
            [params setObjectSafely:[advertisingIdentifier hashUsingSHA1] forKey:kPOWDpidSHA1];
        } else if (SharedConfig.hashTypeForAdvertisingId  == POWHashTypeMD5) {
            // MD5 has type is set, so hash the advertising identifier and save it.
            [params setObjectSafely:[advertisingIdentifier hashUsingMD5] forKey:kPOWDpidMD5];
        } else {
            // No hash type is set, so save the advertising identifier's raw value.
            [params setObjectSafely:advertisingIdentifier forKey:kPOWIFA];
        }
    }
    
    // Enable js
    params[kPOWJs] = @1;
    
    // Set UTC offset
    params[kPOWUTCOffset] = @([POWUtil utcOffsetWithTimeZone:[NSTimeZone systemTimeZone]]);
    
    return [NSDictionary dictionaryWithDictionary:params];
}

// Create user info object.
- (NSDictionary *)userInfoObject {
    NSMutableDictionary *params = [NSMutableDictionary new];
    POWUserInfo *userInfo = SharedConfig.userInfo;
    
    // Save user's location if provided by user.
    if (userInfo.location) {
        // Location is available
        params[kPOWGeoLat] = @(userInfo.location.coordinate.latitude);
        params[kPOWGeoLon] = @(userInfo.location.coordinate.longitude);
        
        // Location is user provided.
        POWLocSource locationSource = userInfo.locationSource > 0 ? userInfo.locationSource : POWLocSourceUserProvided;
        params[kPOWGeoType] = @(locationSource);
    }
    
    // Save country, city, metro, zip etc.
    [params setObjectSafely:userInfo.country forKey:kPOWCountry];
    [params setObjectSafely:userInfo.city forKey:kPOWCity];
    [params setObjectSafely:userInfo.metro forKey:kPOWMetro];
    [params setObjectSafely:userInfo.zip forKey:kPOWZip];
    
    // Get stringified value of gender and save it.
    [params setObjectSafely:[NSString StringFromGender:userInfo.gender] forKey:kPOWGender];
    
    // Save user's birth year is available
    if ([userInfo.birthYear integerValue]>0) {
        params[kPOWBirthYear] = userInfo.birthYear;
    }
    
    return [NSDictionary dictionaryWithDictionary:params];
}

// Create App info object
- (NSDictionary *)appInfoObject {
    NSMutableDictionary *params = [NSMutableDictionary new];
    POWApplicationInfo *appInfo = SharedConfig.appInfo;
    
    // Save app store url
    [params setObjectSafely:appInfo.storeURL forKey:kPOWUrl];
    [params setObjectSafely:appInfo.storeURL forKey:kPOWAppStoreUrl];
    
    // Save app id, bundle, name, domain values if provided by user.
    [params setObjectSafely:appInfo.appId forKey:kPOWAppId];
    [params setObjectSafely:appInfo.appId forKey:kPOWAppBundle];
    [params setObjectSafely:appInfo.name forKey:kPOWAppName];
    [params setObjectSafely:appInfo.domain forKey:kPOWAppDomain];
    
    // Save app categories if available
    [params setObjectSafely:appInfo.categories forKey:kPOWAppCat];
    
    // Save app paid value
    if (appInfo.paid != -1) {
        params[kPOWAppPaid] = @(appInfo.paid);
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

// Create bidder extension object
- (NSDictionary *)bidderExtension {
    if (self.bidderCustomParams.count == 0) {
        // Custom parameters are not available.
        return nil;
    }

    // Save bidder parameters dictionary against key pwtbidrprm.
    // e.g. {"pubmatic": {"keywords": [{ "key": "dctr", "value": ["val1", "val2"] }]}, "appnexus": {"keywords": [{ "key": "key1", "value": ["val1"] }, { "key": "key2", "value": ["val2"] }]}}
    // Stringify this formed object.
    NSString *bidderParam = [NSString stringFromObject:self.bidderCustomParams];
    
    // Save the bidderParam string in the dictionary
    NSDictionary *bidderExt = [NSDictionary dictionaryWithObjectsAndKeys:bidderParam, kPOWBidderParams, nil];
    return bidderExt;
}

// Method to add all the parameters in a dictionary
- (NSDictionary *)queryParametersDictionary {
    /*
     Create a dictionary with keys as parameter name in OpenWrap request and value as a string/number.
     Later, this disctionary will be converted into string and appended to the OpenWrap endpoint.
     */
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[kPOWPubId] = _pubId;
    params[kPOWProfileId] = _profileId;
    
    /*
     Possible values are:
     0 - All
     1 - video/mp4
     2 - application/x-shockwave-flash (VPAID - FLASH)
     3 - video/wmv
     4 - video/h264
     5 - video/webm
     6 - application/javascript (VPAID - JS)
     7 - video/ogg
     8 - video/flv
     */
    params[kPOWMime] = @"1";
    
    // Ad server is DFP
    params[kPOWAdServer] = @"DFP";
    
    // Video platform by default
    params[kPOWPlatform] = @"video";
    params[kPOWAdUnit] = _adUnitId;
    
    // Save the size as widthxheight e.g. 320x480
    params[kPOWSize] = [NSString stringWithFormat:@"%dx%d", (int)_size.width, (int)_size.height];
    params[kPOWFormat] = @"json";
    
    // Send app parameter to identify mobile in-app request
    params[kPOWApp] = @"1";
    
    // Set enable GDPR
    if (SharedConfig.enableGDPR != -1) {
        params[kPOWEnableGDPR] = @(SharedConfig.enableGDPR);
    }
    // Set GDPR string
    [params setObjectSafely:SharedConfig.GDPRConsent forKey:kPOWGDPRConsent];
    
    // Set CCPA
    [params setObjectSafely:SharedConfig.CCPA forKey:kPOWCCPA];
    
    // Add OpenWrap profile version Id only if available.
    [params setObjectSafely:_versionId forKey:kPOWVersionId];
    
    if (_enableDebug) {
        // Add enable debug flag for OpenWrap server request only if available.
        params[kPOWEnableDebug] = @1;
    }
    
    // Set Linearity
    params[kPOWLinearity] = @(SharedConfig.linearity);
    
    // Add device information parameters to params dictionary
    [params addEntriesFromDictionary:[self deviceInfoObject]];
    
    // Add user information parameters to params dictionary
    [params addEntriesFromDictionary:[self userInfoObject]];
    
    // Add app information parameters to params dictionary
    [params addEntriesFromDictionary:[self appInfoObject]];
    
    // Add bidder parameters
    [params addEntriesFromDictionary:[self bidderExtension]];
    
    // Add custom parameters to params dictionary
    NSDictionary *customParams = [POWConfiguration sharedConfig].customKeyValues;
    if (customParams.count > 0) {
        [params addEntriesFromDictionary:customParams];
    }
    
    return [NSDictionary dictionaryWithDictionary:params];
}

- (NSString *)urlString {
    // Get all the query parameters in a string
    NSString *queryParams = [[self queryParametersDictionary] urlQueryStringWithEncoding:YES];
    
    // Append the query parameters to OpenWrap endpoint
    return [NSString stringWithFormat:@"%@?%@", POW_REQUEST_ENDPOINT, queryParams];
}

@end
