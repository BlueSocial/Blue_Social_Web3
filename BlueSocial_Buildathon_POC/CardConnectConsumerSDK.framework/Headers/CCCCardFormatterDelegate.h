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

#import "CCCCardFunctions.h"

@class CCCCardInfo;

/**
 A UITextFieldDelegate class that will auto format its text field with a masked card number.

 This class internally contains the card number set in the text field. When the text is changed, this value is updated
 and a masked value is set to the text field. The masking can be changed using [CCCCardFormatterDelegate maskFormat]
 and [CCCCardFormatterDelegate maskCharacter].

 You can check if the card is valid using [CCCCardFormatterDelegate validCard].

 To retrieve the card number, use [CCCCardFormatterDelegate setCardNumberOnCardInfo:] to set it onto your
 CCCCardInfo object.

 To clear the card number and text field use [CCCTextFieldDelegateProxy clearTextField].
 */
@interface CCCCardFormatterDelegate : CCCTextFieldDelegateProxy

/**
 The mask format used for the card number.

 The default setting is CCCCardMaskFormatMaskWithLastFour.
 */
@property (nonatomic) CCCCardMaskFormat maskFormat;

/**
 The mask character used for the card number.

 The default value is '*'.
 */
@property (nonatomic) unichar maskCharacter;

/**
 The spacing used for the card number.

 The default value is CCCCardMaskSpacingNone.
 */
@property (nonatomic, assign) CCCCardMaskSpacing maskSpacing;

/**
 Can be used to check if the card number is valid.
 */
@property (nonatomic, getter=isValidCard) BOOL validCard;

/**
 Should be used to set the card number on a CCCCardInfo object.

 This is the only way to retrieve the unmasked card number from the text field.

 @param cardInfo The CCCCardInfo object you want to assign the card number to.

 @see CCCCardInfo
 */
- (void)setCardNumberOnCardInfo:(CCCCardInfo*)cardInfo;

@end
