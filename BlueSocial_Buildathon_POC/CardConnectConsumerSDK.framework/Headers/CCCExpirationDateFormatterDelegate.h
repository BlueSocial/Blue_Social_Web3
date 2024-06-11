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

#import "CCCTextFieldDelegateProxy.h"

#import "CCCTypes.h"

@class CCCCardInfo;

/**
 A UITextFieldDelegate class that will auto format its text field with an expiration date in the format MM/yyyy.

 This class internally contains the expiration date entered into the text field. When text is changed the value is
 updated, formatted and set to the text field. The spacing character between months and years can be changed with
 [CCCExpirationDateFormatterDelegate separatorCharacter].

 You can check if the expiration date is valid using [CCCExpirationDateFormatterDelegate validExpirationDate].

 You can retrieve the expiration date using either [CCCExpirationDateFormatterDelegate expirationDate] or set it to your
 CCCCardInfo object using [CCCExpirationDateFormatterDelegate setExpirationDateOnCardInfo:].

 To clear the expiration date and text field use [CCCTextFieldDelegateProxy clearTextField].
 */
@interface CCCExpirationDateFormatterDelegate : CCCTextFieldDelegateProxy

/**
 The separator character used between month and year in the format.

 The default value is '/'.
 */
@property (nonatomic) unichar separatorCharacter;

/**
 The input count for expiration dates.

 This modifies how many digits will be used to generate the expiration date. Default is CCCExpirationDateInputFour.
 */
@property (nonatomic, assign) CCCExpirationDateInput inputCount;

/**
 Can be used to check if the expiration date is valid.
 */
@property (nonatomic, getter=isValidExpirationDate) BOOL validExpirationDate;

/**
 The NSDate value for the text field if it's a valid date.

 This should be a date in UTC. e.g. "2017-08-01 00:00:00 +0000" for an expiration date of 08/17.
 */
@property (nonatomic, readonly) NSDate *expirationDate;

/**
 Can be used to set the expiration date on a CCCCardInfo object.

 @param cardInfo The CCCCardInfo object you want to assign the expiration date to.

 @see CCCCardInfo
 */
- (void)setExpirationDateOnCardInfo:(CCCCardInfo*)cardInfo;

/**
 Used to create a new date formatter with an existing date.

 Use this for instances of editing an existing date. This should be a date in UTC. e.g. "2017-08-01 00:00:00 +0000"
 for an expiration date of 08/17.

 @param date The date to initialize the formatter with.

 @return An instance of CCCExpirationDateFormatterDelegate.
 */
- (instancetype)initWithDate:(NSDate*)date;

@end
