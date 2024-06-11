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

@protocol CCCFormatterDelegateExtension;

/**
 A custom delegate proxy that conforms to UITextFieldDelegate.

 This is the base class used in CCCCardFormatterDelegate, CCCCVVFormatterDelegate and
 CCCExpirationDateFormatterDelegate.
 */
@interface CCCTextFieldDelegateProxy : NSObject <UITextFieldDelegate>

/**
 The original delegate of the text field. e.g. Your UIViewController that contains the UITextField that's using this
 delegate.
 */
@property (nonatomic, weak) IBOutlet id<UITextFieldDelegate> originalDelegate;

/**
 The UITextField this delegate has been set to.

 The textField may not always be available.
 */
@property (nonatomic, strong) UITextField *textField;

/**
 The view to show in the text field's left view when the value is valid.

 You will need to set your leftViewMode. View will not be applied when field is empty.
 */
@property (nonatomic, strong) UIView *leftValidView;

/**
 The view to show in the text fieldss left view when the value is invalid.

 You will need to set your leftViewMode. View will not be applied when field is empty.
 */
@property (nonatomic, strong) UIView *leftInvalidView;

/**
 The view to show in the text field's right view when the value is valid.

 You will need to set your rightViewMode. View will not be applied when field is empty.
 */
@property (nonatomic, strong) UIView *rightValidView;

/**
 The view to show in the text field's right view when the value is invalid.

 You will need to set your rightViewMode. View will not be applied when field is empty.
 */
@property (nonatomic, strong) UIView *rightInvalidView;

/**
 Used to reset the text on the text field.

 Use this if you lost your text field and are resetting the delegate. For instance if the text field is in a cell.

 @param textField The new textfield to set the text of.
*/
- (void)updateTextFieldText:(UITextField*)textField;

/**
 Used to clear the text field.

 This MUST be called to clear custom delegate text fields.
 */
- (void)clearTextField;

@end

/**
 A protocol extending UITextFieldDelegate to provide a callback when characters are changed for a textField.
 */
@protocol CCCFormatterDelegateExtension <UITextFieldDelegate>

@optional

/**
 An optional function called if the delegate class overrides
 [UITextFieldDelegate textField:shouldChangeCharactersInRange:replacementString:] and the text was changed.

 @param formatter The formatter that received the callback from its text field.
 */
- (void)didChangeCharactersInRangeForFormatter:(CCCTextFieldDelegateProxy*)formatter;

@end
