#import <KitBridge/KitBridge.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark Constants

extern NSString* const ILSparkStyleFill;
extern NSString* const ILSparkStyleStroke;
extern NSString* const ILSparkStyleBackground;
extern NSString* const ILSparkStyleBorder;
extern NSString* const ILSparkStyleGradient;
extern NSString* const ILSparkStyleIsFilled;
extern NSString* const ILSparkStyleIsBordered;
extern NSString* const ILSparkStyleWidth;
extern NSString* const ILSparkStyleHints;

#pragma mark - Line Widths

extern CGFloat const ILHairlineWidth;
extern CGFloat const ILFinelineWidth;
extern CGFloat const ILPathlineWidth;
extern CGFloat const ILBoldlineWidth;

#pragma mark -

/*!
@class ILSparkStyle 
@abstract encapsulates style information for an ILSparkViews or ILSparkCell
*/
@interface ILSparkStyle : NSObject <NSCopying>

/*! @brief fill color */
@property(nonatomic, retain) ILColor* fill;

/*! @brief stroke color */
@property(nonatomic, retain) ILColor* stroke;

/*! @brief background color */
@property(nonatomic, retain) ILColor* background;

/*! @brief border color */
@property(nonatomic, retain) ILColor* border;

/*! @brief gradient for color values */
@property(nonatomic, retain) ILGradient* gradient;

/*! @brief font used to render labels */
@property(nonatomic, retain) ILFont* font;

/*! @brief color used to render labels, defaults to stroke color */
@property(nonatomic, retain) ILColor* fontColor;

/*! @brief is the area filled? */
@property(nonatomic, assign) BOOL filled;

/*! @brief is the view outlined? */
@property(nonatomic, assign) BOOL bordered;

/*! @brief stroke width */
@property(nonatomic, assign) CGFloat width;

/*! @brief hints for subclasses */
@property(nonatomic, retain) NSDictionary* hints;

#pragma mark -

/*! @brief default style given to ILSparkViews when initilized */
+ (ILSparkStyle*) defaultStyle;

#pragma mark -

/*! @brief add provided hints to hints dictionary */
- (void) addHints:(NSDictionary*)additionalHints;

/*! @brief copy the style and apply the provided hints */
- (ILSparkStyle*) copyWithHints:(NSDictionary*)styleHints;

@end

#pragma mark -

@protocol ILSparkStyle <NSObject>

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

/*! @brief border layer */
@property(nonatomic, readonly) CAShapeLayer* border;

@end
