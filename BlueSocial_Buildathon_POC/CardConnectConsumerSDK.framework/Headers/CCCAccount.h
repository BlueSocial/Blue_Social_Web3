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

#import "CCCTypes.h"

/**
 Defines a payment account as returned by CardConnect.
 */
@interface CCCAccount : NSObject <NSCopying>

/**
 The ID of the account in CardConnect under the user's profile.
 */
@property (nonatomic, copy) NSString *accountID;

/**
 The type of account. i.e. VISA, MASTERCARD ect.
 */
@property (nonatomic, copy) NSString *accountType;

/**
 A flag that opts out of the account updater.
 */
@property (nonatomic, assign) BOOL accountUpdaterOptOut;

/**
 The address of the account.
 */
@property (nonatomic, copy) NSString *address;

/**
 The city of the account.
 */
@property (nonatomic, copy) NSString *city;

/**
 The country of the account.
 */
@property (nonatomic, copy) NSString *country;

/**
 A flag that indicates if this is the default account.
 */
@property (nonatomic, assign) BOOL defaultAccount;

/**
 The email for the account.
 */
@property (nonatomic, copy) NSString *email;

/**
 The expiration date for the account.

 This should be a date in UTC. e.g. "2017-08-01 00:00:00 +0000" for an expiration date of 08/17.
 */
@property (nonatomic, copy) NSDate *expirationDate;

/**
 A flag that indicates if the license was government issued.
 */
@property (nonatomic, assign) BOOL governmentIssued;

/**
 The license number for the account for ACH verification.
 */
@property (nonatomic, copy) NSString *license;

/**
 The name of the account i.e. the card holder name for payment cards.
 */
@property (nonatomic, copy) NSString *name;

/**
 The phone number of the account.
 */
@property (nonatomic, copy) NSString *phone;

/**
 The postal code of the account.
 */
@property (nonatomic, copy) NSString *postalCode;

/**
 The ID of the profile this account belongs to.
 */
@property (nonatomic, copy) NSNumber *profileID;

/**
 The region of the account.
 */
@property (nonatomic, copy) NSString *region;

/**
 The last 4 of the account holder's social security number.
 */
@property (nonatomic, copy) NSString *ssnl4;

/**
 The payment token for the account.
 */
@property (nonatomic, copy) NSString *token;

/**
 The last 4 of the account number.
 */
@property (nonatomic, readonly) NSString *last4;

/**
 Returns an instance of the class initialized with JSON data.

 @param data The JSON data.

 @return An instance of the class.
 */
- (instancetype)initWithData:(NSData*)data;

/**
 Returns JSON data for the object.

 @return The NSData for the JSON of the object.
 */
- (NSData*)dataForObject;

@end
