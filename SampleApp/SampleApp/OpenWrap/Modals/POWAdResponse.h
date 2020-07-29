/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "POWUtil.h"

/*!
 This class holds the parsed response of OpenWrap.
 */
@interface POWAdResponse : NSObject

/**
 *  @abstract Targetting information as a dictionary.
 */
@property (nonatomic, readonly) NSDictionary *targettingInfo;

/**
 *  @abstract Initializer for POWAdResponse
 *  @param dictionary Parsed response in the form of  NSDictionary
 *  @return Instance of POWAdResponse
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
