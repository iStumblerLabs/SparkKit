#import <KitBridge/KitBridge.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark Line Widths

extern CGFloat const ILHairlineWidth;
extern CGFloat const ILFinelineWidth;
extern CGFloat const ILPathlineWidth;
extern CGFloat const ILBoldlineWidth;

#pragma mark -

/*!
@class ILSparkStyle 
@abstract encapsulates style information for an ILSparkViews or ILSparkCell
*/
@interface ILSparkStyle : NSObject

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

/*! @brief is the area filled? */
@property(nonatomic, assign) BOOL filled;

/*! @brief is the view outlined? */
@property(nonatomic, assign) BOOL bordered;

/*! @brief stroke width */
@property(nonatomic, assign) CGFloat width;

/*! @brief scale factor */
@property(nonatomic, assign) CGFloat scale;

/*! @brief falloff distance
    Distance in pixels between samples which are considered contiguous 0.0 is infinite */
@property(nonatomic, assign) CGFloat falloff;

/*! @brief default style given to ILSparkViews when initilized */
+ (ILSparkStyle*) defaultStyle;

@end

#pragma mark -

@protocol ILSparkStyle <NSObject>

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

/*! @brief border layer */
@property(nonatomic, readonly) CAShapeLayer* border;

@end
