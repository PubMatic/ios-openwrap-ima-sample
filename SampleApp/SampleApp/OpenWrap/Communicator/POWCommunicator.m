/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "POWCommunicator.h"
#import "POWUtil.h"

@interface POWCommunicator()
@property (nonatomic, strong) POWAdRequest *request;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@end

@implementation POWCommunicator

- (instancetype)initWithRequest:(POWAdRequest *)request {
    
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

- (void)dealloc {
    _request = nil;
    if (_sessionTask) {
        [_sessionTask cancel];
        _sessionTask = nil;
    }
}

#pragma mark - Public APIs

- (void)requestAd {
    NSURLRequest *urlRequest = [self.request urlRequest];
    if (urlRequest != nil) {
        self.sessionTask = [self performRequest:urlRequest];
    } else {
        // urlRequest is nil, so give failure callback to communicator delegate with invalid request error.
        NSError *error = [POWUtil errorWithCode:NSURLErrorBadURL description:@"OpenWrap failed to prepare this request."];
        [self.delegate communicator:self didFailWithError:error];
    }
}

#pragma mark - Network calls handling

- (NSURLSessionTask *)performRequest:(NSURLRequest *)request {
    NSURLSession *session = [NSURLSession sharedSession];
    
     __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (error) {
            // Error is received from network handler, so pass it as is to communicator delegate.
            [self.delegate communicator:self didFailWithError:error];
            return;
        }
        // Response is received, so validate it.
        NSError *validationError = [POWUtil checkForOKResponse:response andData:data];
        if (validationError == nil) {
             // Response is valid so feed it parser for parsing.
            NSError *error = nil;
            POWAdResponse *response = [self parseResponse:data error:&error];
            if (response != nil) {
                [self.delegate communicator:self didReceiveAdResponse:response];
            } else {
                [self.delegate communicator:self didFailWithError:validationError];
            }
        }else{
            // Error is received while validating the response, so pass it as is to communicator delegate.
            [self.delegate communicator:self didFailWithError:validationError];
        }
    }];
    [task resume];
    return task;
}

#pragma mark - Parsing

- (POWAdResponse *)parseResponse:(NSData *)response error:(NSError **)error {
    @try {
        
        // Received response. Start parsing.
        NSDictionary *jsonResponse =
        [NSJSONSerialization JSONObjectWithData:response
                                        options:NSJSONReadingMutableContainers |
         NSJSONReadingAllowFragments
                                          error:error];
        
        if (jsonResponse != nil) {
            // Parsing succeeded. Notify delegate with success callabck and parsed object.
            return [[POWAdResponse alloc] initWithDictionary:jsonResponse];
        }
        
    } @catch (NSException *exception) {
        // Parsing exception received. Create an error object with parsing error.
        NSString *responseString = [[NSString alloc] initWithData:response
                                                         encoding:NSUTF8StringEncoding];
        NSString *errorMsg = [NSString stringWithFormat: @"Exception occured while parsing ad response %@\nReason - %@", responseString, exception.reason];
        *error = [POWUtil errorWithCode:NSURLErrorCannotParseResponse description:errorMsg];
    }

    return nil;
}

@end
