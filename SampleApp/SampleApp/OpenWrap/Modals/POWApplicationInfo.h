/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Type for BOOL
typedef NSInteger POWBOOL;

/// Bool value YES
extern POWBOOL const POWBOOLYes;
/// Bool value NO
extern POWBOOL const POWBOOLNo;

/*!
  Provides setters to pass application information, Like store URL, application domain, categories, ...etc. It is very important to provide transparency for buyers of your app inventory.
 */
@interface POWApplicationInfo : NSObject

/**
 *  @abstract Exchange-specific app ID
 */
@property(nonatomic, readonly) NSString *appId;

/**
 *  @abstract App name
 */
@property(nonatomic, readonly) NSString *name;

/**
 *  @abstract Indicates the domain of the mobile application (e.g. “mygame.foo.com”)
 */
@property(nonatomic, strong) NSString *domain;

/**
 *  @abstract Valid URL string of the application on App store
 *  @discussion It is mandatory to pass a valid storeURL, containing the itunes id of your app, It is very important for platform identification.
 *  Example : https://itunes.apple.com/us/app/id1175273098?mt=8
 */
@property(nonatomic, strong) NSString *storeURL;

/**
 *  @abstract Comma separated list of IAB categories for the application. e.g. "IAB-1, IAB-2"
 */
@property(nonatomic, strong) NSString *categories;

/**
 *  @abstract Indicates whether the mobile application is a paid version or not.
 */
@property(nonatomic, assign) POWBOOL paid;

@end

NS_ASSUME_NONNULL_END
