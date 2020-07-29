/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWAdsLoader.h"
#import "POWCommunicator.h"

@interface POWAdsLoader() <POWCommunicatorDelegate>
@property (nonatomic, strong) POWCommunicator *communicator;
@property (nonatomic, strong) POWAdRequest *request;
@end

@implementation POWAdsLoader

- (void)dealloc {
    _communicator = nil;
}

#pragma mark - Public APIs

- (void)requestAdsWithRequest:(POWAdRequest *)request {
    
    _request = request;
    _communicator = [[POWCommunicator alloc] initWithRequest:_request];
    _communicator.delegate = self;
    [_communicator requestAd];
}

#pragma mark - POWCommunicatorDelegate

- (void)communicator:(POWCommunicator *)communicator didReceiveAdResponse:(POWAdResponse *)response {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.delegate adsLoader:self didLoadAd:response];
    });
}

- (void)communicator:(POWCommunicator *)communicator didFailWithError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.delegate adsLoader:self didFailWithError:error];
    });
}

@end
