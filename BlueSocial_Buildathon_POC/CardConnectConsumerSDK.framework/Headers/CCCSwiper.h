/*

 Copyright 2017 iMobile3, LLC. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, is permitted provided that adherence to the following
 conditions is maintained. If you do not agree with these terms,
 please do not use, install, modify or redistribute this software.

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY IMOBILE3, LLC "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL IMOBILE3, LLC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>

@class CCCAccount;

@protocol CCCSwiperDelegate;

/**
 Values describing the connection state of the swiper.
 */
typedef NS_ENUM(NSInteger, CCCSwiperConnectionState)
{
    /** The swiper is not connected. */
    CCCSwiperConnectionStateDisconnected = 0,
    /** The swiper is attempting to connect. */
    CCCSwiperConnectionStateConnecting = 1,
    /** The swiper is connected. */
    CCCSwiperConnectionStateConnected = 2,
};

/**
 Values describing the battery status of the swiper.
 */
typedef NS_ENUM(NSInteger, CCCSwiperBatteryStatus)
{
    /** The swiper battery is low but can still process commands. */
    CCCSwiperBatteryStatusLow,
    /** The swiper battery is critical and wont process any commands. */
    CCCSwiperBatteryStatusCritical
};

/**
 CCCSwiper is a base class that defines a swiper controller. To use the swiper, please use CCCSwiperController. If the
 Library doesn't contain CCCSwiperController, this version does not support swiper integration.
 */
@interface CCCSwiper : NSObject
{
@protected
    CCCSwiperConnectionState _connectionState;
}

/**
 The delegate for the swiper callbacks.
 */
@property(nonatomic, weak) id<CCCSwiperDelegate> delegate;

/**
 The connection state of the swiper.
 */
@property(nonatomic, assign, readonly) CCCSwiperConnectionState connectionState;

/**
 The model of swiper being used.
 */
+ (NSString*)model;

/**
 Flag for setting or checking if debug logging is enabled.
 */
@property(nonatomic, getter = isDebugLoggingEnabled) BOOL debugLoggingEnabled;

/**
 Used to initialize CCCSwiper with a delegate.

 @param delegate A class that adheres to the CCCSwiperDelegate protocol.

 @return An instance of CCCSwiper.
 */
- (instancetype)initWithDelegate:(id<CCCSwiperDelegate>)delegate;

/**
 Used to initialize CCCSwiper with a delegate and set logging enabled.

 @param delegate A class that adheres to the CCCSwiperDelegate protocol.
 @param enabled A flag to set debugLoggingEnabled.

 @return An instance of CCCSwiper.
 */
- (instancetype)initWithDelegate:(id<CCCSwiperDelegate>)delegate loggingEnabled:(BOOL)enabled;

/**
 Indicates if an audio warning should be displayed.

 If returns TRUE, this swiper utilizes the audio jack for communication. An audio warning should be shown prior to
 initializing the swiper that indicates the user should remove any headphones and turn the volume to max.

 @return A flag for if an audio warning should be displayed.
 */
- (bool)shouldShowAudioWarning;

@end

/**
 A protocol that handles responses from CCCSwiper.
 */
@protocol CCCSwiperDelegate <NSObject>

@required

/**
 A required method notifying the delegate that CCCSwiper successfully generated a token and returns an account.

 Call completion to start the swiper again. If you presented a status indicator or disabled user interaction in
 [CCCSwiperDelegate swiperDidStartMSR:], dismiss the status indicator and re-enable user interaction at this point
 before calling completion.

 @param swiper An instance of CCCSwiper.
 @param account The account returned with the generated token for the card swipe.
 @param completion A completion block that can be called to restart the swiper.

 @see CCCAccount
 */
- (void)swiper:(CCCSwiper *)swiper didGenerateTokenWithAccount:(CCCAccount *)account completion:(void (^)())completion;

/**
 A required method notifying the delegate that CCCSwiper failed to swipe the card.

 Call completion to start the swiper again. If you presented a status indicator or disabled user interaction in
 [CCCSwiperDelegate swiperDidStartMSR:], dismiss the status indicator and re-enable user interaction at this point
 before calling completion.

 @param swiper An instance of CCCSwiper.
 @param error The error that occurred if available.
 @param completion Block that should be called to start the swiper again.
 */
- (void)swiper:(CCCSwiper *)swiper didFailWithError:(NSError *)error completion:(void (^)())completion;

@optional

/**
 Optional method notifying the delegate that CCCSwiper connection state has changed.

 @param state The new state of the swiper.

 @param swiper An instance of CCCSwiper.
 */
- (void)swiper:(CCCSwiper *)swiper connectionStateHasChanged:(CCCSwiperConnectionState)state;

/**
 Optional method notifying the delegate that the CCCSwiper battery is low or in critical state.

 @param swiper An instance of CCCSwiper.
 @param status The status of the swiper.
 */
- (void)swiper:(CCCSwiper *)swiper batteryLevelStatusHasChanged:(CCCSwiperBatteryStatus)status;

/**
 Optional method notifying the delegate that CCCSwiper started an MSR transaction.

 Use this callback to display a status indicator and disable user interaction while the services are called.

 @param swiper An instance of CCCSwiper.
 */
- (void)swiperDidStartMSR:(CCCSwiper *)swiper;

@end
