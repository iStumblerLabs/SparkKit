#import <SparkKit/ILSparkView.h>

/*! Pie and Ring Drawing Hints */
extern NSString* const ILSparkGaugeMinAngleHint; // Deg or Rad?
extern NSString* const ILSparkGaugeMaxAngleHint; // Deg or Rad?
extern NSString* const ILSparkGaugeFillClockwiseHint; // Boolean
extern NSString* const ILSparkGaugeRingWidthHint; // Defaults to 8px

/*! Vert and Horz Drawing Direction Hint */
extern NSString* const ILSparkGaugeFillDirectionHint;

extern CGFloat const ILSparkGaugeDefaultRingWidth; // 8

typedef NS_ENUM(NSInteger, ILSparkGaugeFillDirection) {
    ILSparkGaugeNaturalFill, // Use system text direction
    ILSparkGaugeLeftToRightFill, // Fixed Right to Left
    ILSparkGaugeRightToLeftFill, // Fixed Left to Right
    ILSparkGaugeFlippedFill // Reverse of System Text Direction
};


/*! @abstract drawing style of the level indicator
    @cost IndicatorStyleText - the default style, a textual description of the value
    @cost IndicatorStyleVertical - a vertical indicator, like a thermometer
    @cost IndicatorStyleHorizontal - a horizontal indicator, like a thermometer
    @cost IndicatorStyleSquare - a scaled square centered inside of the border
    @cost IndicatorStyleCircle - a scaled circle centered inside of the border
    @cost IndicatorStyleRing - a circular ring, with zero at the 12 o'clock position
    @cost IndicatorStylePie - a pie chart, with zero at the 12 o'clock pososion
    @cost IndicatorStyleDial - a dial, with zero at the 12 o'clock pososion
*/
typedef NS_ENUM(NSInteger, ILSparkGaugeStyle) {
    ILSparkGaugeTextStyle,
    ILSparkGaugeVerticalStyle,
    ILSparkGaugeHorizontalStyle,
    ILSparkGaugeSquareStyle,
    ILSparkGaugeCircleStyle,
    ILSparkGaugeRingStyle,
    ILSparkGaugePieStyle,
    ILSparkGaugeDialStyle
    // TODO ILSparkGaugeStyleLog
};

@protocol ILSparkGaugeDataSource;

#pragma mark -

/*! @abstract An indicator view which displays a single numeric value as a string */
@interface ILSparkGauge : ILSparkView

/*! @abstract the style of the indicator */
@property (nonatomic, assign) ILSparkGaugeStyle gaugeStyle;

/*! @abstract the data source for the indicator implmeneting the ILIndicatorDataSource protocol */
@property (nonatomic, weak) id<ILSparkGaugeDataSource> dataSource;

// TODO @property (nonatomic, assign) CGFloat minAngle; // angle of the min value for circular indicators
// TODO @property (nonatomic, assign) CGFloat maxAngle; // angle of the max value for circular indicators
// TODO @property (nonatomic, assign) NSUInteger valueDivisions; // number of value divisions (tick-marks)

@end

#pragma mark -

/*! @protocol ILSparkGaugeDataSource
 @brief data source protocol for SparkViews */
@protocol ILSparkGaugeDataSource <NSObject>

/*! @brief instantanious between 0-1 */
@property(nonatomic, readonly) CGFloat datum;

@end
