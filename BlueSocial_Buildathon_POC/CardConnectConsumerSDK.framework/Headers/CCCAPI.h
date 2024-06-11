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
#import <PassKit/PassKit.h>

#import "CCCCardInfo.h"
#import "CCCAccount.h"

extern NSString * _Nonnull const CCCAPIErrorDomain;
extern NSInteger const CCCAPIErrorCodeNoEndpoint;
extern NSInteger const CCCAPIErrorCodeInvalidCardData;

/**
 This class is used to make the API call to generate a token for a card object.

 Its a singleton class and endpoint
 should be set before calling generateAccountForCard:completion:. The endpoint will be provided to you by CardConnect.
 Logging on the api call can be enabled by setting enableLogging to `TRUE`.

 Examples:

 - [CCCAPI instance].endpoint = @"{your card secure endpoint}";
 - [[CCCAPI instance] generateAccountForCard:card completion:];
 */
@interface CCCAPI : NSObject

/**
 Returns the singleton instance of the class.
 */
+(instancetype _Nonnull )instance;

/**
 Your token generation endpoint provided by CardConnect.
 */
@property(nonatomic, copy) NSString * _Nullable endpoint;

/**
 Used to enable logging. Default is `FALSE`
 */
@property(nonatomic, assign) BOOL enableLogging;

/**
 Used to generate a token for a card number.

 @param card The card object to generate a token for.
 @param completion A completion block called after the request completes. Contains the account object that can be used
 to save the card to a profile and an error if one occurred.

 @return A session task that can be used to cancel the request.
 */
- (nullable NSURLSessionTask*)generateAccountForCard:(nonnull CCCCardInfo*)card completion:(void(^_Nonnull)(CCCAccount * _Nullable account, NSError * _Nullable error))completion;

/**
 Used to generate a payment token with ApplePay payment information.

 @param payment The PKPayment object returned by PKPaymentAuthorizationViewController.
 @param completion A completion block called after the request completes. Contains the token that can be used for
 authentication and an error if one occurred.

 @return A session task that can be used to cancel the request.
 */
- (nullable NSURLSessionTask*)generateTokenForApplePay:(nonnull PKPayment*)payment completion:(void(^_Nonnull)(NSString * _Nullable token, NSError * _Nullable error))completion;

@end
