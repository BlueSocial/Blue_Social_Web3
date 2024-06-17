//
//  TypewriterLabel.swift
//  Blue
//
//  Created by Blue.

import UIKit

/// A UILabel subclass that adds a ghost type writing animation effect.

public class TypewriterLabel: UILabel {
    
    /// Interval (time gap) between each character being animated on screen.
    public var typingTimeInterval: TimeInterval = 0.04
    
    /// Timer instance that control's the animation.
    private var animationTimer: Timer?
    
    /// Allows for text to be hidden before animation begins.
    public var hideTextBeforeTypewritingAnimation = true {
        didSet {
            configureTransparency()
        }
    }
    
    // MARK: - Lifecycle
    
    /**
     Triggered when label is added to superview, will configure label with provided transparency.
     
     - Parameter toSuperview: view that label is added to.
     */
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        configureTransparency()
    }
    
    /**
     Tidies the animation up if it's still in progress by invalidating the timer.
     */
    deinit {
        animationTimer?.invalidate()
    }
    
    // MARK: - TypingAnimation
    
    /**
     Starts the type writing animation.
     
     - Parameter completion: a callback block/closure for when the type writing animation is complete. This can be useful for chaining multiple animations together.
     */
    public func startTypewritingAnimation(completion: (() -> Void)? = nil) {
        guard let attributedText = attributedText else {
            return
        }
        
        setAttributedTextColorToTransparent()
        stopTypewritingAnimation()
        var animateUntilCharacterIndex = attributedText.string.startIndex
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: typingTimeInterval, repeats: true, block: { (timer: Timer) in
            if animateUntilCharacterIndex < attributedText.string.endIndex {
                self.setAlphaOnAttributedText(1, visibleCharacterEndIndex: animateUntilCharacterIndex)
                animateUntilCharacterIndex = attributedText.string.index(after: animateUntilCharacterIndex)
            } else {
                completion?()
                self.stopTypewritingAnimation()
            }
        })
    }
    
    /**
     Stops the type writing animation.
     */
    public func stopTypewritingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    /**
     Cancels the typing animation and can clear label's content if `clear` is `true`.
     
     - Parameter clear: sets label's content to transparent when animation is cancelled.
     */
    public func cancelTypewritingAnimation(clearText: Bool = true) {
        if clearText {
            setAttributedTextColorToTransparent()
        }
        stopTypewritingAnimation()
    }
    
    // MARK: - Configure
    
    /**
     Adjust transparency to match value set for `hideTextBeforeTypewritingAnimation`.
    */
    private func configureTransparency() {
        if hideTextBeforeTypewritingAnimation {
            setAttributedTextColorToTransparent()
        } else {
            setAttributedTextColorToOpaque()
        }
    }
    
    /**
     Adjusts the alpha value on the attributed string so that it is transparent.
     */
    private func setAttributedTextColorToTransparent() {
        if hideTextBeforeTypewritingAnimation {
            setAlphaOnAttributedText(0)
        }
    }
    
    /**
     Adjusts the alpha value on the attributed string so that it is opaque.
     */
    private func setAttributedTextColorToOpaque() {
        if !hideTextBeforeTypewritingAnimation {
            setAlphaOnAttributedText(1)
        }
    }
    
    /**
     Adjusts the alpha value on the full attributed string.
     
     - Parameter alpha: alpha value the attributed string's characters will be set to.
     */
    private func setAlphaOnAttributedText(_ alpha: CGFloat) {
        guard let attributedText = attributedText else {
            return
        }
        
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.addAttribute(.foregroundColor, value: textColor.withAlphaComponent(alpha), range: NSRange(location:0, length: attributedString.length))
        self.attributedText = attributedString
    }
    
    /**
     Adjusts the alpha value on the attributed string until (inclusive) a certain character length.
     
     - Parameter alpha: alpha value the attributed string's characters will be set to.
     - Parameter characterIndex: upper bound of attributed string's characters that the alpha value will be applied to.
     */
    private func setAlphaOnAttributedText(_ alpha: CGFloat, visibleCharacterEndIndex endIndex: String.Index) {
        guard let attributedText = attributedText else {
            return
        }
        
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        let visibleText = attributedString.string.prefix(through: endIndex)
        
        if let range = attributedString.string.range(of: visibleText) {
            let nsRange = NSRange(range, in: attributedString.string)
            attributedString.addAttribute(.foregroundColor, value: textColor.withAlphaComponent(alpha), range: nsRange)
            self.attributedText = attributedString
        }
    }
}
