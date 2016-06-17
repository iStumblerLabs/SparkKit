#include <TargetConditionals.h>

/*

UIKit & AppKit Bridging Header

*/

#ifndef ILDefines_h
#define ILDefines_h

#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#define ILColor UIColor
#define ILImage UIImage
#define ILView UIView
#define ILViewController UIViewController

#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#define ILColor NSColor
#define ILImage NSImage
#define ILView NSView
#define ILViewController NSViewController

#endif

#endif /* ILDefines_h */
