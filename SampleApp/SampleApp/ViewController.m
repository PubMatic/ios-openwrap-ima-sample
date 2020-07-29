/*
* Copyright 2006-2020, PubMatic Inc.
*
* Licensed under the PubMatic License Agreement. All rights reserved.
*
* https://github.com/PubMatic/ios-openwrap-ima-sample/blob/master/LICENSE
*/

#import "ViewController.h"
#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>
#import <AVFoundation/AVFoundation.h>
#import "POWConfiguration.h"
#import "POWAdsLoader.h"

// The content URL to play.
#define TEST_APP_CONTENT_URL @"https://storage.googleapis.com/gvabox/media/samples/stock.mp4"

// Ad tag url for IMA
#define IMA_AD_TAG_URL @"https://pubads.g.doubleclick.net/gampad/live/ads?iu=%@&description_url=http://pubmatic.com/&tfcd=0&npa=0&sz=%dx%d&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s"

// DFP Ad Unit ID
#define DFP_AD_UNIT_ID     @"/15671365/pm_ott_video"


@interface ViewController () <IMAAdsLoaderDelegate, IMAAdsManagerDelegate, POWAdsLoaderDelegate>

// Content video player.
@property(nonatomic, strong) AVPlayer *contentPlayer;

// Play button.
@property(nonatomic, weak) IBOutlet UIButton *playButton;

// UIView in which we will render our AVPlayer for content.
@property(nonatomic, weak) IBOutlet UIView *videoView;

// Entry point for the IMA SDK. Used to make ad requests.
@property(nonatomic, strong) IMAAdsLoader *imaAdsLoader;

// Playhead used by the IMA SDK to track content video progress and insert mid-rolls.
@property(nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;

// Main point of interaction with the IMA SDK.
@property (nonatomic, strong) IMAAdsManager *adsManager;

// Point of interaction with OpenWrap. It is responsible to request ad to OpenWrap and pass on the response to ViewController.
@property (nonatomic, strong) POWAdsLoader *openWrapAdsLoader;

// Ad size
@property (nonatomic, assign) CGSize adSize;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup UI components
    self.playButton.layer.zPosition = MAXFLOAT;
    
    // Setup IMA's ad loader
    [self setupAdsLoader];
    
    //  Setup main content player.
    [self setUpContentPlayer];
}

- (void)dealloc {
    self.imaAdsLoader = nil;
    self.openWrapAdsLoader = nil;
}

#pragma mark - Supporting methods

/*
 This application demonstrates pre-roll ad.
 Request ad from OpenWrap on play button click.
 */
- (IBAction)playButtonClicked:(id)sender {

    // Set application info
    POWApplicationInfo *appInfo = [POWApplicationInfo new];
    // Set app store URL
    appInfo.storeURL = @"https://itunes.apple.com/app/id378458261";
    [POWConfiguration sharedConfig].appInfo = appInfo;
    
    // Created ad request with OpenWrap Publisher ID, Profile ID and ad size.
    self.adSize = CGSizeMake(300, 250);
    POWAdRequest *adRequest = [[POWAdRequest alloc] initWithPublisherId:@"156276"
                                                              profileId:@2486
                                                               adUnitId:DFP_AD_UNIT_ID
                                                                andSize:self.adSize];

    // Create Ad Loader
    self.openWrapAdsLoader = [POWAdsLoader new];
    
    // Set Ad Loader delegate
    self.openWrapAdsLoader.delegate = self;
    
    // Request Ad Load to load ad
    [self.openWrapAdsLoader requestAdsWithRequest:adRequest];
    
    // Hide the play button to avoid multiple clicks
    self.playButton.hidden = YES;
}

// Method to get request url for IMA SDK
- (NSString *)imaAdTagUrl {
    return [NSString stringWithFormat:IMA_AD_TAG_URL, DFP_AD_UNIT_ID, (int)self.adSize.width, (int)self.adSize.height];
}

#pragma mark - POWAdsLoaderDelegate

- (void)adsLoader:(POWAdsLoader *)loader didLoadAd:(POWAdResponse *)adResponse {
    NSLog(@"Successfully received response from OpenWrap. Response: %@", adResponse.targettingInfo);
    // Get the targetting info as a query parameter string for a url
    NSString *customParam = [adResponse.targettingInfo urlQueryStringWithEncoding:NO];
    
    // Encode OpenWrap bid targetting info string and append to cust_params
    NSString *updatedAdTagURL = [NSString stringWithFormat:@"%@&cust_params=%@", [self imaAdTagUrl], [customParam urlEncode]];
    
    // Request ad from GAM
    [self requestAds:updatedAdTagURL];
}

- (void)adsLoader:(POWAdsLoader *)loader didFailWithError:(NSError *)error {
    NSLog(@"Failed to receive response from OpenWrap: %@", error);
    
    // OpenWrap failed to respond, request IMA SDK with default url.
    [self requestAds:[self imaAdTagUrl]];
}

#pragma mark - Content Player Setup

- (void)setUpContentPlayer {
    // Load AVPlayer with path to our content.
    NSURL *contentURL = [NSURL URLWithString:TEST_APP_CONTENT_URL];
    self.contentPlayer = [AVPlayer playerWithURL:contentURL];
    
    // Create a player layer for the player.
    AVPlayerLayer *playerLayer =
    [AVPlayerLayer playerLayerWithPlayer:self.contentPlayer];
    
    // Size, position, and display the AVPlayer.
    playerLayer.frame = self.videoView.layer.bounds;
    [self.videoView.layer addSublayer:playerLayer];
    
    // Set up our content playhead and contentComplete callback.
    self.contentPlayhead =
    [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.contentPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.contentPlayer.currentItem];
}

#pragma mark - IMA SDK Setup

// Setup IMA SDK's ad loader
- (void)setupAdsLoader {
    // Create IMA's ad loader
    self.imaAdsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    
    // Set delegate to IMA ad loader
    self.imaAdsLoader.delegate = self;
}

// Request Ad from IMA SDK
- (void)requestAds:(NSString *)adTagURL {
    // Create an ad display container for ad rendering.
    IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.videoView
                                        companionSlots:nil];
    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request =
    [[IMAAdsRequest alloc] initWithAdTagUrl:adTagURL
                         adDisplayContainer:adDisplayContainer
                            contentPlayhead:self.contentPlayhead
                                userContext:nil];
    
    // Request ad from IMA ad loader
    [self.imaAdsLoader requestAdsWithRequest:request];
}

#pragma mark - NSNotification handling

- (void)contentDidFinishPlaying:(NSNotification *)notification {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if (notification.object == self.contentPlayer.currentItem) {
        [self.imaAdsLoader contentComplete];
    }
}

#pragma mark - AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    
    // Create ads rendering settings to tell the IMA SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = self;
    
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"Ads Manager failed to load ads with error: %@", adErrorData.adError.message);
    
    // Ad loading failed, so continue playing the main content.
    [self.contentPlayer play];
}

#pragma mark - AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    // When the SDK notified us that ads have been loaded, play them.
    if (event.type == kIMAAdEvent_LOADED) {
        [adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the content.
    NSLog(@"Ads Manager failed with error: %@", error.message);
    [self.contentPlayer play];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The IMA SDK is going to play ads, so pause the content.
    [self.contentPlayer pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The IMA SDK is done playing ads (at least for now), so resume the content.
    [self.contentPlayer play];
}

@end
