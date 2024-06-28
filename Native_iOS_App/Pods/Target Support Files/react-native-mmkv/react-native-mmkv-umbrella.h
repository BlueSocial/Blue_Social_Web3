#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MmkvModule.h"
#import "TypedArray.h"

FOUNDATION_EXPORT double react_native_mmkvVersionNumber;
FOUNDATION_EXPORT const unsigned char react_native_mmkvVersionString[];

