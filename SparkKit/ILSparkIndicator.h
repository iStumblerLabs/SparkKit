#import <SparkKit/ILSparkView.h>

@protocol ILSparkIndicatorDataSource;

/*!
    @abstract drawing style of the level indicator
    @cost IndicatorStyleText - the default style, a textual description of the value
    @cost IndicatorStyleVertical - a vertical indicator, like a thermometer
    @cost IndicatorStyleHorizontal - a horizontal indicator, like a thermometer
    @cost IndicatorStyleSquare - a scaled square centered inside of the border
    @cost IndicatorStyleCircle - a scaled circle centered inside of the border
    @cost IndicatorStyleRing - a circular ring, with zero at the 12 o'clock position
    @cost IndicatorStylePie - a pie chart, with zero at the 12 o'clock pososion
    @cost IndicatorStyleDial - a dial, with zero at the 12 o'clock pososion
*/
typedef NS_ENUM(NSInteger, ILSparkIndicatorStyle) {
    ILIndicatorStyleText,
    ILIndicatorStyleVertical,
    ILIndicatorStyleHorizontal,
    ILIndicatorStyleSquare,
    ILIndicatorStyleCircle,
    ILIndicatorStyleRing,
    ILIndicatorStylePie,
    ILIndicatorStyleDial
    // TODO ILIndicatorStyleLog
};

#pragma mark -

/*! @abstract An indicator view which displays a single numeric value as a string */
@interface ILSparkIndicator : ILSparkView

/*! @abstract the style of the indicator */
@property (nonatomic, assign) ILSparkIndicatorStyle indicatorStyle;

/*! @abstract the data source for the indicator implmeneting the ILIndicatorDataSource protocol */
@property (nonatomic, weak) id<ILSparkIndicatorDataSource> dataSource;

// TODO @property (nonatomic, assign) CGFloat minAngle; // angle of the min value for circular indicators
// TODO @property (nonatomic, assign) CGFloat maxAngle; // angle of the max value for circular indicators
// TODO @property (nonatomic, assign) NSUInteger valueDivisions; // number of value divisions (tick-marks)

@end

#pragma mark -

/*! @protocol ILSparkIndicatorDataSource
 @brief data source protocol for SparkViews */
@protocol ILSparkIndicatorDataSource <NSObject>

/*! @brief instantanious between 0-1 */
@property(nonatomic, readonly) CGFloat datum;

@end
