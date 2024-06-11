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

/**
 Values for card issuers.

 Values can be converted to or from string values using:

 - CCC_AccountTypeForIssuer - Returns the string value for the enumeration.
 - CCC_CardIssuerForAccountType - Returns the enumeration for the string value.
 */
typedef NS_ENUM(NSInteger, CCCCardIssuer)
{
    /** No issuer has been set. */
    CCCCardIssuerNone,
    /** Card issued by American Express */
    CCCCardIssuerAMEX,
    /** Card issued by Visa */
    CCCCardIssuerVISA,
    /** Card issued by Discover */
    CCCCardIssuerDiscover,
    /** Card issued by Master Card */
    CCCCardIssuerMasterCard,
    /** Card issued by Diners Club */
    CCCCardIssuerDiners,
    /** Card issued by JCB */
    CCCCardIssuerJCB,
    /** Card issued by Maestro */
    CCCCardIssuerMaestro,
    /** An unrecognized issuer. */
    CCCCardIssuerOther,
};

/**
 Returns the string value of a card issuer.

 @param issuer The enumeration value of a card issuer.

 @return The string value of the issuer.
 */
NSString* CCC_AccountTypeForIssuer(CCCCardIssuer issuer);

/**
 Returns the CCCCardIssuer value of a CardConnect account type.

 @param accountType The account type string value.

 @return The card issuer enumeration for the account type.
 */
CCCCardIssuer CCC_CardIssuerForAccountType(NSString* accountType);

/**
 Values for card masking.
 */
typedef NS_ENUM(NSInteger, CCCCardMaskFormat)
{
    /** Masks all characters except the last four. */
    CCCCardMaskFormatMaskWithLastFour,
    /** Will only return the last four. */
    CCCCardMaskFormatLastFour,
    /** Masks all characters except the first and last four. */
    CCCCardMaskFormatFirstAndLastFour
};

/**
 Values for card mask spacing.
 */
typedef NS_ENUM(NSInteger, CCCCardMaskSpacing)
{
    /** No spacing added. */
    CCCCardMaskSpacingNone,
    /** Adds 4 spaces every 4 characters.*/
    CCCCardMaskSpacingEveryFour,
    /** Adds a space after every character. */
    CCCCardMaskSpacingEveryCharacter,
    /** Adds a space after every character and 4 after every 4 characters */
    CCCCardMaskSpacingEveryCharacterAndFour
};

/**
 Values for expiration date formatting style.
 */
typedef NS_ENUM(NSInteger, CCCExpirationDateInput)
{
    /** Taks and formats expiration date with four digits @"MM%Cyy". */
    CCCExpirationDateInputFour,
    /** Taks and formats expiration date with six digits @"MM%Cyyyy". */
    CCCExpirationDateInputSix
};
