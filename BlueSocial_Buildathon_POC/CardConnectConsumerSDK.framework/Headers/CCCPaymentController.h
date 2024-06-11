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

#import <UIKit/UIKit.h>

@class CCCTheme;
@class CCCAccount;
@class CCCPaymentRequest;

@protocol CCCAPIBridgeProtocol;
@protocol CCCPaymentControllerDelegate;

/**
 Used to present a pre-build UI that will call your implementation of CCCAPIBridge and return the selected payment
 account.

 The class must use one of the two initialization classes.
 */
@interface CCCPaymentController : NSObject

/**
 The delegate the controller calls when it finishes.
 */
@property (nonatomic, weak, readonly, nullable) id<CCCPaymentControllerDelegate> delegate;

/**
 The payment request that will be used for an ApplePay transaction.

 @see CCCPaymentRequest
 */
@property (nonatomic, nullable, strong) CCCPaymentRequest *paymentRequest;

/**
 Returns an instance of CCCPaymentController initialized with a rootview, api bridge class and delegate.

 @param rootView The view you wish to present the payment controller from.
 @param bridge Your class that conforms to the CCCAPIBridgeProtocol.
 @param delegate Your delegate class for callbacks that conforms to CCCPaymentControllerDelegate.

 @return An instance of CCCPaymentController or nil if rootView, apiBridge or delegate is nil.

 @see CCCAPIBridgeProtocol
 */
- (nullable instancetype)initWithRootView:(nonnull UIViewController*)rootView apiBridge:(nonnull id<CCCAPIBridgeProtocol>)bridge delegate:(nonnull id<CCCPaymentControllerDelegate>)delegate;

/**
 Returns an instance of CCCPaymentController initialized with a rootview, api bridge class, delegate and theme.

 @param rootView The view you wish to present the payment controller from.
 @param bridge Your class that conforms to the CCCAPIBridgeProtocol.
 @param delegate Your delegate class for callbacks that conforms to CCCPaymentControllerDelegate.
 @param theme The theme to use for the payment controller.

 @return An instance of CCCPaymentController or nil if rootView, apiBridge or delegate is nil.

 @see CCCAPIBridgeProtocol
 @see CCCTheme
 */
- (nullable instancetype)initWithRootView:(nonnull UIViewController*)rootView apiBridge:(nonnull id<CCCAPIBridgeProtocol>)bridge delegate:(nonnull id<CCCPaymentControllerDelegate>)delegate theme:(nullable CCCTheme*)theme;

/**
 Presents the payment controller as a modal from your root view.

 If the payment controller was not initialized with a rootView, api bridge and delegate, this will do nothing. If the
 root view is already presenting, this will do nothing.
 */
- (void)presentPaymentView;

/**
 Pushes the payment controller from your root view's navigation stack.

 If the payment controller was not initialized with a rootView, api bridge and delegate, this will do nothing. If the
 root view doesn't have a navigation stack, this will do nothing.
 */
- (void)pushPaymentView;

@end

/**
 The CCCPaymentController delegate callback protocol.

 Defines the callbacks for when CCCPaymentController finishes.
 */
@protocol CCCPaymentControllerDelegate <NSObject>

/**
 Called when a payment account is selected.

 @param controller The CCCPaymentController that selected an account.
 @param account The selected payment account.

 @see CCCAccount
 */
- (void)paymentController:(nonnull CCCPaymentController*)controller finishedWithAccount:(nonnull CCCAccount*)account;

@optional

/**
 Called when the CCCPaymentController is canceled.

 @param controller The CCCPaymentController that was canceled.
 */
- (void)didCancelPaymentController:(nonnull CCCPaymentController*)controller;

/**
 Called when an ApplePay transaction completes.

 If an error occurs during the transaction, it will be displayed and this function wont be called.

 @param controller The CCCPaymentController that finished an ApplePay transaction.
 @param result The result of the ApplePay transaction.
 */
- (void)paymentController:(nonnull CCCPaymentController *)controller finishedApplePayWithResult:(BOOL)result;

@end
