#import <SparkKit/SparkKit.h>

#pragma mark Hints

extern NSString* const ILSparkStackColorsHint; // NSArray<ILColor*>*
// extern NSString* const ILSparkStackGradientHint; // ILGradient*

#pragma mark -

@protocol ILSparkStackDataSource;

/*! @brief ILSparkStack displays a meter with a stack of values, using a list of of colors provided as a style hint  */
@interface ILSparkStack : ILSparkView
@property(nonatomic, weak) id<ILSparkStackDataSource> stackDataSource;

@end

#pragma mark -

/*! @protocol ILSparkStackDataSource
 @brief data source protocol for ILSparkStack */
@protocol ILSparkStackDataSource <NSObject>

/*! @brief any number of numbers */
@property(nonatomic, readonly) NSArray<NSNumber*>* data;

@end

#pragma mark -

/*! ILSParkStyle category for Spark Meters Hints */
@interface ILSparkStyle (ILSparkStack)
@property(nonatomic, readonly) NSArray<ILColor*>* stackColors;

@end

#pragma mark -
#ifdef IL_APP_KIT

/*! @class ILSparkStackCell */
@interface ILSparkStackCell : NSActionCell

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

@end

#endif
