#import <QuartzCore/QuartzCore.h>
#ifdef SWIFT_PACKAGE
#import "KitBridge.h"
#else
#import <KitBridge/KitBridge.h>
#endif

// MARK: Constants

extern NSString* const ILSparkStyleFill;
extern NSString* const ILSparkStyleStroke;
extern NSString* const ILSparkStyleBackground;
extern NSString* const ILSparkStyleBorder;
extern NSString* const ILSparkStyleGradient;
extern NSString* const ILSparkStyleIsFilled;
extern NSString* const ILSparkStyleIsBordered;
extern NSString* const ILSparkStyleWidth;
extern NSString* const ILSparkStyleHints;

// MARK: - Line Widths

extern CGFloat const ILHairlineWidth;
extern CGFloat const ILFinelineWidth;
extern CGFloat const ILPathlineWidth;
extern CGFloat const ILBoldlineWidth;

// MARK: -

/// encapsulates style information for an ILSparkViews or ILSparkCell
@interface ILSparkStyle : NSObject <NSCopying>

///  fill color
@property(nonatomic, retain) ILColor* fill;

///  stroke color
@property(nonatomic, retain) ILColor* stroke;

///  background color
@property(nonatomic, retain) ILColor* background;

///  border color
@property(nonatomic, retain) ILColor* border;

///  gradient for color values
@property(nonatomic, retain) ILGradient* gradient;

///  font used to render labels
@property(nonatomic, retain) ILFont* font;

///  color used to render labels, defaults to stroke color
@property(nonatomic, retain) ILColor* fontColor;

///  is the area filled?
@property(nonatomic, assign) BOOL filled;

///  is the view outlined?
@property(nonatomic, assign) BOOL bordered;

///  stroke width
@property(nonatomic, assign) CGFloat width;

///  hints for subclasses
@property(nonatomic, retain) NSDictionary* hints;

///  L10N bundle, for localizing strings
@property(nonatomic, retain) NSBundle* L10Nbundle;

// MARK: -

///  default style given to ILSparkViews when initilized
+ (ILSparkStyle*) defaultStyle;

// MARK: -

///  add provided hints to hints dictionary
- (void) addHints:(NSDictionary*)additionalHints;

///  copy the style and apply the provided hints
- (ILSparkStyle*) copyWithHints:(NSDictionary*)styleHints;

@end

// MARK: -

@protocol ILSparkStyle <NSObject>

///  style information
@property(nonatomic, retain) ILSparkStyle* style;

///  border layer
@property(nonatomic, readonly) CAShapeLayer* border;

@end
