/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 This is a modal class for OpenWrap ad request. Publisher should create instance of this class and set the applicable parameters before passing it to ad loader.
 */
@interface POWAdRequest : NSObject

/**
 *  @abstract Ad unit Id for OpenWrap
 *  @discussion Value of the ad unit will be used in both OpenWrap and DFP requests.
 */
@property (nonatomic, readonly) NSString *_Nonnull adUnitId;

/**
 *  @abstract Size of the video ad
 *  @discussion Value of the size will be used in both OpenWrap and DFP requests.
 */
@property (nonatomic, readonly) CGSize size;

/**
 *  @abstract Version of the OpenWrap profile
 *  @warning This parameter should not be set while going live as it is onlyrequred by profiles in draft/staging state.
 */
@property (nonatomic, strong) NSNumber *_Nullable versionId;

/**
 *  @abstract Enable debug on OpenWrap ad request
 *  @warning This parameter should be used only in debug mode.
 */
@property (nonatomic, assign) BOOL enableDebug;

/*!
 *  @abstract Sets custom parameters in the form of a dictionary, to set multiple values against same key, use array.
 *  @discussion The dictionary should contain partner specific keywords in the format of { "<partner_name>": { "keywords": [ { "key" : "<key_name>", "value": <value>}, ... ] } }
 *  @warning Only use string or array of string as values
 *
 *  Exmaple :
 *  bidderCustomParams =
 *  {
 *      "pubmatic": {
 *          "keywords": [
 *              {
 *                  "key": "dctr",
 *                  "value": ["val1", "val2"]
 *              }
 *          ]
 *       },
 *       "appnexus": {
 *          "keywords": [
 *              {
 *                  "key": "key1",
 *                  "value": ["val1"]
 *              },
 *              {
 *                  "key": "key2",
 *                  "value": ["val2"]
 *              }
 *          ]
 *       }
 * }
 */
@property(nonatomic, strong) NSDictionary *_Nullable bidderCustomParams;

/**
 *  @abstract Sets the network timeout (in seconds) for making an Ad request.
 *  Default value is 5 seconds,
 *  Different value can be set using this API, given that value is greater/equal to 1.0
 */
@property (nonatomic, assign) NSTimeInterval networkTimeout;

/**
 *  @abstract Initializer for POWAdRequest
 *  @param pubId Publisher ID
 *  @param profileId Profile ID
 *  @param adUnitId Ad unit Id
 *  @param size Size of the video ad
 *  @return Instance of POWAdRequest
 */
- (instancetype _Nullable)initWithPublisherId:(NSString * _Nonnull)pubId
                                    profileId:(NSNumber *_Nonnull)profileId
                                     adUnitId:(NSString *_Nonnull)adUnitId
                                      andSize:(CGSize)size;

/**
 *  @abstract Method to get the NSURL request from POWAdRequest
 *  @return Object of NSURLRequest
 */
- (NSURLRequest *_Nullable)urlRequest;

@end
