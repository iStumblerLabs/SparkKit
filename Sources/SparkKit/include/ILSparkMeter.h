#if SWIFT_PACKAGE
#import "ILSparkView.h"
#else
#import <SparkKit/ILSparkView.h>
#endif

// MARK: Hints

/*! Pie and Ring Drawing Hints */
extern NSString* const ILSparkMeterMinAngleHint; // Deg or Rad?
extern NSString* const ILSparkMeterMaxAngleHint; // Deg or Rad?
extern NSString* const ILSparkMeterDialWidthHint; // Defaults to ILSparkMeterDefaultDialWidth
extern NSString* const ILSparkMeterRingWidthHint; // Defaults to ILSparkMeterDefaultRingWidth

/*! Defaults */
extern CGFloat const ILSparkMeterDefaultDialWidth; // 4
extern CGFloat const ILSparkMeterDefaultRingWidth; // 8

/*! Vert and Horz Drawing Direction Hint */
extern NSString* const ILSparkMeterFillDirectionHint;

typedef NS_ENUM(NSInteger, ILSparkMeterFillDirection) {
    ILSparkMeterNaturalFill, // Use system text direction
    ILSparkMeterLeftToRightFill, // Fixed Right to Left or Clockwise
    ILSparkMeterRightToLeftFill, // Fixed Left to Right or Anti-Clockwise
    ILSparkMeterFlippedFill // Reverse of System Text Direction
};

extern NSString* const ILSparkMeterStyleHint;

/*! @abstract drawing style of the level indicator
    @cost ILSparkMeterTextStyle - the default style, a textual description of the value
    @cost ILSparkMeterVerticalStyle - a vertical indicator, like a thermometer
    @cost ILSparkMeterHorizontalStyle - a horizontal indicator, like a thermometer
    @cost ILSparkMeterSquareStyle - a scaled square centered inside of the border
    @cost ILSparkMeterCircleStyle - a scaled circle centered inside of the border
    @cost ILSparkMeterRingStyle - a circular ring, with zero at the 12 o'clock position
    @cost ILSparkMeterPieStyle - a pie chart, with zero at the 12 o'clock pososion
    @cost ILSparkMeterDialStyle - a dial, with zero at the 12 o'clock pososion
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

// MARK: -

/*! @abstract An indicator view which displays a single numeric value as a string */
@interface ILSparkMeter : ILSparkView

/*! @abstract the data source for the indicator implmeneting the ILIndicatorDataSource protocol */
@property(nonatomic, weak) id<ILSparkMeterDataSource> dataSource;

@end

// MARK: -

/*! @protocol ILSparkMeterDataSource
 @brief data source protocol for SparkViews */
@protocol ILSparkMeterDataSource <NSObject>

/*! @brief instantanious between 0-1 */
@property(nonatomic, readonly) CGFloat datum;

@end

// MARK: -

/*! ILSParkStyle category for Spark Meters Hints */
@interface ILSparkStyle (ILSparkMeter)
@property (nonatomic, readonly) ILSparkMeterStyle meterStyle;
@property (nonatomic, readonly) ILSparkMeterFillDirection fillDirection;
@property (nonatomic, readonly) CGFloat minAngle;
@property (nonatomic, readonly) CGFloat maxAngle;
@property (nonatomic, readonly) BOOL fillClockwise;
@property (nonatomic, readonly) CGFloat dialWidth;
@property (nonatomic, readonly) CGFloat ringWidth;

@end

// MARK: -
#ifdef IL_APP_KIT

///  ILSparkMeterCell */
@interface ILSparkMeterCell : NSActionCell

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

@end

#endif
