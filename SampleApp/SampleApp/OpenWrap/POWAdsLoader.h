/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>
#import "POWAdRequest.h"
#import "POWAdResponse.h"

NS_ASSUME_NONNULL_BEGIN

@class POWAdsLoader;

/*!
The ad loader delegate. It is used to inform theOpenWrap events back to the application.
*/
@protocol POWAdsLoaderDelegate <NSObject>

/**
 *  @abstract Delegate method to inform ad have been successfully loaded from the ad servers by the loader.
 *
 *  @param loader   the POWAdsLoader that received the loaded ad data
 *  @param adResponse Ad response
 */
- (void)adsLoader:(POWAdsLoader *)loader didLoadAd:(POWAdResponse *)adResponse;

/**
 *  @abstract Error reported by the ads loader when loading or requesting an ad fails.
 *  @param loader   The POWAdsLoader that received the loaded ad data
 *  @param error Error  for ad failure
 */
- (void)adsLoader:(POWAdsLoader *)loader didFailWithError:(NSError *)error;

@end

/*!
This class used to load video ad from OpenWrap server.
*/
@interface POWAdsLoader : NSObject

/**
 *  @abstract Delegate to which ad loader events will be notified.
 */
@property (nonatomic, weak) id<POWAdsLoaderDelegate> delegate;

/**
 *  @abstract Request ads from the OpenWrap ad server.
 *
 *  @param request the POWAdRequest.
 *  @see POWAdRequest
 */
- (void)requestAdsWithRequest:(POWAdRequest *)request;

@end

NS_ASSUME_NONNULL_END
