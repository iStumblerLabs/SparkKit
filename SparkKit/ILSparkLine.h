#if SWIFT_PACKAGE
#import "ILSparkView.h"
#else
#import <SparkKit/ILSparkView.h>
#endif

extern NSString* const ILSparkLineScaleFactor;
extern NSString* const ILSparkLineFalloffInterval;

@protocol ILSparkLineDataSource;

// MARK: -

/*! @class ILSparkLine provides a time-series view for iOS and macOS */
@interface ILSparkLine : ILSparkView

/*! @brief dataSource */
@property(nonatomic, retain) NSObject<ILSparkLineDataSource>* dataSource;

@end

#ifdef IL_APP_KIT

// MARK: -

/*! @class ILSparkLineCell */
@interface ILSparkLineCell : NSCell

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

@end

#endif

/*! @struct ILTimePeriod
    @brief describes a range of times with a start time, realtive to 1970 and length of time
*/
typedef struct {
    NSTimeInterval start;
    NSTimeInterval length;
} ILTimePeriod;

// MARK: -

/*! @protocol ILSparkLineDataSource
    @brief Data Source Protocol for ILSparkLine */
@protocol ILSparkLineDataSource

/*! @brief array of dates for which sample values are avaliable */
@property(nonatomic, readonly) NSArray<NSDate*>* sampleDates;

/*! @brief scaled sample value between 0.0 and 1.0 at the index in the sampleDates array */
- (CGFloat) sampleValueAtIndex:(NSUInteger) index;

@optional

/*! @brief reurn sample dates in the time period spefied */
- (NSArray<NSDate*>*) sampleDatesInPeriod:(ILTimePeriod) period;

@end
