#import <Foundation/Foundation.h>
#import <SparkKit/ILSparkView.h>

@protocol ILSparkLineDataSource;

#pragma mark -

/*! @class ILSparkLine */
@interface ILSparkLine : ILSparkView

/*! @brief dataSource */
@property(nonatomic, retain) id<ILSparkLineDataSource> dataSource;

@end

#if !(TARGET_OS_IPHONE || TARGET_OS_TV)

#pragma mark -

/*! @class ILSparkLineCell */
@interface ILSparkLineCell : NSCell

/*! @brief style information
    @discussion defautl time scale is one second per pixel */
@property(nonatomic, retain) ILSparkStyle* style;

@end

#endif

#pragma mark -

/*! @protocol ILSparkLineDataSource
    @brief Data Source Protocol for ILSparkLine */
@protocol ILSparkLineDataSource

/*! @brief array of dates for which sample values are avaliable */
@property(nonatomic, readonly) NSArray<NSDate*>* sampleDates;

/*! @brief scaled sample value between 0.0 and 1.0 at the index in the sampleDates array */
- (CGFloat) sampleValueAtIndex:(NSUInteger) index;

@end
