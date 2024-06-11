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
#import <UIKit/UIKit.h>

#import <PassKit/PassKit.h>

#import "CCCTypes.h"

/**
 Defines the theming used in the UI.
 */
@interface CCCTheme : NSObject

#pragma mark - UINavigation Bar Theming

/**
 The style to use for the navigation bar.
 
 Default is `UIBarStyleBlackTranslucent`.
 */
@property (nonatomic, assign) UIBarStyle navigationBarStyle;

/**
 The color for the navigation bar.
 */
@property (nonatomic, strong, null_resettable) UIColor *navigationBarColor;

/**
 Sets the navigation bar translucent.
 
 Default is `FALSE`.
 */
@property (nonatomic, assign) BOOL navigationBarTranslucent;

/**
 The color for the navigation bar title.
 
 Default is [UIColor whiteColor].
 */
@property (nonatomic, strong, null_resettable) UIColor *navigationTitleColor;

/**
 The font for the navigation bar title.
 */
@property (nonatomic, strong, null_resettable) UIFont *navigationTitleFont;

/**
 The title color for the navigation bar buttons.
 
 Default is [UIColor whiteColor].
 */
@property (nonatomic, strong, null_resettable) UIColor *navigationButtonColor;

/**
 The font for the the navigation bar buttons.
 */
@property (nonatomic, strong, null_resettable) UIFont *navigationButtonFont;

#pragma mark - UI theming -

/**
 The background color for the view controllers.
 */
@property (nonatomic, strong, null_resettable) UIColor *backgroundColor;

/**
 The disclaimer text that appears under accounts.
 
 Default is nil.
 */
@property (nonatomic, strong, nullable) NSString *disclaimerText;

/**
 The text color for disclaimer text.
 */
@property (nonatomic, strong, null_resettable) UIColor *disclaimerTextColor;

/**
 The font for the disclaimer text.
 */
@property (nonatomic, strong, null_resettable) UIFont *disclaimerTextFont;

/**
 The background color for buttons.
 */
@property (nonatomic, strong, null_resettable) UIColor *buttonColor;

/**
 The title color for buttons.
 
 Default is [UIColor whiteColor].
 */
@property (nonatomic, strong, null_resettable) UIColor *buttonTextColor;

/**
 The font for button titles.
 */
@property (nonatomic, strong, null_resettable) UIFont *buttonTextFont;

/**
 The background color for activity spinners.
 */
@property (nonatomic, strong, null_resettable) UIColor *spinnerBackgroundColor;

/**
 The activity indicator style for spinners.
 
 Default is `UIActivityIndicatorViewStyleWhite`.
 */
@property (nonatomic, assign) UIActivityIndicatorViewStyle spinnerStyle;

#pragma mark List Views

/**
 The color for the table separators.
 */
@property (nonatomic, strong, null_resettable) UIColor *listSeparatorColor;

/**
 The background color for the table view cells.
 
 Default is [UIColor whiteColor].
 */
@property (nonatomic, strong, null_resettable) UIColor *listCellColor;

/**
 The title text color for cells.
 */
@property (nonatomic, strong, null_resettable) UIColor *listTextColor;

/**
 The title text font for cells.
 */
@property (nonatomic, strong, null_resettable) UIFont *listTextFont;

/**
 The secondary text color for cells.
 */
@property (nonatomic, strong, null_resettable) UIColor *listSecondaryTextColor;

/**
 The secondary text font for cells.
 */
@property (nonatomic, strong, null_resettable) UIFont *listSecondaryTextFont;

/**
 The section header text color.
 */
@property (nonatomic, strong, null_resettable) UIColor *listSectionHeaderColor;

/**
 The section header text font.
 */
@property (nonatomic, strong, null_resettable) UIFont *listSectionHeaderFont;

#pragma mark Form Views

/**
 Enables/Disables contact information collection.
 
 Setting this option to `YES` will collect name, email and phone on the new account screen. Default is `YES`.
 */
@property (nonatomic, assign) BOOL collectContactInfo;

/**
 Enables/Disables billing address collection.
 
 Setting this option to `YES` will collect street, city and state on the new account screen. Default is `YES`.
 */
@property (nonatomic, assign) BOOL collectBillingAddress;

/**
 The color of the card on new and edit screens.
 
 No default is set. If this color is set, the card will always be this color. If not set, the color will change based on
 the card brand.
 */
@property (nonatomic, strong, nullable) UIColor *cardColor;

/**
 The color for text on the card.
 
 Default is [UIColor whiteColor].
 */
@property (nonatomic, strong, null_resettable) UIColor *cardTextColor;

/**
 The font for text on the card.
 */
@property (nonatomic, strong, null_resettable) UIFont *cardTextFont;

/**
 The text color for text fields in the forms.
 */
@property (nonatomic, strong, null_resettable) UIColor *listInputTextColor;

/**
 The text font for the text fields in the forms.
 */
@property (nonatomic, strong, null_resettable) UIFont *listInputTextFont;

/**
 The color of the toggle when in the `ON` position.
 */
@property (nonatomic, strong, null_resettable) UIColor *listToggleOnColor;

/**
 The tint color for the toggle.
 
 If null, default toggle tint color is used.
 */
@property (nonatomic, strong, nullable) UIColor *listToggleTintColor;

/**
 The thumb color for the toggle.
 
 If null, default toggle thumb color is used.
 */
@property (nonatomic, strong, nullable) UIColor *listToggleThumbColor;

/**
 The mask format for displaying masked values.
 
 Defaults to CCCCardMaskFormatMaskWithLastFour.
 */
@property (nonatomic, assign) CCCCardMaskFormat maskFormat;

/**
 The mask character used when displaying masked values.
 
 Defaults to '•'.
 */
@property (nonatomic, assign) unichar maskCharacter;

/**
 The spacing used when displaying the masked card in the card view..
 
 Defaults to CCCCardMaskSpacingEveryCharacterAndFour.
 */
@property (nonatomic, assign) CCCCardMaskSpacing cardDisplayMaskSpacing;

/**
 The spacing used when displaying masked card number in text fields.
 
 Defaults to CCCCardMaskSpacingEveryCharacterAndFour.
 */
@property (nonatomic, assign) CCCCardMaskSpacing cardTextFieldMaskSpacing;

/**
 The separator character used between month and year in the expiration format.
 
 The default value is '/'.
 */
@property (nonatomic) unichar separatorCharacter;

/**
 The input count for expiration dates.
 
 This modifies how many digits will be used to generate the expiration date. Default is CCCExpirationDateInputFour.
 */
@property (nonatomic, assign) CCCExpirationDateInput expirationDateInputCount;

#pragma mark ApplePay

/**
 The name to display with the ApplePay button.
 
 The default value is 'Pay with ApplePay'.
 */
@property (nonatomic, strong, null_resettable) NSString *applePayButtonDescription;

/**
 The ApplePay button type.
 
 This will change the wording on the ApplePay button.

 The default value is 'PKPaymentButtonTypePlain'.
 */
@property (nonatomic, assign) PKPaymentButtonType applePayButtonType;

/**
 The ApplePay button style.
 
 This will change the color scheme of the ApplePay button.
 
 The default value is 'PKPaymentButtonStyleWhiteOutline'.
 */
@property (nonatomic, assign) PKPaymentButtonStyle applePayButtonStyle;

@end
