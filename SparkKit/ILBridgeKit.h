/*

UIKit & AppKit Bridging Header

*/

#ifndef ILDefines_h
#define ILDefines_h
#include <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV
@import UIKit;
#define ILColor UIColor
#define ILImage UIImage
#define ILView UIView
#define ILViewController UIViewController
#define ILApplicationDelegate UIApplicationDelegate
#define IL_UI_KIT

#elif TARGET_OS_MAC
@import AppKit;
#define ILColor NSColor
#define ILImage NSImage
#define ILView NSView
#define ILViewController NSViewController
#define ILApplicationDelegate UIApplicationDelegate
#define IL_APP_KIT
#endif

#endif /* ILDefines_h */
