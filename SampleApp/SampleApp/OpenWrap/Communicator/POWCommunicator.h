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

@class POWCommunicator;

/*!
 Protocol to notify communicator success/failure events.
 */
@protocol POWCommunicatorDelegate <NSObject>

/**
 *  @abstract Delegate method to notify about communicator sucess
 *  @param communicator Reference of the communicator
 *  @param response POWAdResponse object
 */
- (void)communicator:(POWCommunicator *)communicator didReceiveAdResponse:(POWAdResponse *)response;

/**
 *  @abstract Delegate method to notify about communicator failure
 *  @param communicator Reference of the communicator
 *  @param error Error for failure
 */
- (void)communicator:(POWCommunicator *)communicator didFailWithError:(NSError *)error;

@end

/*!
 This class is the bridge between ad loader and network handler.
 It sends the request to POWNetwork handler, receives raw response from POWNetwork, parses using POWResponseParser and hands over parsed response to POWCommunicatorDelegate.
 */
@interface POWCommunicator : NSObject

/**
 *  @abstract Delegate to which Communicator events will be notified.
 */
@property (nonatomic, weak) id<POWCommunicatorDelegate> delegate;

/**
 *  @abstract Method to initialize the communicator
 *  @param request POWAdRequest object
 */
- (instancetype)initWithRequest:(POWAdRequest *)request;

/**
 *  @abstract Method to request ad from OpenWrap server.
 */
- (void)requestAd;

@end
