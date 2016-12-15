/*

UIKit & AppKit Bridging Header

*/

#ifndef ILDefines_h
#define ILDefines_h
#include <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#define ILColor UIColor
#define ILGradient UIGradient
#define ILFont UIFont
#define ILImage UIImage
#define ILView UIView
#define ILWindow UIWindow
#define ILViewController UIViewController
#define ILApplicationDelegate UIApplicationDelegate
#define IL_UI_KIT 1

#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#define ILColor NSColor
#define ILGradient NSGradient
#define ILFont NSFont
#define ILImage NSImage
#define ILView NSView
#define ILWindow NSWindow
#define ILViewController NSViewController
#define ILApplicationDelegate NSApplicationDelegate
#define IL_APP_KIT 1
#endif

#endif /* ILDefines_h */
