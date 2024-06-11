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

#import "CCCAccount.h"

/**
 CCCAPIBridgeProtocol defines a protocol for communicating with your backend. You should create your own class that
 conforms to this protocol and implement the methods defined.
 */
@protocol CCCAPIBridgeProtocol <NSObject>

/**
 Should retrieve a list of accounts for your customer.

 This function should make a call to your backend that retrieves the accounts associated with your customer and return
 them in the completion handler. Accounts can be initialized using the initWithData: initializer on CCCAccount. You can
 pass what is returned by your backend CardConnect profile call right into this. The completion block must be called for
 the process to continue.

 @param completion A completion block that should return an array of CCCAccount objects and an error if one occurred.

 @see CCCAccount
 */
- (void)CCC_getAccounts:(void(^)(NSArray<CCCAccount *> *accounts, NSError *error))completion;

/**
 Should save an account for your customer.

 This function should make a call to your backend that passes the account object and saves it for the customer. Data for
 account can be obtained by calling [CCCAccount dataForObject]. The completion block must be called for the process to
 continue.

 @param account The account to send to your backend for saving.
 @param completion A completion block that should return the saved account returned or an error if one occurred.

 @see CCCAccount
 */
- (void)CCC_saveAccountToCustomer:(CCCAccount*)account completion:(void(^)(CCCAccount *account, NSError *error))completion;

/**
 Should delete the account for your customer.

 This function should pass the account ID to your backend to delete the account. The completion block must be called for
 the process to continue.

 @param accountID The ID of the account to be deleted.
 @param completion A completion block that should return a boolean result and an error if one occurred.
 */
- (void)CCC_deleteCustomerAccount:(NSString*)accountID completion:(void(^)(BOOL success, NSError *error))completion;

/**
 Should update an account with the provided account object.

 This function should be used to call your backend with the provided account to perform an update. Data for
 account can be obtained by calling [CCCAccount dataForObject]. The completion block must be called for the process to
 continue.

 @param account The account to be updated.
 @param completion A completion block that should return the updated account and an error if once occurred.

 @see CCCAccount
 */
- (void)CCC_updateAccount:(CCCAccount*)account completion:(void(^)(CCCAccount *account, NSError *error))completion;

@optional

/**
 Called when an ApplePay transaction is initiated.

 This function should be used to process a transaction with the provided ApplePay token. The result of the transaction
 should be returned in the completion block to notify the CCCPaymentController of the result.

 @param token The token generated for the ApplePay transaction.
 @param completion A completion block that must be called to return the result of the transaction.

 @see CCCPaymentController
 */
- (void)CCC_authApplePayTransactionWithToken:(NSString*)token completion:(void(^)(BOOL result, NSError *error))completion;

@end
