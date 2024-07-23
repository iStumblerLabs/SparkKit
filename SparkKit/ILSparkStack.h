#if SWIFT_PACKAGE
#import "SparkKit.h"
#else
#import <SparkKit/SparkKit.h>
#endif

// MARK: Hints

extern NSString* const ILSparkStackColorsHint; // NSArray<ILColor*>*
// extern NSString* const ILSparkStackGradientHint; // ILGradient*

// MARK: -

@protocol ILSparkStackDataSource;

/*! @brief ILSparkStack displays a meter with a stack of values, using a list of of colors provided as a style hint  */
@interface ILSparkStack : ILSparkView
@property(nonatomic, weak) id<ILSparkStackDataSource> stackDataSource;

@end

// MARK: -

/*! @protocol ILSparkStackDataSource
 @brief data source protocol for ILSparkStack */
@protocol ILSparkStackDataSource <NSObject>

/*! @brief any number of numbers */
@property(nonatomic, readonly) NSArray<NSNumber*>* data;

@end

// MARK: -

/*! ILSParkStyle category for Spark Meters Hints */
@interface ILSparkStyle (ILSparkStack)
@property(nonatomic, readonly) NSArray<ILColor*>* stackColors;

@end

// MARK: -
#ifdef IL_APP_KIT

/*! @class ILSparkStackCell */
@interface ILSparkStackCell : NSActionCell

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

@end

#endif
