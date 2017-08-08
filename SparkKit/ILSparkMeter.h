#import <SparkKit/ILSparkView.h>

/*! Pie and Ring Drawing Hints */
extern NSString* const ILSparkMeterMinAngleHint; // Deg or Rad?
extern NSString* const ILSparkMeterMaxAngleHint; // Deg or Rad?
extern NSString* const ILSparkMeterFillClockwiseHint; // Boolean
extern NSString* const ILSparkMeterDialWidthHint; // Defaults to ILSparkMeterDefaultDialWidth
extern NSString* const ILSparkMeterRingWidthHint; // Defaults to ILSparkMeterDefaultRingWidth

/*! Vert and Horz Drawing Direction Hint */
extern NSString* const ILSparkMeterFillDirectionHint;

/*! Defaults */
extern CGFloat const ILSparkMeterDefaultDialWidth; // 4
extern CGFloat const ILSparkMeterDefaultRingWidth; // 8

typedef NS_ENUM(NSInteger, ILSparkMeterFillDirection) {
    ILSparkMeterNaturalFill, // Use system text direction
    ILSparkMeterLeftToRightFill, // Fixed Right to Left
    ILSparkMeterRightToLeftFill, // Fixed Left to Right
    ILSparkMeterFlippedFill // Reverse of System Text Direction
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
typedef NS_ENUM(NSInteger, ILSparkMeterStyle) {
    ILSparkMeterTextStyle,
    ILSparkMeterVerticalStyle,
    ILSparkMeterHorizontalStyle,
    ILSparkMeterSquareStyle,
    ILSparkMeterCircleStyle,
    ILSparkMeterRingStyle,
    ILSparkMeterPieStyle,
    ILSparkMeterDialStyle
    // TODO ILSparkMeterStyleLog
};

@protocol ILSparkMeterDataSource;

#pragma mark -

/*! @abstract An indicator view which displays a single numeric value as a string */
@interface ILSparkMeter : ILSparkView

/*! @abstract the style of the indicator */
@property (nonatomic, assign) ILSparkMeterStyle gaugeStyle;

/*! @abstract the data source for the indicator implmeneting the ILIndicatorDataSource protocol */
@property (nonatomic, weak) id<ILSparkMeterDataSource> dataSource;

// TODO @property (nonatomic, assign) CGFloat minAngle; // angle of the min value for circular indicators
// TODO @property (nonatomic, assign) CGFloat maxAngle; // angle of the max value for circular indicators
// TODO @property (nonatomic, assign) NSUInteger valueDivisions; // number of value divisions (tick-marks)

@end

#pragma mark -

/*! @protocol ILSparkMeterDataSource
 @brief data source protocol for SparkViews */
@protocol ILSparkMeterDataSource <NSObject>

/*! @brief instantanious between 0-1 */
@property(nonatomic, readonly) CGFloat datum;

@end
